DROP PACKAGE BODY OBJ_GOOG_OAUTH2_AUTH;

CREATE OR REPLACE PACKAGE BODY          obj_goog_oauth2_auth
AS
   PROCEDURE jsp (state IN VARCHAR2)
   IS
      v_access_token   objs_google_analytics.access_token%TYPE;
   BEGIN
      BEGIN
         SELECT access_token
           INTO v_access_token
           FROM objs_google_analytics
          WHERE account = state;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT INTO objs_google_analytics (account)
                 VALUES (state);
      END;

      COMMIT;

      IF v_access_token IS NULL
      THEN
         HTP.
         p (
               '<script type="text/javascript">window.location = "'
            || con_str_goog_auth_endpoint
            || '?response_type=code'
            || '&client_id='
            || con_str_goog_client_id
            || '&scope='
            || con_str_goog_auth_scope
            || '&redirect_uri='
            || con_str_mstr_auth_callback
            || '&access_type=online'
            || '&approval_prompt=auto'
            || '&state='
            || state
            || '"</script>');
      ELSE
         HTP.
         p (
            '<script type="text/javascript">window.location = "http://moraschi.eu:8081/sso/obj_goog_oauth2_datafeed.jsp?state='
            || state
            --         || '&access_token='
            --         || access_token
            --         || '&token_type='
            --         || token_type
            --         || '&profile_id='
            --         || REPLACE (l_xml.EXTRACT ('/root/items[1]/id/text()').getstringval (), '&quot;', '')
            || '"</script>');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END obj_goog_oauth2_auth;
/
