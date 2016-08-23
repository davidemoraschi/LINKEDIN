DROP PACKAGE BODY OBJ_LNKD_REQUEST_TOKEN;

CREATE OR REPLACE PACKAGE BODY          obj_lnkd_request_token
AS
   PROCEDURE jsp
   IS
      l_obj_linkedin          linkedin;
      con_str_hostname_port   CONSTANT VARCHAR2 (1024) := pq_constants.con_str_hostname_port;
      con_str_dad_name        CONSTANT VARCHAR2 (1024) := '/sso/';
   BEGIN
      l_obj_linkedin :=
         NEW linkedin (
                id                      => 'test3',
                oauth_consumer_key      => 'efZ12YIp1CcRr4zhXtt_UxefWEXqXSDqYbVPBZ0vPR1CfCiNU_BmrD_flPKErVkt',
                oauth_consumer_secret   => 'BxTKKA1dAb2lXz-D3W273TrEGBHXs6EWO2E54rNF3S0CGVrCMcX4K_P7V6fHPrv8',
                oauth_callback          => con_str_hostname_port || con_str_dad_name || 'obj_lnkd_request_token_cb.jsp');

      l_obj_linkedin.save;
      HTP.
      p (
            '<script type="text/javascript">window.location = "'
         || l_obj_linkedin.oauth_api_authorization_url
         || '"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_lnkd_request_token;
/
