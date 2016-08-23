DROP PROCEDURE POST_UPDATE;

CREATE OR REPLACE PROCEDURE          post_update (lnkd_id IN VARCHAR2 := 'LNKD_74oTveK-gQ')
   AS   http_method                                CONSTANT VARCHAR2 (5) := 'POST';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/person-activities';
      oauth_consumer_key                 VARCHAR2 (500);
      oauth_consumer_secret              VARCHAR2 (500);
      oauth_nonce                        VARCHAR2 (50);
      oauth_timestamp                    VARCHAR2 (50);
      oauth_base_string                  VARCHAR2 (1000);
      oauth_signature                    VARCHAR2 (100);
      oauth_access_token                 VARCHAR2 (500);
      oauth_access_token_secret          VARCHAR2 (500);
      var_http_req_url                   VARCHAR2 (4000);
      return_xml                         VARCHAR2 (30000);
      var_http_authorization_header   VARCHAR2 (4096);
      v_user_params                      VARCHAR2 (2048);
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      v_user_params                      
         :=    '<activity locale="en_US">
                    <content-type>linkedin-html</content-type>
                    <body>&lt;a href=&quot;http://moraschi.eu/MicroStrategy&quot;&gt;'||EUROSTAT.GET_FULLNAME(lnkd_id)||' has found this site interesting: EuroStrategy&lt;/a&gt;. See how you can use your LinkedIn account to log in to MicroStrategy. Test it, share it, and please send your feedback to eurostat.microstrategy@gmail.com</body>
                </activity>';
--      v_user_params                      
--         :=    '<activity locale="en_US">
--                    <content-type>linkedin-html</content-type>
--                    <body>&lt;img src=&quot;http://dl.dropbox.com/u/35291135/images/EuroStrategy_thumb.PNG&quot;&gt;&lt;/img&gt;</body>
--                </activity>';
    UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
 
      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = SUBSTR (lnkd_id, 6);

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - pq_constants.con_num_timestamp_tz_diff)
        INTO oauth_timestamp
        FROM DUAL;

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method
                                               ,oauth_api_url
                                               ,oauth_consumer_key
                                               ,oauth_timestamp
                                               ,oauth_nonce
                                               ,oauth_access_token);
      --|| pkg_oauth.urlencode ('&twitter-post=true');
      oauth_signature := utl_linkedin.
         signature ( oauth_base_string, utl_linkedin.key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
                  oauth_api_url
         || '?'
         || 'oauth_callback'
         || '='
         || 'oob'
         || '&'
         || 'oauth_consumer_key'
         || '='
         || oauth_consumer_key
         || '&'
         || 'oauth_nonce'
         || '='
         || oauth_nonce
         || '&'
         || 'oauth_signature'
         || '='
         || urlencode (oauth_signature)
         || '&'
         || 'oauth_signature_method'
         || '='
         || 'HMAC-SHA1'
         || '&'
         || 'oauth_timestamp'
         || '='
         || oauth_timestamp
         || '&'
         || 'oauth_token'
         || '='
         || oauth_access_token
         || '&'
         || 'oauth_version'
         || '='
         || '1.0';

--         http_req_url_access_token (oauth_api_url
--                                   ,oauth_consumer_key
--                                   ,oauth_timestamp
--                                   ,oauth_nonce
--                                   ,oauth_signature
--                                   ,oauth_access_token);
      var_http_authorization_header :=
                  'OAuth realm="",oauth_version="1.0",oauth_consumer_key="'
         || oauth_consumer_key
         || '",oauth_token="'
         || oauth_access_token
         || '",oauth_timestamp="'
         || oauth_timestamp
         || '",oauth_nonce="'
         || oauth_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (oauth_signature)
         || '"';

--         authorization_header (oauth_consumer_key
--                              ,oauth_access_token
--                              ,oauth_timestamp
--                              ,oauth_nonce
--                              ,oauth_signature);
      http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);

      UTL_HTTP.set_body_charset ( http_req, 'UTF-8');
      UTL_HTTP.set_header ( http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'application/xml');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      UTL_HTTP.write_text ( http_req, v_user_params);
      /*
            DBMS_OUTPUT.put_line ('oauth_consumer_key=' || oauth_consumer_key);
            DBMS_OUTPUT.put_line ('oauth_timestamp=' || oauth_timestamp);
            DBMS_OUTPUT.put_line ('oauth_nonce=' || oauth_nonce);
            DBMS_OUTPUT.put_line ('oauth_consumer_secret=' || oauth_consumer_secret);
            DBMS_OUTPUT.put_line ('oauth_access_token=' || oauth_access_token);
            DBMS_OUTPUT.put_line ('oauth_access_token_secret=' || oauth_access_token_secret);
            DBMS_OUTPUT.put_line ('oauth_base_string=' || oauth_base_string);
            DBMS_OUTPUT.put_line ('oauth_signature=' || oauth_signature);
            DBMS_OUTPUT.put_line ('v_user_params=' || v_user_params);
      */
      http_resp   := UTL_HTTP.get_response (http_req);

      IF show_header = 1
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);

         FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
         LOOP
            UTL_HTTP.get_header (http_resp
                                ,i
                                ,h_name
                                ,h_value);
            DBMS_OUTPUT.put_line (h_name || ': ' || h_value);
         END LOOP;
      END IF;

      BEGIN
         DBMS_OUTPUT.put_line ('Response: ');

         WHILE 1 = 1
         LOOP
            UTL_HTTP.read_line ( http_resp, res_value, TRUE);
            DBMS_OUTPUT.put_line (res_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (http_resp);

      --DBMS_OUTPUT.put_line ('finito');
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
--         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
--         DBMS_OUTPUT.put_line (SQLERRM);
--         RAISE;
END post_update;
/
