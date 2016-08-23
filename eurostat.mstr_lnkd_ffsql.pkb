DROP PACKAGE BODY MSTR_LNKD_FFSQL;

CREATE OR REPLACE PACKAGE BODY          mstr_lnkd_FFSQL
AS
   PROCEDURE connections (lnkd_id IN VARCHAR2, cursor_connections IN OUT SYS_REFCURSOR)
   IS
      oauth_api_url                   VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/connections';
      http_method                     CONSTANT VARCHAR2 (5) := 'GET';
      http_req                        UTL_HTTP.req;
      http_resp                       UTL_HTTP.resp;
      oauth_consumer_key              VARCHAR2 (500);
      oauth_consumer_secret           VARCHAR2 (500);
      oauth_timestamp                 VARCHAR2 (50);
      oauth_nonce                     VARCHAR2 (50);
      oauth_base_string               VARCHAR2 (1000);
      oauth_signature                 VARCHAR2 (100);
      --oauth_callback                  VARCHAR2 (1000) := 'http://moraschi.eu/sso/request_token_callback';
      oauth_access_token              VARCHAR2 (500);
      oauth_access_token_secret       VARCHAR2 (500);
      var_http_authorization_header   VARCHAR2 (4096);
      var_http_resp_value             VARCHAR2 (32767);
      var_http_header_name            VARCHAR2 (255);
      var_http_header_value           VARCHAR2 (1023);
      l_clob                          CLOB;
      l_xml                           XMLTYPE;
      l_xml_from_cursor               VARCHAR2 (32767);
      l_xsl                           XMLTYPE;
      l_html                          VARCHAR2 (32767);
      b_debug                         BOOLEAN := FALSE;
   BEGIN
      NULL;

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
               RETURN;
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

      IF b_debug
      THEN
         DBMS_OUTPUT.put_line ('<table border="1">');
         DBMS_OUTPUT.put_line ('<tr><td><b>status code: </b>' || http_resp.status_code || '</td></tr>');
         DBMS_OUTPUT.put_line ('<tr><td><b>reason phrase: </b>' || http_resp.reason_phrase || '</td></tr>');

         FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
         LOOP
            UTL_HTTP.get_header (http_resp,
                                 i,
                                 var_http_header_name,
                                 var_http_header_value);
            DBMS_OUTPUT.
            put_line ('<tr><td><b>' || var_http_header_name || ': </b>' || var_http_header_value || '</td></tr>');
         END LOOP;

         DBMS_OUTPUT.put_line ('<tr><td>&nbsp;</td></tr>');
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

      l_xml := xmltype (l_clob);
      UTL_HTTP.end_response (http_resp);

      IF b_debug
      THEN
         INSERT INTO log_http (result, last_execution)
              VALUES (l_xml, SYSTIMESTAMP);

         COMMIT;
      END IF;

      IF b_debug
      THEN
         FOR c1 IN (SELECT EXTRACTVALUE (VALUE (p), '/person/id') "id",
                           EXTRACTVALUE (VALUE (p), '/person/first-name') "first-name",
                           EXTRACTVALUE (VALUE (p), '/person/last-name') "last-name",
                           EXTRACTVALUE (VALUE (p), '/person/headline') "headline",
                           EXTRACTVALUE (VALUE (p), '/person/site-standard-profile-request/url') "link",
                           EXTRACTVALUE (VALUE (p), '/person/location/name') "location",
                           EXTRACTVALUE (VALUE (p), '/person/industry') "industry"
                      FROM TABLE (XMLSEQUENCE (EXTRACT (l_xml, '/connections/person'))) p)
         LOOP
            DBMS_OUTPUT.put_line ('<tr><td>' || c1."first-name" || '</td></tr>');
         END LOOP;
      ELSE
         OPEN cursor_connections FOR
            SELECT EXTRACTVALUE (VALUE (p), '/person/id') "id",
                   EXTRACTVALUE (VALUE (p), '/person/first-name') "first-name",
                   EXTRACTVALUE (VALUE (p), '/person/last-name') "last-name",
                   EXTRACTVALUE (VALUE (p), '/person/headline') "headline",
                   EXTRACTVALUE (VALUE (p), '/person/site-standard-profile-request/url') "link",
                   EXTRACTVALUE (VALUE (p), '/person/location/name') "location",
                   EXTRACTVALUE (VALUE (p), '/person/industry') "industry"
              FROM TABLE (XMLSEQUENCE (EXTRACT (l_xml, '/connections/person'))) p;
      END IF;


      DBMS_LOB.freetemporary (l_clob);
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END connections;

   FUNCTION connections_table (lnkd_id IN VARCHAR2)
      RETURN mstr_lnkd_connections_type
   IS
      v_tab                mstr_lnkd_connections_type := mstr_lnkd_connections_type ();
      cursor_connections   SYS_REFCURSOR;
      v_id                 VARCHAR2 (50);
      v_first_name         VARCHAR2 (250);
      v_last_name          VARCHAR2 (250);
      v_headline           VARCHAR2 (250);
      v_link               VARCHAR2 (2500);
      v_location           VARCHAR2 (250);
      v_industry           VARCHAR2 (250);
   BEGIN
      connections (lnkd_id, cursor_connections);

      LOOP
         FETCH cursor_connections
         INTO v_id, v_first_name, v_last_name, v_headline, v_link, v_location, v_industry;

         EXIT WHEN cursor_connections%NOTFOUND;

         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_lnkd_connection_row_type (v_id,
                                           v_first_name,
                                           v_last_name,
                                           v_headline);
      END LOOP;



      RETURN v_tab;
   END connections_table;

   PROCEDURE groups (lnkd_id IN VARCHAR2, cursor_groups IN OUT SYS_REFCURSOR)
   IS
      oauth_api_url               VARCHAR2 (1000)
                                     := 'http://api.linkedin.com/v1/people/~/group-memberships:(group:(id,name,category,small-logo-url,site-group-url),membership-state)';
      oauth_api_url_parameters    VARCHAR2 (1000)
                                     := 'count=500&membership-state=awaiting-confirmation&membership-state=manager&membership-state=member&membership-state=moderator&membership-state=owner';
      /*membership-state and all orther parameters must be in sort order for the oauth signature to work*/
      http_method                 CONSTANT VARCHAR2 (5) := 'GET';
      http_req                    UTL_HTTP.req;
      http_resp                   UTL_HTTP.resp;
      oauth_consumer_key          VARCHAR2 (500);
      oauth_consumer_secret       VARCHAR2 (500);
      oauth_access_token          VARCHAR2 (500);
      oauth_access_token_secret   VARCHAR2 (500);
      oauth_timestamp             VARCHAR2 (50);
      oauth_nonce                 VARCHAR2 (50);
      oauth_base_string           VARCHAR2 (1000);
      oauth_signature             VARCHAR2 (100);
      var_http_resp_value         VARCHAR2 (32767);
      var_http_header_name        VARCHAR2 (255);
      var_http_header_value       VARCHAR2 (1023);
      l_clob                      CLOB;
      l_xml                       XMLTYPE;
      b_debug                     BOOLEAN := FALSE;
   BEGIN
      IF lnkd_id IS NULL
      THEN
         HTP.p ('ERROR: Null ID');
         RETURN;
      END IF;

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
               RETURN;
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
         utl_linkedin.base_string_access_token_par (http_method,
                                                    oauth_api_url,
                                                    oauth_consumer_key,
                                                    oauth_timestamp,
                                                    oauth_nonce,
                                                    oauth_access_token,
                                                    oauth_api_url_parameters);
      oauth_signature :=
         utl_linkedin.
         signature (oauth_base_string, utl_linkedin.key_token (oauth_consumer_secret, oauth_access_token_secret));
      oauth_api_url :=
            oauth_api_url
         || '?'
         || oauth_api_url_parameters
         || '&oauth_consumer_key='
         || oauth_consumer_key
         || '&oauth_nonce='
         || oauth_nonce
         || '&oauth_signature='
         || urlencode (oauth_signature)
         || '&oauth_signature_method=HMAC-SHA1&oauth_timestamp='
         || oauth_timestamp
         || '&oauth_token='
         || oauth_access_token
         || '&oauth_version=1.0';
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
      http_req := UTL_HTTP.begin_request (oauth_api_url, http_method, UTL_HTTP.http_version_1_1);

      IF b_debug
      THEN
         HTP.p ('<table border="1">');
         HTP.p ('<tr><td><b>oauth_consumer_key: </b>' || oauth_consumer_key || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_consumer_secret: </b>' || oauth_consumer_secret || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_nonce: </b>' || oauth_nonce || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_timestamp: </b>' || oauth_timestamp || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_token: </b>' || oauth_access_token || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_access_token_secret: </b>' || oauth_access_token_secret || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_base_string: </b>' || oauth_base_string || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_signature: </b>' || oauth_signature || '</td></tr>');
         HTP.p ('<tr><td><b>oauth_api_url: </b>' || oauth_api_url || '</td></tr>');
         HTP.p ('<tr><td>&nbsp;</td></tr>');
      END IF;

      http_resp := UTL_HTTP.get_response (http_req);

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

            IF b_debug
            THEN
               HTP.p (var_http_resp_value);
            END IF;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      l_xml := xmltype (l_clob);
      UTL_HTTP.end_response (http_resp);

--      INSERT INTO log_http (result, last_execution)
--           VALUES (l_xml, SYSTIMESTAMP);
--
--      COMMIT;

      OPEN cursor_groups FOR
         SELECT EXTRACTVALUE (VALUE (p), '/group-membership/group/id') "id",
                EXTRACTVALUE (VALUE (p), '/group-membership/group/name') "name",
                EXTRACTVALUE (VALUE (p), '/group-membership/group/category/code') "category",
                EXTRACTVALUE (VALUE (p), '/group-membership/membership-state/code') "membership-state",
                '<img src="' || EXTRACTVALUE (VALUE (p), '/group-membership/group/small-logo-url') || '" />'
                   "small-logo-url",
                   '<a href="'
                || EXTRACTVALUE (VALUE (p), '/group-membership/group/site-group-url')
                || '">Goto to group -></a>'
                   "site-group-url"
           FROM TABLE (XMLSEQUENCE (EXTRACT (l_xml, '/group-memberships/group-membership'))) p;

      DBMS_LOB.freetemporary (l_clob);
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END groups;

   FUNCTION groups_table (lnkd_id IN VARCHAR2)
      RETURN mstr_lnkd_groups_type
   IS
      v_tab                mstr_lnkd_groups_type := mstr_lnkd_groups_type ();
      cursor_groups        SYS_REFCURSOR;
      v_id                 VARCHAR2 (50);
      v_group_name         VARCHAR2 (500);
      v_category           VARCHAR2 (250);
      v_membership_state   VARCHAR2 (50);
      v_logo_url           VARCHAR2 (1024);
      v_group_url          VARCHAR2 (1024);
   BEGIN
      groups (lnkd_id, cursor_groups);

      LOOP
         FETCH cursor_groups
         INTO v_id, v_group_name, v_category, v_membership_state, v_logo_url, v_group_url;

         EXIT WHEN cursor_groups%NOTFOUND;

         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_lnkd_group_row_type (v_id,
                                      v_group_name,
                                      v_category,
                                      v_membership_state,
                                      v_logo_url,
                                      v_group_url);
      END LOOP;



      RETURN v_tab;
   END groups_table;
   PROCEDURE share_EuroStrategy (lnkd_id IN VARCHAR2, p_comment IN VARCHAR2 := 'See how you can use your LinkedIn account to log in to MicroStrategy.', cursor_groups IN OUT SYS_REFCURSOR)
      AS   http_method                                CONSTANT VARCHAR2 (5) := 'POST';
      http_req                           UTL_HTTP.req;
      http_resp                          UTL_HTTP.resp;
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      oauth_api_url                      VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/person-activities';
      oauth_consumer_key                 VARCHAR2 (500);
      oauth_consumer_secret              VARCHAR2 (500);
      oauth_nonce                        VARCHAR2 (50);
      oauth_timestamp                    VARCHAR2 (50);
      oauth_base_string                  VARCHAR2 (1000);
      oauth_signature                    VARCHAR2 (100);
      oauth_access_token                 VARCHAR2 (500);
      oauth_access_token_secret          VARCHAR2 (500);
      var_http_req_url                   VARCHAR2 (4000);
      return_xml                         VARCHAR2 (30000);
      var_http_authorization_header   VARCHAR2 (4096);
      v_user_params                      VARCHAR2 (2048);
      show_header                        NUMBER := 1;
      h_name                             VARCHAR2 (255);
      h_value                            VARCHAR2 (1023);
      res_value                          VARCHAR2 (32767);
   BEGIN
      v_user_params                      
         :=    '<activity locale="en_US">
                    <content-type>linkedin-html</content-type>
                    <body>&lt;a href=&quot;http://moraschi.eu/MicroStrategy&quot;&gt;'||EUROSTAT.GET_FULLNAME(lnkd_id)||' has found this site interesting: EuroStrategy&lt;/a&gt;. '||p_comment||' Test it, share it, and please send your feedback to eurostat.microstrategy@gmail.com</body>
                </activity>';
--      v_user_params                      
--         :=    '<activity locale="en_US">
--                    <content-type>linkedin-html</content-type>
--                    <body>&lt;img src=&quot;http://dl.dropbox.com/u/35291135/images/EuroStrategy_thumb.PNG&quot;&gt;&lt;/img&gt;</body>
--                </activity>';
    UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
 
      SELECT oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        INTO oauth_consumer_key
            ,oauth_consumer_secret
            ,oauth_access_token
            ,oauth_access_token_secret
        FROM oauth_linkedin_parameters
       WHERE account = SUBSTR (lnkd_id, 6);

      SELECT urlencode (oauth_nonce_seq.NEXTVAL) INTO oauth_nonce FROM DUAL;

      SELECT TO_CHAR ( (SYSDATE - TO_DATE ( '01-01-1970', 'DD-MM-YYYY')) * (86400) - pq_constants.con_num_timestamp_tz_diff)
        INTO oauth_timestamp
        FROM DUAL;

      oauth_base_string :=
         utl_linkedin.base_string_access_token (http_method
                                               ,oauth_api_url
                                               ,oauth_consumer_key
                                               ,oauth_timestamp
                                               ,oauth_nonce
                                               ,oauth_access_token);
      --|| pkg_oauth.urlencode ('&twitter-post=true');
      oauth_signature := utl_linkedin.
         signature ( oauth_base_string, utl_linkedin.key_token ( oauth_consumer_secret, oauth_access_token_secret));
      var_http_req_url :=
                  oauth_api_url
         || '?'
         || 'oauth_callback'
         || '='
         || 'oob'
         || '&'
         || 'oauth_consumer_key'
         || '='
         || oauth_consumer_key
         || '&'
         || 'oauth_nonce'
         || '='
         || oauth_nonce
         || '&'
         || 'oauth_signature'
         || '='
         || urlencode (oauth_signature)
         || '&'
         || 'oauth_signature_method'
         || '='
         || 'HMAC-SHA1'
         || '&'
         || 'oauth_timestamp'
         || '='
         || oauth_timestamp
         || '&'
         || 'oauth_token'
         || '='
         || oauth_access_token
         || '&'
         || 'oauth_version'
         || '='
         || '1.0';

--         http_req_url_access_token (oauth_api_url
--                                   ,oauth_consumer_key
--                                   ,oauth_timestamp
--                                   ,oauth_nonce
--                                   ,oauth_signature
--                                   ,oauth_access_token);
      var_http_authorization_header :=
                  'OAuth realm="",oauth_version="1.0",oauth_consumer_key="'
         || oauth_consumer_key
         || '",oauth_token="'
         || oauth_access_token
         || '",oauth_timestamp="'
         || oauth_timestamp
         || '",oauth_nonce="'
         || oauth_nonce
         || '",oauth_signature_method="HMAC-SHA1",oauth_signature="'
         || urlencode (oauth_signature)
         || '"';

--         authorization_header (oauth_consumer_key
--                              ,oauth_access_token
--                              ,oauth_timestamp
--                              ,oauth_nonce
--                              ,oauth_signature);
      http_req    := UTL_HTTP.begin_request ( oauth_api_url, http_method, UTL_HTTP.http_version_1_1);

      UTL_HTTP.set_body_charset ( http_req, 'UTF-8');
      UTL_HTTP.set_header ( http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Type', VALUE => 'application/xml');
      UTL_HTTP.set_header ( r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      UTL_HTTP.write_text ( http_req, v_user_params);
      /*
            DBMS_OUTPUT.put_line ('oauth_consumer_key=' || oauth_consumer_key);
            DBMS_OUTPUT.put_line ('oauth_timestamp=' || oauth_timestamp);
            DBMS_OUTPUT.put_line ('oauth_nonce=' || oauth_nonce);
            DBMS_OUTPUT.put_line ('oauth_consumer_secret=' || oauth_consumer_secret);
            DBMS_OUTPUT.put_line ('oauth_access_token=' || oauth_access_token);
            DBMS_OUTPUT.put_line ('oauth_access_token_secret=' || oauth_access_token_secret);
            DBMS_OUTPUT.put_line ('oauth_base_string=' || oauth_base_string);
            DBMS_OUTPUT.put_line ('oauth_signature=' || oauth_signature);
            DBMS_OUTPUT.put_line ('v_user_params=' || v_user_params);
      */
      http_resp   := UTL_HTTP.get_response (http_req);

      IF show_header = 1
      THEN
         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);

         FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
         LOOP
            UTL_HTTP.get_header (http_resp
                                ,i
                                ,h_name
                                ,h_value);
            DBMS_OUTPUT.put_line (h_name || ': ' || h_value);
         END LOOP;
      END IF;

      BEGIN
         DBMS_OUTPUT.put_line ('Response: ');

         WHILE 1 = 1
         LOOP
            UTL_HTTP.read_line ( http_resp, res_value, TRUE);
            DBMS_OUTPUT.put_line (res_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (http_resp);

      OPEN cursor_groups FOR
         SELECT 'A comment has been sent to your <My Updates> page in LinkedIn. Please don''t execute this report twice.'
           FROM DUAL;
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
--         DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);
--         DBMS_OUTPUT.put_line (SQLERRM);
--         RAISE;
END share_EuroStrategy;
END mstr_lnkd_FFSQL;
/
