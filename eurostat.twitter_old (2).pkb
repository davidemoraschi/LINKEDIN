DROP PACKAGE BODY TWITTER_OLD;

CREATE OR REPLACE PACKAGE BODY          twitter_old
AS
   PROCEDURE update_status (p_status    IN VARCHAR2:= 'TEST h. ' || TO_CHAR (SYSDATE, 'HH24:MI:SS'),
                            p_account   IN VARCHAR2:= 'EuroStrategy')
   IS
      oauth_api_update_status_url   CONSTANT VARCHAR2 (1000) := 'http://api.twitter.com/1/statuses/update.xml';
      oauth_consumer_key            twitter_parameters.OAUTH_CONSUMER_KEY%TYPE;
      oauth_consumer_secret         twitter_parameters.OAUTH_CONSUMER_SECRET%TYPE;
      oauth_access_token            twitter_parameters.OAUTH_ACCESS_TOKEN%TYPE;
      oauth_access_token_secret     twitter_parameters.OAUTH_ACCESS_TOKEN_SECRET%TYPE;
      oauth_nonce                   VARCHAR2 (50);
      oauth_timestamp               VARCHAR2 (50);
      oauth_base_string             VARCHAR2 (1000);
      oauth_signature               VARCHAR2 (100);
      oauth_authorization_header    VARCHAR2 (1024);
      oauth_api_params              VARCHAR2 (1024) := 'status=' || urlencode (p_status);
      show_header                   NUMBER := 1;
      show_content                  NUMBER := 1;
   BEGIN
      SELECT oauth_consumer_key,
             oauth_consumer_secret,
             oauth_access_token,
             oauth_access_token_secret
        INTO oauth_consumer_key,
             oauth_consumer_secret,
             oauth_access_token,
             oauth_access_token_secret
        FROM twitter_parameters
       WHERE oauth_account = p_account;

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      oauth_timestamp := calculate_timestamp;

      oauth_base_string :=
         base_string_access_token (p_http_method         => PQ_CONSTANTS.con_str_http_POST,
                                   p_request_token_url   => oauth_api_update_status_url,
                                   p_consumer_key        => oauth_consumer_key,
                                   p_timestamp           => oauth_timestamp,
                                   p_nonce               => oauth_nonce,
                                   p_token               => oauth_access_token)
         || urlencode ('&' || oauth_api_params);
      oauth_signature :=
         signature (
            p_oauth_base_string   => oauth_base_string,
            p_oauth_key           => key_token (p_consumer_secret   => oauth_consumer_secret,
                                                p_token_secret      => oauth_access_token_secret));
      oauth_authorization_header :=
         auth_header (p_consumer_key   => oauth_consumer_key,
                      p_token          => oauth_access_token,
                      p_timestamp      => oauth_timestamp,
                      p_nonce          => oauth_nonce,
                      p_signature      => oauth_signature);

      PQ_CONSTANTS.init;
      DBMS_OUTPUT.put_line ('base string: ' || oauth_base_string);
      DBMS_OUTPUT.put_line ('signature  : ' || oauth_signature);
      DBMS_OUTPUT.put_line ('header     : ' || oauth_authorization_header);
      http_req :=
         UTL_HTTP.
         begin_request (url            => oauth_api_update_status_url,
                        method         => PQ_CONSTANTS.con_str_http_POST,
                        http_version   => UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_body_charset (r => http_req, charset => 'UTF-8');
      --UTL_HTTP.set_header (r => http_req, name => 'User-Agent', VALUE => 'Mozilla/4.0');
      UTL_HTTP.set_header (r => http_req, NAME => 'Authorization', VALUE => oauth_authorization_header);
      --UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (oauth_api_params));
      UTL_HTTP.write_text (r => http_req, data => oauth_api_params);
      http_resp := UTL_HTTP.get_response (r => http_req);

      IF show_header = 1 OR http_resp.status_code <> 200
      THEN
         show_resp_header (p_resp => http_resp);
      END IF;

      IF show_content = 1 OR http_resp.status_code <> 200
      THEN
         show_resp_content (p_resp => http_resp);
      END IF;

      UTL_HTTP.end_response (r => http_resp);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         RAISE;
   END update_status;

   FUNCTION urlencode (p_str IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_tmp    VARCHAR2 (6000);
      l_bad    VARCHAR2 (100) DEFAULT ' ,>%}\~];?@&<#{|^[`/:=$+''"';
      l_char   CHAR (1);
   BEGIN
      FOR i IN 1 .. NVL (LENGTH (p_str), 0)
      LOOP
         l_char := SUBSTR (p_str, i, 1);

         IF (INSTR (l_bad, l_char) > 0)
         THEN
            l_tmp := l_tmp || '%' || TO_CHAR (ASCII (l_char), 'fmXX');
         ELSE
            l_tmp := l_tmp || l_char;
         END IF;
      END LOOP;

      RETURN l_tmp;
   END urlencode;

   FUNCTION base_string_access_token (
      p_http_method         IN VARCHAR2,
      p_request_token_url   IN VARCHAR2,
      p_consumer_key        IN VARCHAR2,
      p_timestamp           IN VARCHAR2:= TO_CHAR (
      (SYSDATE - TO_DATE ('01-01-1970', 'DD-MM-YYYY')) * (86400) - (TO_NUMBER (SUBSTR (SESSIONTIMEZONE, 2, 2)) * 3600)),
      p_nonce               IN VARCHAR2,
      p_token               IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_base_string   VARCHAR2 (2000);
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

   FUNCTION signature (p_oauth_base_string IN VARCHAR2, p_oauth_key IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_signature   VARCHAR2 (500);
   BEGIN
      v_oauth_signature :=
         UTL_RAW.
         cast_to_varchar2 (
            UTL_ENCODE.
            base64_encode (
               DBMS_CRYPTO.
               mac (UTL_I18N.string_to_raw (p_oauth_base_string, 'AL32UTF8'),
                    DBMS_CRYPTO.hmac_sh1,
                    UTL_I18N.string_to_raw (p_oauth_key, 'AL32UTF8'))));
      RETURN v_oauth_signature;
   END signature;

   FUNCTION key_token (p_consumer_secret IN VARCHAR2, p_token_secret IN VARCHAR2)
      RETURN VARCHAR2
   AS
      v_oauth_key   VARCHAR2 (500);
   BEGIN
      SELECT urlencode (p_consumer_secret) || '&' || urlencode (p_token_secret) --gi? urlencodato
                                                                               INTO v_oauth_key FROM DUAL;

      RETURN v_oauth_key;
   END key_token;

   FUNCTION auth_header (p_consumer_key   IN VARCHAR2,
                         p_token          IN VARCHAR2,
                         p_timestamp      IN VARCHAR2,
                         p_nonce          IN VARCHAR2,
                         p_signature      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_authorization_header   VARCHAR2 (4000);
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
   END auth_header;

   PROCEDURE show_resp_header (p_resp IN UTL_HTTP.resp)
   IS
      h_name    VARCHAR2 (255);
      h_value   VARCHAR2 (1023);
   BEGIN
      DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
      DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp,
                              i,
                              h_name,
                              h_value);
         DBMS_OUTPUT.put_line (h_name || ': ' || h_value);
      END LOOP;
   END show_resp_header;

   PROCEDURE show_resp_content (p_resp IN UTL_HTTP.resp)
   IS
      res_value   VARCHAR2 (32767);
   BEGIN
      WHILE 1 = 1
      LOOP
         UTL_HTTP.read_line (http_resp, res_value, TRUE);
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END show_resp_content;

   FUNCTION calculate_timestamp
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN TO_CHAR (
                TRUNC (
                   (SYSDATE - TO_DATE ('01-01-1970', 'DD-MM-YYYY')) * (86400)
                   - (TO_NUMBER (SUBSTR (SESSIONTIMEZONE, 2, 2)) * 3600)));
   END;
END twitter_old;
/
