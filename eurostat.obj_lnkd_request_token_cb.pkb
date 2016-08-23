DROP PACKAGE BODY OBJ_LNKD_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE BODY          obj_lnkd_request_token_cb
AS
   PROCEDURE jsp (oauth_token      IN VARCHAR2:= NULL,
                  oauth_verifier   IN VARCHAR2:= NULL,
                  oauth_problem    IN VARCHAR2:= NULL)
   IS
      v_obj_linkedin   linkedin;
      l_xml_profile    XMLTYPE;
   BEGIN
      IF oauth_problem IS NOT NULL
      THEN
         HTP.p (oauth_problem);
      ELSE
         IF oauth_token IS NULL
         THEN
            HTP.p ('token invalid');
            RETURN;
         ELSE
            SELECT (obj_linkedin)
              INTO v_obj_linkedin
              FROM objs_linkedin
             WHERE (obj_linkedin).oauth_request_token = oauth_token;

            v_obj_linkedin.oauth_verifier := oauth_verifier;
            v_obj_linkedin.save;
            v_obj_linkedin.upgrade_token;
            v_obj_linkedin.save;
            --   HTP.p (v_obj_linkedin.oauth_access_token_secret);
            v_obj_linkedin.get_profile (out_xml => l_xml_profile);
            HTP.p ('<script type="text/javascript">window.location = "main.jsp"</script>');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_lnkd_request_token_cb;
/
