DROP PACKAGE BODY MSTR_LNKD_AUTHENTICATE;

CREATE OR REPLACE PACKAGE BODY          mstr_lnkd_authenticate
AS
   PROCEDURE jsp (token IN VARCHAR2 := NULL)
   IS
      oauth_api_url                   VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline)';
      http_method                     CONSTANT VARCHAR2 (5) := 'GET';
      http_req                        UTL_HTTP.req;
      http_resp                       UTL_HTTP.resp;
      oauth_consumer_key              VARCHAR2 (500);
      oauth_consumer_secret           VARCHAR2 (500);
      oauth_access_token              VARCHAR2 (500);
      oauth_access_token_secret       VARCHAR2 (500);
      -- v_oauth_token OWA_COOKIE.cookie;
      -- v_token_secret  OWA_COOKIE.cookie;
      oauth_timestamp                 VARCHAR2 (50);
      oauth_nonce                     VARCHAR2 (50);
      oauth_base_string               VARCHAR2 (1000);
      oauth_signature                 VARCHAR2 (100);
      var_http_authorization_header   VARCHAR2 (4096);
      var_http_resp_value             VARCHAR2 (32767);
      var_http_header_name            VARCHAR2 (255);
      var_http_header_value           VARCHAR2 (1023);
      l_linkedin_account_id           VARCHAR2 (255);
      l_linkedin_account_name         VARCHAR2 (255);

      l_clob                          CLOB;
      l_xml                           XMLTYPE;
      -- l_xsl   XMLTYPE;
      l_html                          VARCHAR2 (32767);
      b_debug                         BOOLEAN := FALSE;
   BEGIN
      -- SELECT oauth_consumer_key, oauth_consumer_secret
      -- INTO oauth_consumer_key, oauth_consumer_secret
      -- FROM oauth_linkedin_parameters
      -- WHERE  account = 'eurostat.microstrategy@gmail.com';
      IF token IS NULL
      THEN
         HTP.p ('ERROR: Null Token');
         RETURN;
      END IF;

      BEGIN
         --  SELECT oauth_consumer_key, oauth_consumer_secret, oauth_access_token_secret
         --  INTO  oauth_consumer_key, oauth_consumer_secret, oauth_access_token_secret
         --  FROM  oauth_linkedin_parameters
         --  WHERE  oauth_access_token = token;
         SELECT MAX (account) KEEP (DENSE_RANK LAST ORDER BY last_modified_date) account,
                MAX (oauth_consumer_key) KEEP (DENSE_RANK LAST ORDER BY last_modified_date) oauth_consumer_key,
                MAX (oauth_consumer_secret) KEEP (DENSE_RANK LAST ORDER BY last_modified_date) oauth_consumer_secret,
                MAX (oauth_access_token_secret) KEEP (DENSE_RANK LAST ORDER BY last_modified_date)
                   oauth_access_token_secret
           INTO l_linkedin_account_id,
                oauth_consumer_key,
                oauth_consumer_secret,
                oauth_access_token_secret
           FROM eurostat.oauth_linkedin_parameters
          WHERE oauth_access_token = token AND last_modified_date IS NOT NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            HTP.p ('ERROR: Invalid Token');
            RETURN;
      END;

      SELECT utl_linkedin.urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR (
                (SYSDATE - TO_DATE ('01-01-1970', 'DD-MM-YYYY')) * (86400) - pq_constants.con_num_timestamp_tz_diff)
        INTO oauth_timestamp
        FROM DUAL;

      -- v_oauth_token := OWA_COOKIE.get ('oauth_access_token');
      oauth_access_token := token;
      -- v_token_secret := OWA_COOKIE.get ('oauth_token_secret');

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method,
                                                oauth_api_url,
                                                oauth_consumer_key,
                                                oauth_timestamp,
                                                oauth_nonce                                /*,v_oauth_token.vals (1));*/
                                                           ,
                                                oauth_access_token);
      oauth_signature :=
         utl_linkedin.
         signature (oauth_base_string, utl_linkedin.key_token (oauth_consumer_secret, oauth_access_token_secret /*v_token_secret.vals (1)*/
                                                                                                               ));
      var_http_authorization_header :=
         utl_linkedin.authorization_header (oauth_consumer_key,
                                            oauth_access_token                                /*v_oauth_token.vals (1)*/
                                                              ,
                                            oauth_timestamp,
                                            oauth_nonce,
                                            oauth_signature);
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);

      http_req := UTL_HTTP.begin_request (oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r => http_req, name => 'Authorization', VALUE => var_http_authorization_header);

      IF b_debug
      THEN
         HTP.p ('<table border="1">');
         HTP.p ('<tr><td><b>oauth_consumer_key: </b>' || oauth_consumer_key || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_consumer_secret: </b>' || oauth_consumer_secret || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_nonce: </b>' || oauth_nonce || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_timestamp: </b>' || oauth_timestamp || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_token: </b>' || token || '</td></tr>');
         --HTP.p ('<tr><td><b>v_token_secret: </b>' || v_token_secret.vals (1) || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_base_string: </b>' || oauth_base_string || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_signature: </b>' || oauth_signature || '</td></tr>');
         HTP.p ('<tr><td><b>authorization_header: </b>' || var_http_authorization_header || '</td></tr>');
         HTP.p ('<tr><td>&nbsp;</td></tr>');
      END IF;

      http_resp := UTL_HTTP.get_response (http_req);

      -- IF http_resp.status_code = 401
      -- THEN
      --  -- Error en el token borra el cookie y vuelve a pedir acceso
      --  --owa_cookie.remove(
      --  -- name  in  varchar2,
      --  -- val in varchar2,
      --  -- path  in  varchar2 DEFAULT NULL);
      --
      --  --HTP.p ('<script type="text/javascript">window.location = "' || '/cdm_dad/request_token' || '"</script>');
      -- END IF;

      IF b_debug
      THEN
         HTP.p ('<tr><td><b>status code: </b>' || http_resp.status_code || '</td></tr>');
         HTP.p ('<tr><td><b>reason phrase: </b>' || http_resp.reason_phrase || '</td></tr>');

         FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
         LOOP
            UTL_HTTP.get_header (http_resp,
                                 i,
                                 var_http_header_name,
                                 var_http_header_value);
            HTP.p ('<tr><td><b>' || var_http_header_name || ': </b>' || var_http_header_value || '</td></tr>');
         END LOOP;

         HTP.p ('<tr><td>&nbsp;</td></tr>');
         HTP.p ('</table>');
      END IF;

      DBMS_LOB.createtemporary (l_clob, FALSE);

      BEGIN
         WHILE TRUE
         LOOP
            UTL_HTTP.read_line (http_resp, var_http_resp_value, TRUE);
            DBMS_LOB.writeappend (l_clob, LENGTH (var_http_resp_value), var_http_resp_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      -- SELECT const_value
      -- INTO l_xsl
      -- FROM xml_constants
      -- WHERE  xml_constants.const_name = 'get_profile';

      l_xml := xmltype (l_clob);
      --l_html := l_xml.transform (l_xsl).getclobval ();
      --HTP.p (l_html);
      UTL_HTTP.end_response (http_resp);
      DBMS_LOB.freetemporary (l_clob);

      BEGIN
         UPDATE oauth_linkedin_parameters
            SET account = l_xml.EXTRACT ('/person/id/text()').getstringval ()
          WHERE account = l_linkedin_account_id;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            DELETE FROM oauth_linkedin_parameters
                  WHERE account = l_xml.EXTRACT ('/person/id/text()').getstringval ();

            UPDATE oauth_linkedin_parameters
               SET account = l_xml.EXTRACT ('/person/id/text()').getstringval ()
             WHERE account = l_linkedin_account_id;
      END;

      --    DELETE FROM oauth_linkedin_parameters
      --    WHERE         oauth_access_token LIKE TRIM (token) AND account <> l_linkedin_account_id;

      SELECT    '<return_code><pass userid="LNKD_'
             || EXTRACTVALUE (l_xml, '/person/id')
             || '" username="'
             || EXTRACTVALUE (l_xml, '/person/first-name')
             || ' '
             || EXTRACTVALUE (l_xml, '/person/last-name')
             || '" /></return_code>'
        INTO l_html
        FROM DUAL;

      OWA_UTIL.mime_header ('text/xml', TRUE, 'utf-8');
      HTP.p (l_html);
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END mstr_lnkd_authenticate;
/
