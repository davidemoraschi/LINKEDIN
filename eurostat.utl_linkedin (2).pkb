DROP PACKAGE BODY UTL_LINKEDIN;

CREATE OR REPLACE PACKAGE BODY          utl_linkedin
AS
   FUNCTION base_string (p_http_method         IN VARCHAR2
                        ,p_request_token_url   IN VARCHAR2
                        ,p_consumer_key        IN VARCHAR2
                        ,p_timestamp           IN VARCHAR2
                        ,p_nonce               IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_base_string                VARCHAR2 (2000);
   BEGIN
      SELECT p_http_method || '&' || urlencode (p_request_token_url) || '&'
             || urlencode (
                      'oauth_callback'
                   || '='
                   || 'oob'
                   || '&'
                   || 'oauth_consumer_key'
                   || '='
                   || urlencode (p_consumer_key)
                   || '&'
                   || 'oauth_nonce'
                   || '='
                   || p_nonce
                   || '&'
                   || 'oauth_signature_method'
                   || '='
                   || 'HMAC-SHA1'
                   || '&'
                   || 'oauth_timestamp'
                   || '='
                   || p_timestamp
                   || '&'
                   || 'oauth_version'
                   || '='
                   || '1.0')
        INTO v_oauth_base_string
        FROM DUAL;

      RETURN v_oauth_base_string;
   END base_string;

   FUNCTION base_string_callback (p_http_method         IN VARCHAR2
                                 ,p_request_token_url   IN VARCHAR2
                                 ,p_callback_url        IN VARCHAR2
                                 ,p_consumer_key        IN VARCHAR2
                                 ,p_timestamp           IN VARCHAR2
                                 ,p_nonce               IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_base_string                VARCHAR2 (2000);
   BEGIN
      SELECT p_http_method || '&' || urlencode (p_request_token_url) || '&'
             || urlencode (
                      'oauth_callback'
                   || '='
                   || urlencode (p_callback_url)
                   || '&'
                   || 'oauth_consumer_key'
                   || '='
                   || urlencode (p_consumer_key)
                   || '&'
                   || 'oauth_nonce'
                   || '='
                   || p_nonce
                   || '&'
                   || 'oauth_signature_method'
                   || '='
                   || 'HMAC-SHA1'
                   || '&'
                   || 'oauth_timestamp'
                   || '='
                   || p_timestamp
                   || '&'
                   || 'oauth_version'
                   || '='
                   || '1.0')
        INTO v_oauth_base_string
        FROM DUAL;

      RETURN v_oauth_base_string;
   END base_string_callback;

   FUNCTION base_string_token (p_http_method         IN VARCHAR2
                              ,p_request_token_url   IN VARCHAR2
                              ,p_consumer_key        IN VARCHAR2
                              ,p_timestamp           IN VARCHAR2
                              ,p_nonce               IN VARCHAR2
                              ,p_token               IN VARCHAR2
                              ,p_token_verifier      IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_base_string                VARCHAR2 (2000);
   BEGIN
      SELECT p_http_method || '&' || urlencode (p_request_token_url) || '&'
             || urlencode (
                      --                      'oauth_callback'
                      --                   || '='
                      --                   || 'oob'
                      --                   || '&'
                      --||
                      'oauth_consumer_key'
                   || '='
                   || urlencode (p_consumer_key)
                   || '&'
                   || 'oauth_nonce'
                   || '='
                   || p_nonce
                   || '&'
                   || 'oauth_signature_method'
                   || '='
                   || 'HMAC-SHA1'
                   || '&'
                   || 'oauth_timestamp'
                   || '='
                   || p_timestamp
                   || '&'
                   || 'oauth_token'
                   || '='
                   || urlencode (p_token)
                   || '&'
                   || 'oauth_verifier'
                   || '='
                   || p_token_verifier
                   || '&'
                   || 'oauth_version'
                   || '='
                   || '1.0')
        INTO v_oauth_base_string
        FROM DUAL;

      RETURN v_oauth_base_string;
   END base_string_token;

   FUNCTION base_string_access_token (p_http_method         IN VARCHAR2
                                     ,p_request_token_url   IN VARCHAR2
                                     ,p_consumer_key        IN VARCHAR2
                                     ,p_timestamp           IN VARCHAR2
                                     ,p_nonce               IN VARCHAR2
                                     ,p_token               IN VARCHAR2)
      RETURN VARCHAR2
   AS
      /*
       oauth_consumer_key
       oauth_nonce
       oauth_signature_method
       oauth_timestamp
       oauth_version

       oauth_signature

       action=user-get
       response=xml

   */
      v_oauth_base_string                VARCHAR2 (2000);
   BEGIN
      SELECT p_http_method || '&' || urlencode (p_request_token_url) || '&'
             || urlencode (
                      'oauth_consumer_key'
                   || '='
                   || urlencode (p_consumer_key)
                   || '&'
                   || 'oauth_nonce'
                   || '='
                   || p_nonce
                   || '&'
                   || 'oauth_signature_method'
                   || '='
                   || 'HMAC-SHA1'
                   || '&'
                   || 'oauth_timestamp'
                   || '='
                   || p_timestamp
                   || '&'
                   || 'oauth_token'
                   || '='
                   || urlencode (p_token)
                   || '&'
                   || 'oauth_version'
                   || '='
                   || '1.0')
        INTO v_oauth_base_string
        FROM DUAL;

      RETURN v_oauth_base_string;
   END base_string_access_token;

   FUNCTION base_string_access_token_par (p_http_method         IN VARCHAR2,
                                          p_request_token_url   IN VARCHAR2,
                                          p_consumer_key        IN VARCHAR2,
                                          p_timestamp           IN VARCHAR2,
                                          p_nonce               IN VARCHAR2,
                                          p_token               IN VARCHAR2,
                                          p_par                 IN VARCHAR2)
      RETURN VARCHAR2
   AS
      /*
       oauth_consumer_key
       oauth_nonce
       oauth_signature_method
       oauth_timestamp
       oauth_version

       oauth_signature

       action=user-get
       response=xml

   */
      v_oauth_base_string                VARCHAR2 (2000);
   BEGIN
      SELECT p_http_method || '&' || urlencode (p_request_token_url) || '&'||urlencode (p_par)
             || urlencode (
                      '&oauth_consumer_key'
                   || '='
                   || urlencode (p_consumer_key)
                   || '&'
                   || 'oauth_nonce'
                   || '='
                   || p_nonce
                   || '&'
                   || 'oauth_signature_method'
                   || '='
                   || 'HMAC-SHA1'
                   || '&'
                   || 'oauth_timestamp'
                   || '='
                   || p_timestamp
                   || '&'
                   || 'oauth_token'
                   || '='
                   || urlencode (p_token)
                   || '&'
                   || 'oauth_version'
                   || '='
                   || '1.0')
        INTO v_oauth_base_string
        FROM DUAL;

      RETURN v_oauth_base_string;
   END base_string_access_token_par;

   FUNCTION KEY (p_consumer_secret IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_key                        VARCHAR2 (500);
   BEGIN
      SELECT urlencode (p_consumer_secret) || '&' INTO v_oauth_key FROM DUAL;

      RETURN v_oauth_key;
   END KEY;

   FUNCTION key_token ( p_consumer_secret IN VARCHAR2, p_token_secret IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_key                        VARCHAR2 (500);
   BEGIN
      SELECT urlencode (p_consumer_secret) || '&' || urlencode (p_token_secret) --giá urlencodato
                                                                               INTO v_oauth_key FROM DUAL;

      RETURN v_oauth_key;
   END key_token;

   FUNCTION signature ( p_oauth_base_string IN VARCHAR2, p_oauth_key IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_signature                  VARCHAR2 (500);
   BEGIN
      v_oauth_signature :=
         UTL_RAW.cast_to_varchar2 (
            UTL_ENCODE.base64_encode (
               DBMS_CRYPTO.mac ( UTL_I18N.string_to_raw ( p_oauth_base_string, 'AL32UTF8'), DBMS_CRYPTO.hmac_sh1, UTL_I18N.string_to_raw ( p_oauth_key, 'AL32UTF8'))));
      RETURN v_oauth_signature;
   END signature;

   FUNCTION http_req_url (p_request_token_url   IN VARCHAR2
                         ,p_consumer_key        IN VARCHAR2
                         ,p_timestamp           IN VARCHAR2
                         ,p_nonce               IN VARCHAR2
                         ,p_signature           IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_http_req_url                     VARCHAR2 (4000);
   BEGIN
      v_http_req_url :=
            p_request_token_url
         || '?'
         || 'oauth_callback'
         || '='
         || 'oob'
         || '&'
         || 'oauth_consumer_key'
         || '='
         || p_consumer_key
         || '&'
         || 'oauth_nonce'
         || '='
         || p_nonce
         || '&'
         || 'oauth_signature'
         || '='
         || urlencode (p_signature)
         || '&'
         || 'oauth_signature_method'
         || '='
         || 'HMAC-SHA1'
         || '&'
         || 'oauth_timestamp'
         || '='
         || p_timestamp
         || '&'
         || 'oauth_version'
         || '='
         || '1.0';
      RETURN v_http_req_url;
   END http_req_url;

   FUNCTION http_req_url_token (p_request_token_url   IN VARCHAR2
                               ,p_consumer_key        IN VARCHAR2
                               ,p_timestamp           IN VARCHAR2
                               ,p_nonce               IN VARCHAR2
                               ,p_signature           IN VARCHAR2
                               ,p_token               IN VARCHAR2
                               ,p_token_verifier      IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_http_req_url                     VARCHAR2 (4000);
   BEGIN
      v_http_req_url :=
            p_request_token_url
         || '?'
         || 'oauth_callback'
         || '='
         || 'oob'
         || '&'
         || 'oauth_consumer_key'
         || '='
         || p_consumer_key
         || '&'
         || 'oauth_nonce'
         || '='
         || p_nonce
         || '&'
         || 'oauth_signature'
         || '='
         || urlencode (p_signature)
         || '&'
         || 'oauth_signature_method'
         || '='
         || 'HMAC-SHA1'
         || '&'
         || 'oauth_timestamp'
         || '='
         || p_timestamp
         || '&'
         || 'oauth_token'
         || '='
         || urlencode (p_token)
         || '&'
         || 'oauth_verifier'
         || '='
         || p_token_verifier
         || '&'
         || 'oauth_version'
         || '='
         || '1.0';
      RETURN v_http_req_url;
   END http_req_url_token;

   FUNCTION http_req_url_access_token (p_request_token_url   IN VARCHAR2
                                      ,p_consumer_key        IN VARCHAR2
                                      ,p_timestamp           IN VARCHAR2
                                      ,p_nonce               IN VARCHAR2
                                      ,p_signature           IN VARCHAR2
                                      ,p_token               IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_http_req_url                     VARCHAR2 (4000);
   BEGIN
      v_http_req_url :=
            p_request_token_url
         || '?'
         || 'oauth_callback'
         || '='
         || 'oob'
         || '&'
         || 'oauth_consumer_key'
         || '='
         || p_consumer_key
         || '&'
         || 'oauth_nonce'
         || '='
         || p_nonce
         || '&'
         || 'oauth_signature'
         || '='
         || urlencode (p_signature)
         || '&'
         || 'oauth_signature_method'
         || '='
         || 'HMAC-SHA1'
         || '&'
         || 'oauth_timestamp'
         || '='
         || p_timestamp
         || '&'
         || 'oauth_token'
         || '='
         || p_token
         || '&'
         || 'oauth_version'
         || '='
         || '1.0';
      RETURN v_http_req_url;
   END http_req_url_access_token;

   FUNCTION get_token ( the_list VARCHAR2, the_index NUMBER, delim VARCHAR2 := ',')
      RETURN VARCHAR2
   IS
      start_pos                          NUMBER;
      end_pos                            NUMBER;
   BEGIN
      IF the_index = 1
      THEN
         start_pos   := 1;
      ELSE
         start_pos   :=
            INSTR (the_list
                  ,delim
                  ,1
                  ,the_index - 1);

         IF start_pos = 0
         THEN
            RETURN NULL;
         ELSE
            start_pos   := start_pos + LENGTH (delim);
         END IF;
      END IF;

      end_pos     :=
         INSTR (the_list
               ,delim
               ,start_pos
               ,1);

      IF end_pos = 0
      THEN
         RETURN SUBSTR ( the_list, start_pos);
      ELSE
         RETURN SUBSTR ( the_list, start_pos, end_pos - start_pos);
      END IF;
   END get_token;

   FUNCTION authorization_header (p_consumer_key   IN VARCHAR2
                                 ,p_token          IN VARCHAR2
                                 ,p_timestamp      IN VARCHAR2
                                 ,p_nonce          IN VARCHAR2
                                 ,p_signature      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_authorization_header             VARCHAR2 (4000);
   BEGIN
      v_authorization_header :=
            'OAuth realm="",oauth_version="1.0",oauth_consumer_key="'
         || p_consumer_key
         || '",oauth_token="'
         || p_token
         || '",oauth_timestamp="'
         || p_timestamp
         || '",oauth_nonce="'
         || p_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (p_signature)
         || '"';
      RETURN v_authorization_header;
   END authorization_header;

   FUNCTION authorization_header_token_ver (p_consumer_key   IN VARCHAR2
                                           ,p_token          IN VARCHAR2
                                           ,p_verifier       IN VARCHAR2
                                           ,p_timestamp      IN VARCHAR2
                                           ,p_nonce          IN VARCHAR2
                                           ,p_signature      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_authorization_header             VARCHAR2 (4000);
   BEGIN
      v_authorization_header :=
            'OAuth oauth_verifier="'
         || p_verifier
         || '",realm="",oauth_version="1.0",oauth_consumer_key="'
         || p_consumer_key
         || '",oauth_token="'
         || p_token
         || '",oauth_timestamp="'
         || p_timestamp
         || '",oauth_nonce="'
         || p_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (p_signature)
         || '"';
      RETURN v_authorization_header;
   END authorization_header_token_ver;

   FUNCTION authorization_header_no_token (p_consumer_key   IN VARCHAR2
                                          ,p_timestamp      IN VARCHAR2
                                          ,p_nonce          IN VARCHAR2
                                          ,p_signature      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_authorization_header             VARCHAR2 (4000);
   BEGIN
      v_authorization_header :=
            'OAuth realm="",oauth_callback="oob",oauth_version="1.0",oauth_consumer_key="'
         || p_consumer_key
         || '",oauth_timestamp="'
         || p_timestamp
         || '",oauth_nonce="'
         || p_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (p_signature)
         || '"';
      RETURN v_authorization_header;
   END authorization_header_no_token;

   FUNCTION authorization_header_callback (p_callback_url   IN VARCHAR2
                                          ,p_consumer_key   IN VARCHAR2
                                          ,p_timestamp      IN VARCHAR2
                                          ,p_nonce          IN VARCHAR2
                                          ,p_signature      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_authorization_header             VARCHAR2 (4000);
   BEGIN
      v_authorization_header :=
            'OAuth realm="",oauth_callback="'
         || p_callback_url
         || '",oauth_version="1.0",oauth_consumer_key="'
         || p_consumer_key
         || '",oauth_timestamp="'
         || p_timestamp
         || '",oauth_nonce="'
         || p_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (p_signature)
         || '"';
      RETURN v_authorization_header;
   END authorization_header_callback;

   FUNCTION urlencode (p_str IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_tmp                              VARCHAR2 (32767);
      l_bad                              VARCHAR2 (100) DEFAULT '(),>%}\];?@&<#{|^[`/:=$+''"';
      l_char                             CHAR (1);
   BEGIN
      FOR i IN 1 .. NVL (LENGTH (p_str), 0)
      LOOP
         l_char      := SUBSTR ( p_str, i, 1);

         IF (INSTR ( l_bad, l_char) > 0)
         THEN
            l_tmp       := l_tmp || '%' || TO_CHAR ( ASCII (l_char), 'fmXX');
         ELSE
            l_tmp       := l_tmp || l_char;
         END IF;
      END LOOP;

      RETURN l_tmp;
   END urlencode;

FUNCTION urldecode (p_str IN VARCHAR2)
   RETURN VARCHAR2
IS
   /* Declare */
   l_hex                              VARCHAR2 (16) := '0123456789ABCDEF';
   l_idx                              NUMBER := 0;
   l_ret                              LONG := p_str;
BEGIN
   IF p_str IS NULL
   THEN
      RETURN p_str;
   END IF;

   LOOP
      l_idx       := INSTR ( l_ret, '%', l_idx + 1);
      EXIT WHEN l_idx = 0;
      l_ret       :=
         SUBSTR ( l_ret, 1, l_idx - 1)
         || CHR (
                 (INSTR ( l_hex, SUBSTR ( l_ret, l_idx + 1, 1)) - 1) * 16
               + INSTR ( l_hex, SUBSTR ( l_ret, l_idx + 2, 1))
               - 1)
         || SUBSTR ( l_ret, l_idx + 3);
   END LOOP;

   RETURN l_ret;
END urldecode;

   PROCEDURE linking_by_the_pl (p_status IN VARCHAR2)
   AS
      http_method               CONSTANT VARCHAR2 (5) := 'PUT';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/current-status';
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
      var_http_authorization_header      VARCHAR2 (1024);
      v_user_params                      VARCHAR2 (1024)
         := '<?xml version="1.0" encoding="UTF-8"?><current-status>' || (p_status) || '</current-status>';
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      UTL_HTTP.set_proxy ('10.234.23.117:8080');
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);

      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = 'davidem@hotmail.com';

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - 6000)
        INTO oauth_timestamp
        FROM DUAL;

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method
                                               ,oauth_api_url
                                               ,oauth_consumer_key
                                               ,oauth_timestamp
                                               ,oauth_nonce
                                               ,oauth_access_token);
      oauth_signature := signature ( oauth_base_string, key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
         http_req_url_access_token (oauth_api_url
                                   ,oauth_consumer_key
                                   ,oauth_timestamp
                                   ,oauth_nonce
                                   ,oauth_signature
                                   ,oauth_access_token);
      var_http_authorization_header :=
         authorization_header (oauth_consumer_key
                              ,oauth_access_token
                              ,oauth_timestamp
                              ,oauth_nonce
                              ,oauth_signature);
      http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);
      UTL_HTTP.set_body_charset ( http_req, 'UTF-8');
      UTL_HTTP.set_header ( http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
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

      --IF show_header = 1
      --THEN
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

      --END IF;

      BEGIN
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
      DBMS_OUTPUT.put_line ('finito');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END linking_by_the_pl;

   PROCEDURE get_connections
   AS
      http_method               CONSTANT VARCHAR2 (5) := 'GET';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/connections';
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
      var_http_authorization_header      VARCHAR2 (1024);
      v_user_params                      VARCHAR2 (2048);
      --         := '<?xml version="1.0" encoding="UTF-8"?><current-status>' || (p_status) || '</current-status>';
      --      xml_body                           XMLTYPE
      --         := xmltype (
      --               '<?xml version="1.0" encoding="UTF-8"?>
      --                    <share>
      --                      <comment>83% of employers will use social media to hire: 78% LinkedIn, 55% Facebook, 45% Twitter [SF Biz Times] http://bit.ly/cCpeOD</comment>
      --                      <content>
      --                         <title>Survey: Social networks top hiring tool - San Francisco Business Times</title>
      --                         <submitted-url>http://sanfrancisco.bizjournals.com/sanfrancisco/stories/2010/06/28/daily34.html</submitted-url>
      --                         <submitted-image-url>http://images.bizjournals.com/travel/cityscapes/thumbs/sm_sanfrancisco.jpg</submitted-image-url>
      --                      </content>
      --                      <visibility>
      --                         <code>connections-only</code>
      --                      </visibility>
      --                    </share>');
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      --v_user_params := xml_body.getclobval ();
      UTL_HTTP.set_proxy ('10.234.23.117:8080');
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);

      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = 'davidem@hotmail.com';

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - 6000)
        INTO oauth_timestamp
        FROM DUAL;

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method
                                               ,oauth_api_url
                                               ,oauth_consumer_key
                                               ,oauth_timestamp
                                               ,oauth_nonce
                                               ,oauth_access_token);
      oauth_signature := signature ( oauth_base_string, key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
         http_req_url_access_token (oauth_api_url
                                   ,oauth_consumer_key
                                   ,oauth_timestamp
                                   ,oauth_nonce
                                   ,oauth_signature
                                   ,oauth_access_token);
      var_http_authorization_header :=
         authorization_header (oauth_consumer_key
                              ,oauth_access_token
                              ,oauth_timestamp
                              ,oauth_nonce
                              ,oauth_signature);
      http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);
      UTL_HTTP.set_body_charset ( http_req, 'UTF-8');
      UTL_HTTP.set_header ( http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      --UTL_HTTP.write_text ( http_req, v_user_params);
      DBMS_OUTPUT.put_line ('oauth_consumer_key=' || oauth_consumer_key);
      DBMS_OUTPUT.put_line ('oauth_timestamp=' || oauth_timestamp);
      DBMS_OUTPUT.put_line ('oauth_nonce=' || oauth_nonce);
      DBMS_OUTPUT.put_line ('oauth_consumer_secret=' || oauth_consumer_secret);
      DBMS_OUTPUT.put_line ('oauth_access_token=' || oauth_access_token);
      DBMS_OUTPUT.put_line ('oauth_access_token_secret=' || oauth_access_token_secret);
      DBMS_OUTPUT.put_line ('oauth_base_string=' || oauth_base_string);
      DBMS_OUTPUT.put_line ('oauth_signature=' || oauth_signature);
      DBMS_OUTPUT.put_line ('v_user_params=' || v_user_params);

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

      DBMS_OUTPUT.put_line ('finito');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END get_connections;

   PROCEDURE get_jobs
   AS
      http_method               CONSTANT VARCHAR2 (5) := 'GET';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/job-search';
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
      var_http_authorization_header      VARCHAR2 (1024);
      v_user_params                      VARCHAR2 (2048) := 'keywords=Microstrategy';
      --         := '<?xml version="1.0" encoding="UTF-8"?><current-status>' || (p_status) || '</current-status>';
      --      xml_body                           XMLTYPE
      --         := xmltype (
      --               '<?xml version="1.0" encoding="UTF-8"?>
      --                    <share>
      --                      <comment>83% of employers will use social media to hire: 78% LinkedIn, 55% Facebook, 45% Twitter [SF Biz Times] http://bit.ly/cCpeOD</comment>
      --                      <content>
      --                         <title>Survey: Social networks top hiring tool - San Francisco Business Times</title>
      --                         <submitted-url>http://sanfrancisco.bizjournals.com/sanfrancisco/stories/2010/06/28/daily34.html</submitted-url>
      --                         <submitted-image-url>http://images.bizjournals.com/travel/cityscapes/thumbs/sm_sanfrancisco.jpg</submitted-image-url>
      --                      </content>
      --                      <visibility>
      --                         <code>connections-only</code>
      --                      </visibility>
      --                    </share>');
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      --v_user_params := xml_body.getclobval ();
      UTL_HTTP.set_proxy ('10.234.23.117:8080');
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);

      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = 'davidem@hotmail.com';

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - 6000)
        INTO oauth_timestamp
        FROM DUAL;

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method
                                               ,oauth_api_url
                                               ,oauth_consumer_key
                                               ,oauth_timestamp
                                               ,oauth_nonce
                                               ,oauth_access_token);
      oauth_signature := signature ( oauth_base_string, key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
         http_req_url_access_token (oauth_api_url
                                   ,oauth_consumer_key
                                   ,oauth_timestamp
                                   ,oauth_nonce
                                   ,oauth_signature
                                   ,oauth_access_token);
      var_http_authorization_header :=
         authorization_header (oauth_consumer_key
                              ,oauth_access_token
                              ,oauth_timestamp
                              ,oauth_nonce
                              ,oauth_signature);
      http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);
      UTL_HTTP.set_body_charset ( http_req, 'UTF-8');
      UTL_HTTP.set_header ( http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      --UTL_HTTP.write_text ( http_req, v_user_params);
      DBMS_OUTPUT.put_line ('oauth_consumer_key=' || oauth_consumer_key);
      DBMS_OUTPUT.put_line ('oauth_timestamp=' || oauth_timestamp);
      DBMS_OUTPUT.put_line ('oauth_nonce=' || oauth_nonce);
      DBMS_OUTPUT.put_line ('oauth_consumer_secret=' || oauth_consumer_secret);
      DBMS_OUTPUT.put_line ('oauth_access_token=' || oauth_access_token);
      DBMS_OUTPUT.put_line ('oauth_access_token_secret=' || oauth_access_token_secret);
      DBMS_OUTPUT.put_line ('oauth_base_string=' || oauth_base_string);
      DBMS_OUTPUT.put_line ('oauth_signature=' || oauth_signature);
      DBMS_OUTPUT.put_line ('v_user_params=' || v_user_params);

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

      DBMS_OUTPUT.put_line ('finito');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END get_jobs;

   PROCEDURE create_share
   AS
      http_method               CONSTANT VARCHAR2 (5) := 'POST';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/shares';
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
      var_http_authorization_header      VARCHAR2 (1024);
      v_user_params                      VARCHAR2 (2048)
         := '<?xml version="1.0" encoding="UTF-8"?>

                          <share>

                            <comment>Dilbert strip ' || TO_CHAR ( SYSDATE, 'Month, DD')
            || '</comment>

                            <content>

                               <title>Read the latest Dilbert strip</title>

                               <submitted-url>http://dilbert.com/dyn/str_strip/000000000/00000000/0000000/100000/20000/9000/000/129084/129084.strip.gif</submitted-url>

                               <submitted-image-url>http://dilbert.com/dyn/str_strip/000000000/00000000/0000000/100000/20000/9000/000/129084/129084.strip.gif</submitted-image-url>

                               <description>via Oracle Linkedin connector</description>

                            </content>

                            <visibility>

                               <code>connections-only</code>

                            </visibility>

                          </share>';
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      UTL_HTTP.set_proxy (PQ_CONSTANTS.con_str_http_proxy);
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);

      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = 'davidem@hotmail.com';

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - 6000)
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
      oauth_signature := signature ( oauth_base_string, key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
         http_req_url_access_token (oauth_api_url
                                   ,oauth_consumer_key
                                   ,oauth_timestamp
                                   ,oauth_nonce
                                   ,oauth_signature
                                   ,oauth_access_token);
      var_http_authorization_header :=
         authorization_header (oauth_consumer_key
                              ,oauth_access_token
                              ,oauth_timestamp
                              ,oauth_nonce
                              ,oauth_signature);
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

      DBMS_OUTPUT.put_line ('finito');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END create_share;

   PROCEDURE share_latest_dilbert (p_gif_url IN VARCHAR2)
   AS
      http_method               CONSTANT VARCHAR2 (5) := 'POST';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/shares';
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
      var_http_authorization_header      VARCHAR2 (1024);
      v_user_params                      VARCHAR2 (2048)
         :=    '<?xml version="1.0" encoding="UTF-8"?>

                          <share>

                            <comment>Dilbert strip '
            || TO_CHAR ( SYSDATE, 'Month, DD')
            || '</comment>

                            <content>

                               <title>Read the latest Dilbert strip</title>

                               <submitted-url>'
            || p_gif_url
            || '</submitted-url>

                               <submitted-image-url>'
            || p_gif_url
            || '</submitted-image-url>

                               <description>via Oracle Linkedin connector</description>

                            </content>

                            <visibility>

                               <code>connections-only</code>

                            </visibility>

                          </share>';
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      UTL_HTTP.set_proxy (PQ_CONSTANTS.con_str_http_proxy);
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (TRUE);
      UTL_HTTP.set_detailed_excp_support (TRUE);

      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = 'davidem@hotmail.com';

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - 6000)
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
      oauth_signature := signature ( oauth_base_string, key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
         http_req_url_access_token (oauth_api_url
                                   ,oauth_consumer_key
                                   ,oauth_timestamp
                                   ,oauth_nonce
                                   ,oauth_signature
                                   ,oauth_access_token);
      var_http_authorization_header :=
         authorization_header (oauth_consumer_key
                              ,oauth_access_token
                              ,oauth_timestamp
                              ,oauth_nonce
                              ,oauth_signature);
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

      DBMS_OUTPUT.put_line ('finito');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END share_latest_dilbert;

   PROCEDURE statusoftheday
   IS
      var_http_request                   UTL_HTTP.req;
      var_http_response                  UTL_HTTP.resp;
      var_http_value                     VARCHAR2 (32767);
      var_http_xml_result                VARCHAR2 (32767);
      var_http_xml                       XMLTYPE;
      tweet_string                       VARCHAR2 (140);
   BEGIN
      UTL_HTTP.set_proxy ('10.234.23.117:8080');
      --var_http_request := UTL_HTTP.begin_request (url => 'http://feeds.feedburner.com/brainyquote/QUOTENA', method => 'GET');
      var_http_request := UTL_HTTP.begin_request ( url => 'http://www.quotationspage.com/data/qotd.rss', method => 'GET');
      UTL_HTTP.set_header ( var_http_request, 'User-Agent', 'Mozilla/4.0');
      var_http_response := UTL_HTTP.get_response (r => var_http_request);

      BEGIN
         LOOP
            UTL_HTTP.read_line ( r => var_http_response, DATA => var_http_value, remove_crlf => TRUE);
            var_http_xml_result := var_http_xml_result || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => var_http_response);
      END;

      var_http_xml := XMLTYPE (var_http_xml_result);

      UPDATE log_http
         SET entry        = var_http_xml;

      COMMIT;

      SELECT    REPLACE ( REGEXP_SUBSTR ( EXTRACTVALUE ( a.entry, '/rss/channel/item[1]/description'), '"(.*?)"'), '"')
             || ' - '
             || REPLACE ( EXTRACTVALUE ( a.entry, '/rss/channel/item[1]/title'), '"')
        INTO tweet_string
        FROM log_http a;

      linking_by_the_pl (tweet_string);
   END statusoftheday;

   PROCEDURE SendErrorOutput ( p_SQLERRM IN VARCHAR2, p_error_backtrace IN VARCHAR2)
   IS
   BEGIN
      OWA_UTIL.mime_header ( 'text/html', TRUE, 'utf-8');
      HTP.p (
         '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
      HTP.p ('<html xmlns="http://www.w3.org/1999/xhtml">');
      HTP.p ('<head>');
      HTP.p ('<link rel="Stylesheet" href="/public/css/canvas.css" type="text/css" />');
      HTP.p ('</head>');
      HTP.p ('<body>');
      HTP.p ('<div class="StatusBar">');
      HTP.p (p_SQLERRM);
      HTP.p ('<br>' || p_error_backtrace);
      HTP.p ('</div>');
      HTP.p ('</body>');
      HTP.p ('</html>');
   END SendErrorOutput;
END utl_linkedin;
/
