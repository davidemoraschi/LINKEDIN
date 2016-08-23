DROP PROCEDURE REQUEST_TOKEN_CALLBACK;

CREATE OR REPLACE PROCEDURE          request_token_callback ( oauth_token IN VARCHAR2 := NULL, oauth_verifier IN VARCHAR2 := NULL, oauth_problem IN VARCHAR2 := NULL)
IS
   http_method               CONSTANT VARCHAR2 (5) := 'POST';
   http_req                           UTL_HTTP.req;
   http_resp                          UTL_HTTP.resp;
   oauth_api_url                      VARCHAR2 (1000) := 'https://api.linkedin.com/uas/oauth/accessToken';
   oauth_consumer_key                 VARCHAR2 (500);
   oauth_consumer_secret              VARCHAR2 (500);
   oauth_access_token_secret          VARCHAR2 (500);
   oauth_nonce                        VARCHAR2 (50);
   oauth_timestamp                    VARCHAR2 (50);
   oauth_base_string                  VARCHAR2 (1000);
   oauth_signature                    VARCHAR2 (100);
   var_http_authorization_header      VARCHAR2 (4096);
   var_http_header_name               VARCHAR2 (255);
   var_http_header_value              VARCHAR2 (1023);
   var_http_resp_value                VARCHAR2 (32767);
   l_list                             parse.items_tt;
   oauth_access_token                 parse.items_tt;
   oauth_token_secret                 parse.items_tt;
   v_oauth_token                      OWA_COOKIE.cookie;
   v_oauth_verifier                   OWA_COOKIE.cookie;
   b_DEBUG                            BOOLEAN := FALSE;
BEGIN
   IF oauth_problem = 'user_refused'
   THEN
      HTP.p ('You must allow access to this application log in...');
   ELSE
      EXECUTE IMMEDIATE 'SELECT OAUTH_TOKEN_SECRET        
        FROM OAUTH_LINKEDIN_PARAMETERS
       WHERE OAUTH_TOKEN LIKE TRIM (''' || oauth_token || ''')' INTO oauth_access_token_secret;
      EXECUTE IMMEDIATE
            'UPDATE OAUTH_LINKEDIN_PARAMETERS
               SET OAUTH_VERIFIER = '
         || TRIM (oauth_verifier)
         || ' WHERE OAUTH_TOKEN LIKE TRIM ('''
         || oauth_token
         || ''')';
      COMMIT;
      IF b_DEBUG
      THEN
         HTP.p ('<table border="1">');
      END IF;
   /*
         OWA_UTIL.mime_header ( 'text/html', FALSE);
         --OWA_COOKIE.send ( 'city', 'BOSTON');
         OWA_COOKIE.send ( 'oauth_token', oauth_token);
         OWA_COOKIE.send ( 'oauth_verifier', oauth_verifier);
         OWA_UTIL.http_header_close;
         HTP.p (
            '<img title="Log in with LinkedIn account" src="http://www.yourbalance.com.au/wp-content/uploads/2010/07/log-in-linkedin-large.png" onclick="alert(''login'')">');
         v_oauth_token := OWA_COOKIE.get ('oauth_token');
         IF v_oauth_token.num_vals = 0
         THEN
            HTP.PRINT ('<h1>oauth_token cookie not found!</h1>');
         ELSE
            FOR i IN 1 .. v_oauth_token.num_vals
            LOOP
               HTP.PRINT ('oauth_token: ' || v_oauth_token.vals (i));
            END LOOP;
         END IF;
         v_oauth_verifier := OWA_COOKIE.get ('oauth_verifier');
         IF v_oauth_verifier.num_vals = 0
         THEN
            HTP.PRINT ('<h1>oauth_verifier cookie not found!</h1>');
         ELSE
            FOR i IN 1 .. v_oauth_verifier.num_vals
            LOOP
               HTP.PRINT ('oauth_verifier: ' || v_oauth_verifier.vals (i));
            END LOOP;
         END IF;
      --HTP.p ('oauth_token: ' || v_oauth_token.vals(1));
      --HTP.p ('oauth_verifier: ' || v_oauth_verifier.vals(1));
      */
   SELECT oauth_consumer_key, oauth_consumer_secret
     INTO oauth_consumer_key, oauth_consumer_secret
     FROM oauth_linkedin_parameters
    WHERE account = 'eurostat.microstrategy@gmail.com';
   SELECT utl_linkedin.urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;
   SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400)) INTO oauth_timestamp FROM DUAL;
   oauth_base_string :=
      utl_linkedin.base_string_token (http_method
                                     ,oauth_api_url
                                     ,oauth_consumer_key
                                     ,oauth_timestamp
                                     ,oauth_nonce
                                     ,oauth_token
                                     ,oauth_verifier);
   oauth_signature := utl_linkedin.signature ( oauth_base_string, utl_linkedin.key_token ( oauth_consumer_secret, oauth_access_token_secret));
   var_http_authorization_header :=
      utl_linkedin.authorization_header_token_ver (oauth_consumer_key
                                                  ,oauth_token
                                                  ,oauth_verifier
                                                  ,oauth_timestamp
                                                  ,oauth_nonce
                                                  ,oauth_signature);
 --  UTL_HTTP.set_proxy (PQ_CONSTANTS.con_str_http_proxy);
   UTL_HTTP.set_wallet ( PATH => PQ_CONSTANTS.con_str_wallet_path, PASSWORD => PQ_CONSTANTS.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);
   http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
   UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
   UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'text/xml');
   IF b_DEBUG
   THEN
      HTP.p ('<tr><td><b>oauth_consumer_key: </b>' || oauth_consumer_key || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_consumer_secret: </b>' || oauth_consumer_secret || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_token: </b>' || oauth_token || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_access_token_secret: </b>' || oauth_access_token_secret || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_nonce: </b>' || oauth_nonce || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_timestamp: </b>' || oauth_timestamp || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_verifier: </b>' || oauth_verifier || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_base_string: </b>' || oauth_base_string || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_signature: </b>' || oauth_signature || '</td></tr>');
      HTP.p ('<tr><td><b>authorization_header: </b>' || var_http_authorization_header || '</td></tr>');
      HTP.p ('<tr><td>&nbsp;</td></tr>');
   END IF;
   http_resp   := UTL_HTTP.get_response (http_req);
   IF b_DEBUG
   THEN
      HTP.p ('<tr><td><b>status code: </b>' || http_resp.status_code || '</td></tr>');
      HTP.p ('<tr><td><b>reason phrase: </b>' || http_resp.reason_phrase || '</td></tr>');
      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp
                             ,i
                             ,var_http_header_name
                             ,var_http_header_value);
         HTP.p ('<tr><td><b>' || var_http_header_name || ': </b>' || var_http_header_value || '</td></tr>');
      END LOOP;
      HTP.p ('<tr><td>&nbsp;</td></tr>');
   END IF;
   BEGIN
      WHILE TRUE
      LOOP
         UTL_HTTP.read_line ( http_resp, var_http_resp_value, TRUE);
         l_list      := parse.string_to_list ( var_http_resp_value, '&');
         IF b_DEBUG
         THEN
            FOR i IN 1 .. l_list.COUNT
            LOOP
               HTP.p ('<tr><td>' || l_list (i) || '</td></tr>');
            END LOOP;
         END IF;
         oauth_access_token := parse.string_to_list ( l_list (1), '=');
         oauth_token_secret := parse.string_to_list ( l_list (2), '=');
      --HTP.p ('<tr><td><b>request token: </b>' || oauth_request_token (2) || '</td></tr>');
      --HTP.p ('<tr><td><b>redirect url: </b>' || urldecode (oauth_redirect_url (2)) || '</td></tr>');
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;
   --   /*
   --   <script type="text/javascript">
   --   <!--
   --   window.location = "http://www.google.com/"
   --   //-->
   --   </script>
   --   */
   --
   IF b_DEBUG
   THEN
      HTP.p ('</table>');
   END IF;
   --   HTP.p (
   --         '<input type="button" value="Click Here" onClick="window.location='''
   --      || urldecode (oauth_redirect_url (2))
   --      || '?oauth_token='
   --      || oauth_request_token (2)
   --      || ''';">');
   --
   UTL_HTTP.end_response (http_resp);
   OWA_UTIL.mime_header ( 'text/html', FALSE);
   OWA_COOKIE.send ( 'oauth_access_token', oauth_access_token (2));
   OWA_COOKIE.send ( 'oauth_token_secret', oauth_token_secret (2));
   OWA_UTIL.http_header_close;
   HTP.p ('<script type="text/javascript">window.location = "' || 'http://moraschi.eu/sso/jsp/doLogin.jsp?token=' ||oauth_access_token (2)|| '"</script>');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      utl_linkedin.SendErrorOutput ( SQLERRM, DBMS_UTILITY.format_error_backtrace);
END request_token_callback;
/
