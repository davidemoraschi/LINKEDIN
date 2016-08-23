DROP PACKAGE BODY OBJ_TWIT_REQUEST_TOKEN;

CREATE OR REPLACE PACKAGE BODY          obj_twit_request_token
AS
   PROCEDURE jsp
   IS
      l_obj_twitter           twitter;
      con_str_hostname_port   CONSTANT VARCHAR2 (1024) := pq_constants.con_str_hostname_port;
      con_str_dad_name        CONSTANT VARCHAR2 (1024) := '/sso/';
   BEGIN
      l_obj_twitter :=
         NEW twitter (
                id                      => 'twitter1',
                oauth_consumer_key      => 'okSQJwBryotn9GWrB1iPw',
                oauth_consumer_secret   => 'wBEulz9R5z32At7lpcfm2OivJjiiuUERkA51rPk10',
                oauth_callback          => con_str_hostname_port || con_str_dad_name || 'obj_twit_request_token_cb.jsp');

      l_obj_twitter.save;
      --HTP.p (l_obj_twitter.oauth_api_authorization_url);
      HTP.
      p (
            '<script type="text/javascript">window.location = "'
         || l_obj_twitter.oauth_api_authorization_url
         || '"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_twit_request_token;
/
