DROP FUNCTION GOOGLE_ANALYTICS_PROFILE;

CREATE OR REPLACE FUNCTION          google_analytics_profile (
   p_google_analytics_login IN VARCHAR2)
   RETURN VARCHAR2
IS
   http_method            CONSTANT VARCHAR2 (5) := 'GET';
   http_req                        UTL_HTTP.req;
   http_resp                       UTL_HTTP.resp;
   con_str_wallet_path    CONSTANT VARCHAR2 (50)
      := 'file:/u01/app/oracle/product/11.2.0/wallet' ;
   con_str_wallet_pass    CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   google_analytics__api_url       VARCHAR2 (2000)
      := 'https://www.googleapis.com/analytics/v2.4/management/accounts/~all/webproperties/~all/profiles';
   var_http_authorization_header   VARCHAR2 (4096)
                                      := p_google_analytics_login;
   v_user_params                   VARCHAR2 (2048);

   h_name                          VARCHAR2 (255);
   h_value                         VARCHAR2 (1023);
   res_value                       VARCHAR2 (32767);
   l_clob                          CLOB;
   l_text                          VARCHAR2 (32767);
   l_xml                           XMLTYPE;
BEGIN
   UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH       => pq_constants.con_str_wallet_path,
                        password   => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (FALSE);
   UTL_HTTP.set_detailed_excp_support (FALSE);
   http_req :=
      UTL_HTTP.begin_request (google_analytics__api_url,
                              http_method,
                              UTL_HTTP.http_version_1_1);

   UTL_HTTP.set_body_charset (http_req, 'UTF-8');
   UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
   UTL_HTTP.set_header (
      r       => http_req,
      NAME    => 'Authorization',
      VALUE   => 'GoogleLogin ' || var_http_authorization_header);
   http_resp := UTL_HTTP.get_response (http_req);

   FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
   LOOP
      UTL_HTTP.get_header (http_resp,
                           i,
                           h_name,
                           h_value);
   END LOOP;

   DBMS_LOB.createtemporary (l_clob, FALSE);

   BEGIN
      WHILE 1 = 1
      LOOP
         UTL_HTTP.read_text (http_resp, l_text, 32766);
         DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;

   UTL_HTTP.end_response (http_resp);
   l_xml :=
      xmltype (l_clob).EXTRACT (
         '/feed/entry[1]/dxp:property[@name="ga:profileId"]/@value',
         'xmlns="http://www.w3.org/2005/Atom" xmlns:dxp="http://schemas.google.com/analytics/2009" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/"');
   DBMS_LOB.freetemporary (l_clob);

   RETURN l_xml.getstringval ();
END;
/
