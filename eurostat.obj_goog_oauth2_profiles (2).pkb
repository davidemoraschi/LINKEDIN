DROP PACKAGE BODY OBJ_GOOG_OAUTH2_PROFILES;

CREATE OR REPLACE PACKAGE BODY          obj_goog_oauth2_profiles
AS
   PROCEDURE jsp (   --access_token   IN VARCHAR2 := NULL,
                     --token_type     IN VARCHAR2 := NULL,
                  state IN VARCHAR2 := NULL)
   IS
      http_method          CONSTANT VARCHAR2 (5) := 'GET';
      http_req                      UTL_HTTP.req;
      http_resp                     UTL_HTTP.resp;
      google_analytics_oauth2_url   VARCHAR2 (2000)
                                := 'https://www.googleapis.com/analytics/v3/management/accounts/~all/webproperties/~all/profiles';
      var_http_authorization_header VARCHAR2 (4096);
      -- := token_type || ' ' || urlencode (access_token);
      --      v_user_params                   VARCHAR2 (2048)
      --         := 'code=' || code
      --            || '&client_id=560216110065.apps.googleusercontent.com&client_secret=50sQBHAsM76cVPuMNH6xaE2Z&redirect_uri=http://moraschi.eu:8081/sso/obj_goog_oauth2_auth_cb.jsp&grant_type=authorization_code';
      h_name                        VARCHAR2 (255);
      h_value                       VARCHAR2 (1023);
      res_value                     VARCHAR2 (32767);
      l_clob                        CLOB;
      l_text                        VARCHAR2 (32767);
      l_xml                         XMLTYPE;
      obj                           json;   -- := json ('{a:1,b:[2,3,4],c:true}');
      v_profile_id                  objs_google_analytics.profile_id%TYPE;
      v_profile_name                objs_google_analytics.profile_name%TYPE;
   BEGIN
      BEGIN
         SELECT token_type || ' ' || urlencode (access_token)
         INTO   var_http_authorization_header
         FROM   objs_google_analytics
         WHERE  ACCOUNT = state;
      --      EXCEPTION
      --         WHEN NO_DATA_FOUND
      --         THEN
      --            INSERT INTO objs_google_analytics (account)
      --                 VALUES (state);
      END;

      COMMIT;
      --      HTP.
      --      p (
      --         '<script type="text/javascript">window.location = "https://www.googleapis.com/analytics/v3/management/accounts/~all/webproperties/~all/profiles?access_token='
      --         || access_token
      --         || '"</script>');

      --      IF error = 'access_denied'
      --      THEN
      --         HTP.p (access_token);
      --      ELSE
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, PASSWORD => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
      http_req := UTL_HTTP.begin_request (google_analytics_oauth2_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_body_charset (http_req, 'UTF-8');
      UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header (r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      --HTP.p ('<hr>'||var_http_authorization_header);

      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      --      UTL_HTTP.write_text (http_req, v_user_params);
      http_resp := UTL_HTTP.get_response (http_req);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp, i, h_name, h_value);
      --HTP.p ('<hr>' || h_name || ':' || h_value);
      END LOOP;

      DBMS_LOB.createtemporary (l_clob, FALSE);

      BEGIN
         WHILE 1 = 1
         LOOP
            UTL_HTTP.read_text (http_resp, l_text, 32766);
            DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
         --UTL_HTTP.read_line (http_resp, res_value, TRUE);
         --HTP.p (res_value);
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
      --OWA_UTIL.mime_header ('text/xml', TRUE, 'utf-8');
      --HTP.p (l_xml.getclobval ());
      --         REPLACE (l_xml.EXTRACT ('/root/items[1]/id/text()').getstringval (),
      --                  '&quot;',
      --                  ''));
      --      END IF;
      v_profile_id := REPLACE (l_xml.EXTRACT ('/root/items[1]/id/text()').getstringval (), '&quot;', '');
      v_profile_name := REPLACE (l_xml.EXTRACT ('/root/items[1]/name/text()').getstringval (), '&quot;', '');

      BEGIN
         UPDATE objs_google_analytics
            SET profile_id = v_profile_id
               ,profile_name = v_profile_name
          WHERE ACCOUNT = state;
      --         EXCEPTION
      --            WHEN NO_DATA_FOUND
      --            THEN
      --               INSERT INTO objs_google_analytics (account)
      --                    VALUES (state);
      END;

      COMMIT;
/*
      HTP.
      p (
            '<script type="text/javascript">window.location = "http://moraschi.eu:8081/sso/obj_goog_oauth2_datafeed.jsp?state='
         || state
         --         || '&access_token='
         --         || access_token
         --         || '&token_type='
         --         || token_type
         --         || '&profile_id='
         --         || REPLACE (l_xml.EXTRACT ('/root/items[1]/id/text()').getstringval (), '&quot;', '')
         || '"</script>');
*/
      HTP.p
         ('<script type="text/javascript">window.location = "http://moraschi.eu/MicroStrategy/servlet/mstrWeb?hiddenSections=header&Server=IP-10-195-81-29&Project=EUROSTAT&Port=0&evt=4001&src=mstrWeb.4001&visMode=0&reportViewMode=1&reportID=5CABA42B4568A90D71516096B2C0DF4B"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_goog_oauth2_profiles;
/
