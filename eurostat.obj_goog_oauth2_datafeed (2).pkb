DROP PACKAGE BODY OBJ_GOOG_OAUTH2_DATAFEED;

CREATE OR REPLACE PACKAGE BODY          obj_goog_oauth2_datafeed
AS
   PROCEDURE jsp (state IN VARCHAR2 := NULL)
   IS
      http_method          CONSTANT VARCHAR2 (5) := 'GET';
      http_req                      UTL_HTTP.req;
      http_resp                     UTL_HTTP.resp;
      google_analytics_oauth2_url   VARCHAR2 (2000) := 'https://www.googleapis.com/analytics/v3/data/ga';
      var_http_authorization_header VARCHAR2 (4096);
      v_user_params                 VARCHAR2 (2048);
      h_name                        VARCHAR2 (255);
      h_value                       VARCHAR2 (1023);
      res_value                     VARCHAR2 (32767);
      l_clob                        CLOB;
      l_text                        VARCHAR2 (32767);
      l_xml                         XMLTYPE;
      obj                           json;
   BEGIN
      SELECT token_type || ' ' || urlencode (access_token)
            ,    '?ids=ga:'
              || TO_CHAR (profile_id)
              || '&dimensions=ga:country,ga:browser,ga:source'
              || '&metrics=ga:visits,ga:pageviews,ga:timeOnSite,ga:exits'
              --pageviews || '&dimensions=ga:pagePath&metrics=ga:pageviews,ga:uniquePageviews,ga:timeOnPage,ga:bounces,ga:entrances,ga:exits&sort=-ga:pageviews'
              || '&start-date='
              || TO_CHAR (SYSDATE - 30, 'YYYY-MM-DD')
              || '&end-date='
              || TO_CHAR (SYSDATE, 'YYYY-MM-DD')
              || '&max-results=100'
              || '&prettyprint=true'
      INTO   var_http_authorization_header
            ,v_user_params
      FROM   objs_google_analytics
      WHERE  ACCOUNT = state;

      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, PASSWORD => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
      http_req := UTL_HTTP.begin_request (google_analytics_oauth2_url || v_user_params, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_body_charset (http_req, 'UTF-8');
      UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header (r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      --HTP.p ('<hr>'||var_http_authorization_header);

      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      --      UTL_HTTP.write_text (http_req, v_user_params);
      http_resp := UTL_HTTP.get_response (http_req);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp, i, h_name, h_value);
      --HTP.p ('<hr>' || h_name || ':' || h_value);
      END LOOP;

      DBMS_LOB.createtemporary (l_clob, FALSE);

      BEGIN
         WHILE 1 = 1
         LOOP
            UTL_HTTP.read_text (http_resp, l_text, 32766);
            DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
         --UTL_HTTP.read_line (http_resp, res_value, TRUE);
         --HTP.p ('<hr>'||res_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (http_resp);
      obj := json (REPLACE (l_clob, 'ga:', ''));
      l_xml := json_xml.json_to_xml (obj);
      DBMS_LOB.freetemporary (l_clob);

      --OWA_UTIL.mime_header ('text/xml', TRUE, 'utf-8');
      UPDATE objs_google_analytics
         SET xml_response = l_xml
       WHERE ACCOUNT = state;

      HTP.p
         ('<script type="text/javascript">window.location = "http://moraschi.eu/MicroStrategy/servlet/mstrWeb?hiddenSections=header&Server=IP-10-195-81-29&Project=EUROSTAT&Port=0&evt=4001&src=mstrWeb.4001&visMode=0&reportViewMode=1&reportID=67CEC5F34F286B8EDB9AAD8DC40F9543"</script>');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;

   PROCEDURE "analytics#gaData" (lnkd_id IN VARCHAR2, cursor_gadata IN OUT sys_refcursor)
   IS
   BEGIN
      OPEN cursor_gadata FOR
         SELECT EXTRACTVALUE (COLUMN_VALUE, '/rows') l_row
         FROM   objs_google_analytics, TABLE (XMLSEQUENCE (EXTRACT (xml_response, '/root/rows'))) p
         WHERE  ACCOUNT = lnkd_id;
   END "analytics#gaData";

   FUNCTION "analytics#gaData" (lnkd_id IN VARCHAR2)
      RETURN mstr_goog_adata_table_type
   IS
      http_method          CONSTANT VARCHAR2 (5) := 'GET';
      http_req                      UTL_HTTP.req;
      http_resp                     UTL_HTTP.resp;
      var_http_authorization_header VARCHAR2 (4096);
      v_user_params                 VARCHAR2 (2048);
      h_name                        VARCHAR2 (255);
      h_value                       VARCHAR2 (1023);
      l_clob                        CLOB;
      l_text                        VARCHAR2 (32767);
      obj                           json;
      l_xml                         XMLTYPE;
      google_analytics_oauth2_url   VARCHAR2 (2000) := 'https://www.googleapis.com/analytics/v3/data/ga';
      cursor_gadata                 sys_refcursor;
      l_row                         CLOB;
      l_list                        parse.items_tt;
      v_tab                         mstr_goog_adata_table_type := mstr_goog_adata_table_type ();
      v_country                     VARCHAR2 (500)
         :=    '<script type="text/javascript">window.location = "http://moraschi.eu:8081/sso/obj_goog_oauth2_auth.jsp?state='
            || lnkd_id
            || '"</script>';
      v_profile_name                VARCHAR2 (1000);
      v_browser                     VARCHAR2 (500);
      v_source                      VARCHAR2 (2000);
      v_visits                      NUMBER;
      v_pageviews                   NUMBER;
      v_timeonsite                  NUMBER;
      v_exits                       NUMBER;
      v_access_token                objs_google_analytics.access_token%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT access_token
         INTO   v_access_token
         FROM   objs_google_analytics
         WHERE  ACCOUNT = lnkd_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_tab.EXTEND;
            v_tab (v_tab.LAST) :=
               mstr_goog_adata_row_type (v_profile_name
                                        ,v_country
                                        ,v_browser
                                        ,v_source
                                        ,v_visits
                                        ,v_pageviews
                                        ,v_timeonsite
                                        ,v_exits);
            RETURN v_tab;
      END;

      IF v_access_token IS NULL
      THEN
         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_goog_adata_row_type (v_profile_name
                                     ,v_country
                                     ,v_browser
                                     ,v_source
                                     ,v_visits
                                     ,v_pageviews
                                     ,v_timeonsite
                                     ,v_exits);
         RETURN v_tab;
      END IF;

/*      ELSE
         "analytics#gaData" (lnkd_id, cursor_gadata);

         LOOP
            FETCH cursor_gadata
            INTO  l_row;

            --v_country, v_browser, v_source, v_visits, v_pageviews, v_timeOnSite,v_exits ;
            EXIT WHEN cursor_gadata%NOTFOUND;
            l_list := parse.string_to_list (l_row, ',');
            v_country := REPLACE (REPLACE (l_list (1), '"', ''), '[', '');
            v_browser := REPLACE (l_list (2), '"', '');
            v_source := REPLACE (l_list (3), '"', '');
            v_visits := REPLACE (l_list (4), '"', '');
            v_pageviews := REPLACE (l_list (5), '"', '');
            --v_timeOnSite := REPLACE( REPLACE(l_list (6),'"',''),'.',',');
            --v_timeOnSite := REPLACE(l_list (6),'"','');--,'.',',');
            v_exits := REPLACE (REPLACE (l_list (7), '"', ''), ']', '');
            v_tab.EXTEND;
            v_tab (v_tab.LAST) :=
                          mstr_goog_adata_row_type (v_country, v_browser, v_source, v_visits, v_pageviews, v_timeonsite, v_exits);
         END LOOP;
      END IF;
*/
      SELECT token_type || ' ' || urlencode (access_token)
            ,    '?ids=ga:'
              || TO_CHAR (profile_id)
              || '&dimensions=ga:country,ga:browser,ga:source'
              || '&metrics=ga:visits,ga:pageviews,ga:timeOnSite,ga:exits'
              --pageviews || '&dimensions=ga:pagePath&metrics=ga:pageviews,ga:uniquePageviews,ga:timeOnPage,ga:bounces,ga:entrances,ga:exits&sort=-ga:pageviews'
              || '&start-date='
              || TO_CHAR (SYSDATE - 30, 'YYYY-MM-DD')
              || '&end-date='
              || TO_CHAR (SYSDATE, 'YYYY-MM-DD')
              || '&max-results=100'
              || '&prettyprint=true'
            ,profile_name
      INTO   var_http_authorization_header
            ,v_user_params
            ,v_profile_name
      FROM   objs_google_analytics
      WHERE  ACCOUNT = lnkd_id;

      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, PASSWORD => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
      http_req := UTL_HTTP.begin_request (google_analytics_oauth2_url || v_user_params, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_body_charset (http_req, 'UTF-8');
      UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header (r => http_req, NAME => 'Authorization', VALUE => var_http_authorization_header);
      --HTP.p ('<hr>'||var_http_authorization_header);

      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_user_params));
      --      UTL_HTTP.write_text (http_req, v_user_params);
      http_resp := UTL_HTTP.get_response (http_req);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp, i, h_name, h_value);
      --HTP.p ('<hr>' || h_name || ':' || h_value);
      END LOOP;

      DBMS_LOB.createtemporary (l_clob, FALSE);

      BEGIN
         WHILE 1 = 1
         LOOP
            UTL_HTTP.read_text (http_resp, l_text, 32766);
            DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
         --UTL_HTTP.read_line (http_resp, res_value, TRUE);
         --HTP.p ('<hr>'||res_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (http_resp);
      obj := json (REPLACE (l_clob, 'ga:', ''));
      l_xml := json_xml.json_to_xml (obj);
      DBMS_LOB.freetemporary (l_clob);

      --OWA_UTIL.mime_header ('text/xml', TRUE, 'utf-8');
      OPEN cursor_gadata FOR
         SELECT EXTRACTVALUE (COLUMN_VALUE, '/rows') l_row
         FROM   TABLE (XMLSEQUENCE (EXTRACT (l_xml, '/root/rows'))) p;

      --WHERE  ACCOUNT = lnkd_id;
      LOOP
         FETCH cursor_gadata
         INTO  l_row;

         --v_country, v_browser, v_source, v_visits, v_pageviews, v_timeOnSite,v_exits ;
         EXIT WHEN cursor_gadata%NOTFOUND;
         l_list := parse.string_to_list (l_row, ',');
         v_country := REPLACE (REPLACE (l_list (1), '"', ''), '[', '');
         v_browser := REPLACE (l_list (2), '"', '');
         v_source := REPLACE (l_list (3), '"', '');
         v_visits := REPLACE (l_list (4), '"', '');
         v_pageviews := REPLACE (l_list (5), '"', '');
         --v_timeOnSite := REPLACE( REPLACE(l_list (6),'"',''),'.',',');
         v_timeOnSite := REPLACE(l_list (6),'"','');--,'.',',');
         v_exits := REPLACE (REPLACE (l_list (7), '"', ''), ']', '');
         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_goog_adata_row_type (v_profile_name
                                     ,v_country
                                     ,v_browser
                                     ,v_source
                                     ,v_visits
                                     ,v_pageviews
                                     ,v_timeonsite
                                     ,v_exits);
      END LOOP;

      RETURN v_tab;
   END "analytics#gaData";
END;
/
