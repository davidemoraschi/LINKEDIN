DROP FUNCTION GET_FULLNAME;

CREATE OR REPLACE FUNCTION          GET_FULLNAME (lnkd_id IN VARCHAR2 := 'LNKD_74oTveK-gQ')
   RETURN VARCHAR2
AS
   http_method                     CONSTANT VARCHAR2 (5) := 'GET';
   http_req                        UTL_HTTP.req;
   http_resp                       UTL_HTTP.resp;
   oauth_api_url                   VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~:(first-name,last-name)';
   oauth_consumer_key              VARCHAR2 (500);
   oauth_consumer_secret           VARCHAR2 (500);
   oauth_timestamp                 VARCHAR2 (50);
   oauth_nonce                     VARCHAR2 (50);
   oauth_base_string               VARCHAR2 (1000);
   oauth_signature                 VARCHAR2 (100);
   oauth_access_token              VARCHAR2 (500);
   oauth_access_token_secret       VARCHAR2 (500);
   var_http_authorization_header   VARCHAR2 (4096);
   var_http_resp_value             VARCHAR2 (32767);
   b_debug                         BOOLEAN := FALSE;
   l_clob                          CLOB;
   l_xml                           XMLTYPE;
   v_retval                        VARCHAR2 (1024);
BEGIN
   BEGIN
      SELECT oauth_consumer_key,
             oauth_consumer_secret,
             oauth_access_token,
             oauth_access_token_secret
        INTO oauth_consumer_key,
             oauth_consumer_secret,
             oauth_access_token,
             oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = SUBSTR (lnkd_id, 6);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF b_debug
         THEN
            HTP.p ('ERROR: Account unknown');
            RETURN 'ERR';
         ELSE
            RAISE;
         END IF;
   END;

   SELECT utl_linkedin.urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

   SELECT TO_CHAR (
             (SYSDATE - TO_DATE ('01-01-1970', 'DD-MM-YYYY')) * (86400) - pq_constants.con_num_timestamp_tz_diff)
     INTO oauth_timestamp
     FROM DUAL;

   oauth_base_string :=
      utl_linkedin.base_string_access_token (http_method,
                                             oauth_api_url,
                                             oauth_consumer_key,
                                             oauth_timestamp,
                                             oauth_nonce,
                                             oauth_access_token);
   oauth_signature :=
      utl_linkedin.
      signature (oauth_base_string, utl_linkedin.key_token (oauth_consumer_secret, oauth_access_token_secret));
   var_http_authorization_header :=
      utl_linkedin.authorization_header (oauth_consumer_key,
                                         oauth_access_token,
                                         oauth_timestamp,
                                         oauth_nonce,
                                         oauth_signature);

   UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);

   http_req := UTL_HTTP.begin_request (oauth_api_url, http_method, UTL_HTTP.http_version_1_1);
   UTL_HTTP.set_header (r => http_req, name => 'Authorization', VALUE => var_http_authorization_header);
   http_resp := UTL_HTTP.get_response (http_req);
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

   l_xml := xmltype (l_clob);
   UTL_HTTP.end_response (http_resp);
   DBMS_LOB.freetemporary (l_clob);

   SELECT EXTRACTVALUE (l_xml, '/person/first-name') || ' ' || EXTRACTVALUE (l_xml, '/person/last-name')
     INTO v_retval
     FROM DUAL;

   RETURN v_retval;
END;
/
