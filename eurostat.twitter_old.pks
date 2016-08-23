DROP PACKAGE TWITTER_OLD;

CREATE OR REPLACE PACKAGE          twitter_old
AS
   http_req    UTL_HTTP.req;
   http_resp   UTL_HTTP.resp;

   PROCEDURE update_status (
      p_status    IN VARCHAR2:= 'TEST h. ' || TO_CHAR (SYSDATE, 'HH24:MI:SS'),
      p_account   IN VARCHAR2:= 'EuroStrategy');

   FUNCTION urlencode (p_str IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION base_string_access_token (
      p_http_method         IN VARCHAR2,
      p_request_token_url   IN VARCHAR2,
      p_consumer_key        IN VARCHAR2,
      p_timestamp           IN VARCHAR2:= TO_CHAR (
      (SYSDATE - TO_DATE ('01-01-1970', 'DD-MM-YYYY')) * (86400)
      - (TO_NUMBER (SUBSTR (SESSIONTIMEZONE, 2, 2)) * 3600)),
      p_nonce               IN VARCHAR2,
      p_token               IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION signature (p_oauth_base_string   IN VARCHAR2,
                       p_oauth_key           IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION key_token (p_consumer_secret   IN VARCHAR2,
                       p_token_secret      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION auth_header (p_consumer_key   IN VARCHAR2,
                         p_token          IN VARCHAR2,
                         p_timestamp      IN VARCHAR2,
                         p_nonce          IN VARCHAR2,
                         p_signature      IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE show_resp_header (p_resp IN UTL_HTTP.resp);

   PROCEDURE show_resp_content (p_resp IN UTL_HTTP.resp);

   FUNCTION calculate_timestamp
      RETURN VARCHAR2;
END twitter_old;
/
