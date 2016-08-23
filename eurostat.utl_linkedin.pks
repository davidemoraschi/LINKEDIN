DROP PACKAGE UTL_LINKEDIN;

CREATE OR REPLACE PACKAGE          utl_linkedin
AS
   consumer_key   CONSTANT VARCHAR2 (2000) := 'NHx8CZzuf9XEF6C2ksimwDkS7Fw=';

   FUNCTION base_string (p_http_method         IN VARCHAR2,
                         p_request_token_url   IN VARCHAR2,
                         p_consumer_key        IN VARCHAR2,
                         p_timestamp           IN VARCHAR2,
                         p_nonce               IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION base_string_callback (p_http_method         IN VARCHAR2,
                                  p_request_token_url   IN VARCHAR2,
                                  p_callback_url        IN VARCHAR2,
                                  p_consumer_key        IN VARCHAR2,
                                  p_timestamp           IN VARCHAR2,
                                  p_nonce               IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION base_string_token (p_http_method         IN VARCHAR2,
                               p_request_token_url   IN VARCHAR2,
                               p_consumer_key        IN VARCHAR2,
                               p_timestamp           IN VARCHAR2,
                               p_nonce               IN VARCHAR2,
                               p_token               IN VARCHAR2,
                               p_token_verifier      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION base_string_access_token (p_http_method         IN VARCHAR2,
                                      p_request_token_url   IN VARCHAR2,
                                      p_consumer_key        IN VARCHAR2,
                                      p_timestamp           IN VARCHAR2,
                                      p_nonce               IN VARCHAR2,
                                      p_token               IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION base_string_access_token_par (p_http_method         IN VARCHAR2,
                                          p_request_token_url   IN VARCHAR2,
                                          p_consumer_key        IN VARCHAR2,
                                          p_timestamp           IN VARCHAR2,
                                          p_nonce               IN VARCHAR2,
                                          p_token               IN VARCHAR2,
                                          p_par                 IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION key (p_consumer_secret IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION key_token (p_consumer_secret IN VARCHAR2, p_token_secret IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION signature (p_oauth_base_string IN VARCHAR2, p_oauth_key IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION http_req_url (p_request_token_url   IN VARCHAR2,
                          p_consumer_key        IN VARCHAR2,
                          p_timestamp           IN VARCHAR2,
                          p_nonce               IN VARCHAR2,
                          p_signature           IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION http_req_url_token (p_request_token_url   IN VARCHAR2,
                                p_consumer_key        IN VARCHAR2,
                                p_timestamp           IN VARCHAR2,
                                p_nonce               IN VARCHAR2,
                                p_signature           IN VARCHAR2,
                                p_token               IN VARCHAR2,
                                p_token_verifier      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION http_req_url_access_token (p_request_token_url   IN VARCHAR2,
                                       p_consumer_key        IN VARCHAR2,
                                       p_timestamp           IN VARCHAR2,
                                       p_nonce               IN VARCHAR2,
                                       p_signature           IN VARCHAR2,
                                       p_token               IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_token (the_list VARCHAR2, the_index NUMBER, delim VARCHAR2 := ',')
      RETURN VARCHAR2;

   FUNCTION authorization_header (p_consumer_key   IN VARCHAR2,
                                  p_token          IN VARCHAR2,
                                  p_timestamp      IN VARCHAR2,
                                  p_nonce          IN VARCHAR2,
                                  p_signature      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION authorization_header_token_ver (p_consumer_key   IN VARCHAR2,
                                            p_token          IN VARCHAR2,
                                            p_verifier       IN VARCHAR2,
                                            p_timestamp      IN VARCHAR2,
                                            p_nonce          IN VARCHAR2,
                                            p_signature      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION authorization_header_no_token (p_consumer_key   IN VARCHAR2,
                                           p_timestamp      IN VARCHAR2,
                                           p_nonce          IN VARCHAR2,
                                           p_signature      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION authorization_header_callback (p_callback_url   IN VARCHAR2,
                                           p_consumer_key   IN VARCHAR2,
                                           p_timestamp      IN VARCHAR2,
                                           p_nonce          IN VARCHAR2,
                                           p_signature      IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION urlencode (p_str IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION urldecode (p_str IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE linking_by_the_pl (p_status IN VARCHAR2);

   PROCEDURE get_connections;

   PROCEDURE get_jobs;

   PROCEDURE create_share;

   PROCEDURE share_latest_dilbert (p_gif_url IN VARCHAR2);

   PROCEDURE statusoftheday;

   PROCEDURE senderroroutput (p_sqlerrm IN VARCHAR2, p_error_backtrace IN VARCHAR2);
END utl_linkedin;
/
