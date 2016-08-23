DROP FUNCTION GOOGLE_ANALYTICS_OAUTH2_AUTH;

CREATE OR REPLACE FUNCTION          google_analytics_oauth2_auth
   RETURN VARCHAR2
IS
   --https://accounts.google.com/o/oauth2/auth?response_type=code&scope=https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile&redirect_uri=https://oauth2-login-demo.appspot.com/code&approval_prompt=force&state=/profile&client_id=812741506391.apps.googleusercontent.com&hl=en-US&from_login=1&as=-2d6de5b147ff9308&pli=1
   http_method            CONSTANT VARCHAR2 (5) := 'GET';
   http_req                        UTL_HTTP.req;
   http_resp                       UTL_HTTP.resp;
   google_analytics_oauth2_url     VARCHAR2 (2000) := 'https://accounts.google.com/o/oauth2/auth';
   var_http_authorization_header   VARCHAR2 (4096);
   v_user_params                   VARCHAR2 (2048)
      := 'response_type=code&client_id=560216110065.apps.googleusercontent.com&scope=https://www.googleapis.com/auth/analytics.readonly&redirect_uri=http://moraschi.eu:8081/sso/obj_goog_request_token_cb.jsp';
   h_name                          VARCHAR2 (255);
   h_value                         VARCHAR2 (1023);
   res_value                       VARCHAR2 (32767);
BEGIN
   UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);
   --   http_req := UTL_HTTP.begin_request (google_analytics_oauth2_url, http_method, UTL_HTTP.http_version_1_1);
   http_req :=
      UTL_HTTP.begin_request (google_analytics_oauth2_url || '?' || v_user_params, http_method, UTL_HTTP.http_version_1_1);

   UTL_HTTP.set_body_charset (http_req, 'UTF-8');
   UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
   --UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
   --UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
   --UTL_HTTP.write_text (http_req, v_user_params);
   http_resp := UTL_HTTP.get_response (http_req);

   FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
   LOOP
      UTL_HTTP.get_header (http_resp,
                           i,
                           h_name,
                           h_value);
      DBMS_OUTPUT.put_line (h_name || ' : ' || h_value);
   END LOOP;

   BEGIN
      WHILE 1 = 1
      LOOP
         UTL_HTTP.read_line (http_resp, res_value, TRUE);
         DBMS_OUTPUT.put_line (res_value);

         IF INSTR (res_value, 'Auth') > 0
         THEN
            var_http_authorization_header := res_value;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;

   UTL_HTTP.end_response (http_resp);

   RETURN var_http_authorization_header;
END;
/
