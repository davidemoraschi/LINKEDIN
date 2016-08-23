DROP PACKAGE BODY OBJ_DRBX_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE BODY          obj_drbx_request_token_cb
AS
   PROCEDURE jsp (oauth_token IN VARCHAR2 := NULL, UID IN VARCHAR2 := NULL)
   IS
      v_obj_dropbox               dropbox;
      p_credentials_in_response   CLOB;
      p_credentials_json          json;
      l_xml_profile               XMLTYPE;
   --v_json_responseobj json
   BEGIN
      IF oauth_token IS NULL
      THEN
         HTP.P ('token invalid');
         RETURN;
      ELSE
         --HTP.P (oauth_token);

         SELECT (obj_dropbox)
           INTO v_obj_dropbox
           FROM objs_dropbox
          WHERE account = oauth_token;

         v_obj_dropbox.oauth_request_token := oauth_token;
         --v_obj_dropbox.oauth_verifier := UID;
         v_obj_dropbox.SAVE;
         v_obj_dropbox.upgrade_token;
         v_obj_dropbox.SAVE;
         v_obj_dropbox.get_account_info (p_credentials_in_response => p_credentials_in_response);
         p_credentials_json := json (p_credentials_in_response);
         l_xml_profile := json_xml.json_to_xml (p_credentials_json);
         --HTP.P (p_credentials_xml.getclobval ());

         HTP.p (l_xml_profile.EXTRACT ('/root/uid').getstringval ());
         HTP.p (l_xml_profile.EXTRACT ('/root/display_name').getstringval ());
         v_obj_dropbox.id := l_xml_profile.EXTRACT ('/root/uid/text()').getstringval ();
         v_obj_dropbox.save;

         DELETE objs_dropbox
          WHERE account = oauth_token;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_drbx_request_token_cb;
/
