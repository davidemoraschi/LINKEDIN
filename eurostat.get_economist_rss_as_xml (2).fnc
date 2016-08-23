DROP FUNCTION GET_ECONOMIST_RSS_AS_XML;

CREATE OR REPLACE FUNCTION          GET_ECONOMIST_RSS_AS_XML (
   --   p_rss_url IN VARCHAR2 := 'http://www.economist.com/blogs/charlemagne/2011/12/euro-crisis-0?fsrc=rss')
   p_rss_url IN VARCHAR2 := 'http://www.economist.com/topics/euro-zone/index.xml')
   --
   RETURN XMLTYPE
AS
   l_http_req    UTL_HTTP.req;
   l_http_resp   UTL_HTTP.resp;
   l_content     CLOB;
   --l_gzcompressed_blob   BLOB;
   --l_uncompressed_blob   BLOB;
   l_text        VARCHAR2 (32767);
   l_raw         RAW (32767);
   l_xml         XMLTYPE;
BEGIN
   UTL_HTTP.set_proxy (proxy => pq_constants.con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   UTL_HTTP.set_response_error_check (enable => FALSE);
   UTL_HTTP.set_detailed_excp_support (enable => FALSE);
   l_http_req := UTL_HTTP.begin_request (p_rss_url, 'GET', UTL_HTTP.http_version_1_1);

   UTL_HTTP.set_body_charset (l_http_req, 'UTF-8');
   UTL_HTTP.set_header (l_http_req, 'User-Agent', 'Mozilla/4.0');
   UTL_HTTP.set_header (l_http_req, 'Accept-Charset', 'utf-8');
   UTL_HTTP.set_header (l_http_req, 'Accept-Encoding', 'gzip,deflate');

   --UTL_HTTP.set_header (l_http_req, 'Accept-Charset', 'utf-8');
   --UTL_HTTP.set_header (r => l_http_req, name => 'Accept-Encoding', VALUE => 'gzip,deflate');
   --UTL_HTTP.set_header (r => l_http_req, name => 'Accept', VALUE => 'application/xml');

   --DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
   DBMS_LOB.createtemporary (l_content, FALSE);

   l_http_resp := UTL_HTTP.get_response (l_http_req);

   BEGIN
      LOOP
         --UTL_HTTP.read_line (l_http_resp, l_text, TRUE);
         --DBMS_OUTPUT.put_line (l_text);
         --UTL_HTTP.read_text (l_http_resp, l_text, 32766);
         UTL_HTTP.read_raw (l_http_resp, l_raw, 32766);
         l_text := UTL_RAW.CAST_TO_VARCHAR2 (l_raw);
         --DBMS_OUTPUT.put_line (UTL_RAW.CAST_TO_VARCHAR2 (l_raw));
         DBMS_LOB.writeappend (l_content, LENGTH (l_text), l_text);
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;

   UTL_HTTP.end_response (l_http_resp);
   l_xml := xmltype (l_content);
   DBMS_LOB.freetemporary (l_content);
   RETURN l_xml;
END;
/
