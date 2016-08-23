DROP PACKAGE BODY OBJ_GOOG_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE BODY          obj_goog_request_token_cb
AS
   PROCEDURE jsp (oauth_verifier IN VARCHAR2 := NULL, oauth_token IN VARCHAR2 := NULL)
   IS
      l_obj_google   google;
   --      con_str_hostname_port   CONSTANT VARCHAR2 (1024) := 'http://localhost:1592';
   --      con_str_dad_name        CONSTANT VARCHAR2 (1024) := '/sso/';
   BEGIN
      /*         SELECT (obj_google)
                 INTO l_obj_google
                 FROM objs_google
                WHERE account = oauth_token;*/
      HTP.p ('['||urlencode(oauth_token) || '] under construction...');
      EXECUTE IMMEDIATE 'SELECT (obj_google)
          FROM objs_google
           WHERE account LIKE TRIM (''' || urlencode(oauth_token) || ''')' INTO l_obj_google;


      --      l_obj_google :=
      --         NEW google (
      --                id                      => 'google',
      --                oauth_consumer_key      => 'moraschi.eu',
      --                oauth_consumer_secret   => '_7bPH3TvV2OoIbwJ1_8XAnDQ',
      --                oauth_callback          => con_str_hostname_port || con_str_dad_name || 'obj_goog_request_token_cb.jsp',
      --                google_scope            => 'https://www.google.com/calendar/feeds/');

      l_obj_google.oauth_verifier := oauth_verifier;
      l_obj_google.save;
      l_obj_google.upgrade_token;
      l_obj_google.save;

   --      p (
   --            '<script type="text/javascript">window.location = "'
   --         || l_obj_google.oauth_api_authorization_url
   --         || '"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_goog_request_token_cb;
/
