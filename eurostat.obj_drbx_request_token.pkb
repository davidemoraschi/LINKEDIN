DROP PACKAGE BODY OBJ_DRBX_REQUEST_TOKEN;

CREATE OR REPLACE PACKAGE BODY          obj_drbx_request_token
AS
   PROCEDURE jsp
   IS
      l_obj_dropbox           dropbox;
      con_str_hostname_port   CONSTANT VARCHAR2 (1024) := pq_constants.con_str_hostname_port;
      con_str_dad_name        CONSTANT VARCHAR2 (1024) := '/sso/';
   BEGIN
      l_obj_dropbox :=
         NEW dropbox (
                id                      => 'EuroStrategy',
                oauth_consumer_key      => '5dlgdhkctfn4ngq',
                oauth_consumer_secret   => 'dgkduksn1pdxltm',
                oauth_callback          => con_str_hostname_port || con_str_dad_name || 'obj_drbx_request_token_cb.jsp');

      l_obj_dropbox.save;
      --HTP.p (l_obj_dropbox.oauth_api_authorization_url);
      HTP.
      p (
            '<script type="text/javascript">window.location = "'
         || l_obj_dropbox.oauth_api_authorization_url
         || '"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_drbx_request_token;
/
