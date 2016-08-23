DROP PACKAGE BODY OBJ_GOOG_OAUTH2_AUTH_CB;

CREATE OR REPLACE PACKAGE BODY          obj_goog_oauth2_auth_cb
AS
   PROCEDURE jsp (state IN VARCHAR2 := NULL, code IN VARCHAR2 := NULL, error IN VARCHAR2 := NULL)
   IS
      --      var_http_authorization_header   VARCHAR2 (4096);
      var_user_params   VARCHAR2 (2048)
                           :=    'code='
                              || code
                              || '&client_id='
                              || obj_goog_oauth2_auth.con_str_goog_client_id
                              || '&client_secret='
                              || obj_goog_oauth2_auth.con_str_goog_client_secret
                              || '&redirect_uri='
                              || obj_goog_oauth2_auth.con_str_mstr_auth_callback
                              || '&grant_type=authorization_code';
      http_req          UTL_HTTP.req;
      http_resp         UTL_HTTP.resp;
      h_name            VARCHAR2 (255);
      h_value           VARCHAR2 (1023);
      --      res_value                       VARCHAR2 (32767);
      l_clob            CLOB;
      l_text            VARCHAR2 (32767);
      l_xml             XMLTYPE;
      obj               json;
      v_access_token    objs_google_analytics.access_token%TYPE;
      v_token_type      objs_google_analytics.token_type%TYPE;
      v_expires_in      objs_google_analytics.expires_in%TYPE;
   --v_access_token    objs_google_analytics.access_token%TYPE;
   BEGIN
      IF error = 'access_denied'
      THEN
         HTP.p ('[access_denied] Error. You need to authorize data access to execute this report.');
      ELSE
         BEGIN
            UPDATE objs_google_analytics
               SET authorization_code = code
             WHERE account = state;
         --         EXCEPTION
         --            WHEN NO_DATA_FOUND
         --            THEN
         --               INSERT INTO objs_google_analytics (account)
         --                    VALUES (state);
         END;

         COMMIT;
         UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
         UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
         UTL_HTTP.set_response_error_check (FALSE);
         UTL_HTTP.set_detailed_excp_support (FALSE);
         http_req := UTL_HTTP.begin_request (con_str_goog_token_endpoint, http_method, UTL_HTTP.http_version_1_1);

         UTL_HTTP.set_body_charset (http_req, 'UTF-8');
         UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
         UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
         UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (var_user_params));
         UTL_HTTP.write_text (http_req, var_user_params);
         http_resp := UTL_HTTP.get_response (http_req);

         FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
         LOOP
            UTL_HTTP.get_header (http_resp,
                                 i,
                                 h_name,
                                 h_value);
         END LOOP;

         DBMS_LOB.createtemporary (l_clob, FALSE);

         BEGIN
            WHILE 1 = 1
            LOOP
               UTL_HTTP.read_text (http_resp, l_text, 32766);
               DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
            --               UTL_HTTP.read_line (http_resp, res_value, TRUE);
            --               HTP.p (res_value);
            END LOOP;
         EXCEPTION
            WHEN UTL_HTTP.end_of_body
            THEN
               NULL;
         END;

         UTL_HTTP.end_response (http_resp);
         obj := json (l_clob);
         l_xml := json_xml.json_to_xml (obj);
         DBMS_LOB.freetemporary (l_clob);
         --OWA_UTIL.mime_header ( 'text/xml', TRUE, 'utf-8');
         v_access_token := l_xml.EXTRACT ('/root/access_token/text()').getstringval ();
         v_token_type := l_xml.EXTRACT ('/root/token_type/text()').getstringval ();
         v_expires_in := l_xml.EXTRACT ('/root/expires_in/text()').getstringval ();
         v_access_token := REPLACE (v_access_token, '&quot;', '');
         v_token_type := REPLACE (v_token_type, '&quot;', '');
         v_expires_in := REPLACE (v_expires_in, '&quot;', '');

         BEGIN
            UPDATE objs_google_analytics
               SET access_token = v_access_token,
                   token_type = v_token_type,
                   expires_in = v_expires_in,
                   creation_date = SYSTIMESTAMP
             WHERE account = state;
         --         EXCEPTION
         --            WHEN NO_DATA_FOUND
         --            THEN
         --               INSERT INTO objs_google_analytics (account)
         --                    VALUES (state);
         END;

         COMMIT;
         HTP.
         p (
            '<script type="text/javascript">window.location = "http://moraschi.eu:8081/sso/obj_goog_oauth2_profiles.jsp?state='
            || state
            --            || '&access_token='
            --            || v_access_token
            --            || '&token_type='
            --            || v_token_type
            || '"</script>');
      --         HTP.
      --         p (
      --            '<script type="text/javascript">window.location = "https://www.googleapis.com/analytics/v3/management/accounts/~all/webproperties/~all/profiles?access_token='
      --            || access_token
      --            || '"</script>');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_goog_oauth2_auth_cb;
/
