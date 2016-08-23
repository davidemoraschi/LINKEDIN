DROP FUNCTION GOOGLE_ANALYTICS_LOGIN;

CREATE OR REPLACE FUNCTION          google_analytics_login
   RETURN VARCHAR2
IS
   http_method            CONSTANT VARCHAR2 (5) := 'POST';
   http_req                        UTL_HTTP.req;
   http_resp                       UTL_HTTP.resp;
   con_str_wallet_path    CONSTANT VARCHAR2 (50)
      := 'file:/u01/app/oracle/product/11.2.0/wallet' ;
   con_str_wallet_pass    CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   google_analytics__api_url       VARCHAR2 (2000)
      := 'https://www.google.com/accounts/ClientLogin';
   var_http_authorization_header   VARCHAR2 (4096);
   v_user_params                   VARCHAR2 (2048)
      := 'accountType=GOOGLE&Email=eurostat.microstrategy@gmail.com&Passwd=3SamsungGalaxySII&service=analytics&source=EuroStrategy-1.05';
   h_name                          VARCHAR2 (255);
   h_value                         VARCHAR2 (1023);
   res_value                       VARCHAR2 (32767);
BEGIN
   UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH       => pq_constants.con_str_wallet_path,
                        password   => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);
   http_req :=
      UTL_HTTP.begin_request (google_analytics__api_url,
                              http_method,
                              UTL_HTTP.http_version_1_1);

   UTL_HTTP.set_body_charset (http_req, 'UTF-8');
   UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
   UTL_HTTP.set_header (r       => http_req,
                        NAME    => 'Content-Type',
                        VALUE   => 'application/x-www-form-urlencoded');
   UTL_HTTP.set_header (r       => http_req,
                        NAME    => 'Content-Length',
                        VALUE   => LENGTH (v_user_params));
   UTL_HTTP.write_text (http_req, v_user_params);
   http_resp := UTL_HTTP.get_response (http_req);

   FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
   LOOP
      UTL_HTTP.get_header (http_resp,
                           i,
                           h_name,
                           h_value);
   END LOOP;

   BEGIN
      WHILE 1 = 1
      LOOP
         UTL_HTTP.read_line (http_resp, res_value, TRUE);

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
