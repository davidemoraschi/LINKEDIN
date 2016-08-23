DROP PACKAGE BODY OBJ_GOOG_REQUEST_TOKEN;

CREATE OR REPLACE PACKAGE BODY          obj_goog_request_token
AS
   PROCEDURE jsp
   IS
      l_obj_google            google;
      con_str_hostname_port   CONSTANT VARCHAR2 (1024) := 'http://localhost:1592';
      con_str_dad_name        CONSTANT VARCHAR2 (1024) := '/sso/';
   BEGIN
      l_obj_google :=
         NEW google (
                id                      => 'google',
                oauth_consumer_key      => 'moraschi.eu',
                oauth_consumer_secret   => '_7bPH3TvV2OoIbwJ1_8XAnDQ',
                oauth_callback          => 'http://moraschi.eu:8081/sso/' || 'obj_goog_request_token_cb.jsp',
                google_scope            => 'https://www.googleapis.com/auth/analytics.readonly');

      l_obj_google.save;
      HTP.
      p (
            '<script type="text/javascript">window.location = "'
         || l_obj_google.oauth_api_authorization_url
         || '"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_goog_request_token;
/
