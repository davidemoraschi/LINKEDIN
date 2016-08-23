DROP PACKAGE BODY OBJ_TWIT_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE BODY          obj_twit_request_token_cb
AS
   PROCEDURE jsp (oauth_token IN VARCHAR2 := NULL, oauth_verifier IN VARCHAR2 := NULL, denied IN VARCHAR2 := NULL)
   IS
      v_obj_twitter   twitter;
      l_xml_profile   XMLTYPE;
   BEGIN
      IF denied IS NOT NULL
      THEN
         HTP.p ('user denied access');
         RETURN;
      END IF;

      IF oauth_token IS NULL
      THEN
         HTP.p ('token invalid');
         RETURN;
      ELSE
         SELECT (obj_twitter)
           INTO v_obj_twitter
           FROM objs_twitter
          WHERE account = oauth_token;

         v_obj_twitter.oauth_verifier := oauth_verifier;
         v_obj_twitter.save;
         v_obj_twitter.upgrade_token;
         v_obj_twitter.save;
         --   HTP.p (v_obj_linkedin.oauth_access_token_secret);
         v_obj_twitter.get_account (p_credentials_in_response => l_xml_profile);
         HTP.p (l_xml_profile.EXTRACT ('/user/id').getstringval ());
         HTP.p (l_xml_profile.EXTRACT ('/user/name').getstringval ());
         v_obj_twitter.id := l_xml_profile.EXTRACT ('/user/id/text()').getstringval ();
         v_obj_twitter.save;
         
         DELETE objs_twitter
          WHERE account = oauth_token;
         
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_twit_request_token_cb;
/
