DROP PROCEDURE GET_PROFILE;

CREATE OR REPLACE PROCEDURE          get_profile
IS
   oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~';
   http_method               CONSTANT VARCHAR2 (5) := 'GET';
   http_req                           UTL_HTTP.req;
   http_resp                          UTL_HTTP.resp;
   oauth_consumer_key                 VARCHAR2 (500);
   oauth_consumer_secret              VARCHAR2 (500);
   v_oauth_token                      OWA_COOKIE.cookie;
   v_token_secret                     OWA_COOKIE.cookie;
   oauth_timestamp                    VARCHAR2 (50);
   oauth_nonce                        VARCHAR2 (50);
   oauth_base_string                  VARCHAR2 (1000);
   oauth_signature                    VARCHAR2 (100);
   var_http_authorization_header      VARCHAR2 (4096);
   var_http_resp_value                VARCHAR2 (32767);
   var_http_header_name               VARCHAR2 (255);
   var_http_header_value              VARCHAR2 (1023);
   l_clob                             CLOB;
   l_xml                              XMLTYPE;
   l_xsl                              XMLTYPE;
   l_html                             VARCHAR2 (32767);
   b_DEBUG                            BOOLEAN := FALSE;
BEGIN
   SELECT oauth_consumer_key, oauth_consumer_secret
     INTO oauth_consumer_key, oauth_consumer_secret
     FROM oauth_linkedin_parameters
    WHERE account = 'eurostat.microstrategy@gmail.com';
   SELECT utl_linkedin.urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;
   SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400)) INTO oauth_timestamp FROM DUAL;
   v_oauth_token := OWA_COOKIE.get ('oauth_access_token');
   v_token_secret := OWA_COOKIE.get ('oauth_token_secret');
   oauth_base_string :=
      utl_linkedin.base_string_access_token (http_method
                                            ,oauth_api_url
                                            ,oauth_consumer_key
                                            ,oauth_timestamp
                                            ,oauth_nonce
                                            ,v_oauth_token.vals (1));
   oauth_signature := utl_linkedin.signature ( oauth_base_string, utl_linkedin.key_token ( oauth_consumer_secret, v_token_secret.vals (1)));
   var_http_authorization_header :=
      utl_linkedin.authorization_header (oauth_consumer_key
                                        ,v_oauth_token.vals (1)
                                        ,oauth_timestamp
                                        ,oauth_nonce
                                        ,oauth_signature);
   --UTL_HTTP.set_proxy (PKG_CONSTANTS.con_str_http_proxy);
   UTL_HTTP.set_wallet ( PATH => PQ_CONSTANTS.con_str_wallet_path, PASSWORD => PQ_CONSTANTS.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);
   http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
   UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
   IF b_DEBUG
   THEN
      HTP.p ('<table border="1">');
      HTP.p ('<tr><td><b>oauth_consumer_key: </b>' || oauth_consumer_key || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_consumer_secret: </b>' || oauth_consumer_secret || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_nonce: </b>' || oauth_nonce || '</td></tr>');
      HTP.p ('<tr><td><b>oauth_timestamp: </b>' || oauth_timestamp || '</td></tr>');
      HTP.p ('<tr><td><b>v_oauth_token: </b>' || v_oauth_token.vals (1) || '</td></tr>');
      HTP.p ('<tr><td><b>v_token_secret: </b>' || v_token_secret.vals (1) || '</td></tr>');
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
      HTP.p ('</table>');
   END IF;
   DBMS_LOB.createtemporary ( l_clob, FALSE);
   BEGIN
      WHILE TRUE
      LOOP
         UTL_HTTP.read_line ( http_resp, var_http_resp_value, TRUE);
         DBMS_LOB.writeappend ( l_clob, LENGTH (var_http_resp_value), var_http_resp_value);
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;
   SELECT CONST_VALUE
     INTO l_xsl
     FROM XML_CONSTANTS
    WHERE XML_CONSTANTS.const_name = 'get_profile';
   l_xml       := xmltype (l_clob);
   l_html      := l_xml.transform (l_xsl).getclobval ();
   HTP.p (l_html);
   UTL_HTTP.end_response (http_resp);
   DBMS_LOB.freetemporary (l_clob);
EXCEPTION
   WHEN OTHERS
   THEN
      utl_linkedin.SendErrorOutput ( SQLERRM, DBMS_UTILITY.format_error_backtrace);
END;
/
