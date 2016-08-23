DROP PACKAGE BODY MSTR_GOOG_FFSQL;

CREATE OR REPLACE PACKAGE BODY          MSTR_GOOG_FFSQL
AS
   FUNCTION search_table (p_search_pattern IN VARCHAR2 := 'MicroStrategy RSS')
      RETURN mstr_goog_rss_type
   IS
      url                            VARCHAR2 (4000)
         := 'https://www.googleapis.com/customsearch/v1?alt=atom&cx=010722013183089041389:ab5yj_rbe5q&key=AIzaSyAN80EPArspHpyxtisnqFRSe0fCkOW8w_k&q='
            || urlencode (p_search_pattern);
      con_str_wallet_path   CONSTANT VARCHAR2 (50) := 'file:C:\oracle\product\11.2.0';
      con_str_wallet_pass   CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      req                            UTL_HTTP.req;
      resp                           UTL_HTTP.resp;
      name                           VARCHAR2 (256);
      VALUE                          VARCHAR2 (1024);
      l_clob                         CLOB;
      l_text                         VARCHAR2 (32767);
      l_xml                          XMLTYPE;
      cursor_search_results          SYS_REFCURSOR;
      v_title                        VARCHAR2 (1024);
      v_link                         VARCHAR2 (4000);
      v_description                  CLOB;
      v_pubdate                      VARCHAR2 (20);
      v_tab                          mstr_goog_rss_type := mstr_goog_rss_type ();
   BEGIN
      -- Initialize the CLOB.
      DBMS_LOB.createtemporary (l_clob, FALSE);
      -- When going through a firewall, pass requests through this host.
      -- Specify sites inside the firewall that don't need the proxy host.
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      -- Ask UTL_HTTP not to raise an exception for 4xx and 5xx status codes,
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);

      -- Begin retrieving this Web page.
      req := UTL_HTTP.begin_request (url);
      -- Identify ourselves. Some sites serve special pages for particular browsers.
      UTL_HTTP.set_body_charset (req, 'UTF-8');
      UTL_HTTP.set_header (req, 'User-Agent', 'Mozilla/4.0');
      UTL_HTTP.set_header (req, 'Accept-Charset', 'utf-8');
      UTL_HTTP.set_header (req, 'Accept-Encoding', 'gzip,deflate');

      BEGIN
         -- Start receiving the HTML text.
         resp := UTL_HTTP.get_response (req);

         LOOP
            --UTL_HTTP.read_line ( resp, VALUE);
            --DBMS_OUTPUT.put_line (VALUE);
            UTL_HTTP.read_text (resp, l_text, 32766);
            DBMS_LOB.writeappend (l_clob, LENGTH (l_text), l_text);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (resp);
      l_xml := xmltype (l_clob);
      --UPDATE XML_CONSTANTS SET CONST_VALUE = l_xml WHERE CONST_ID = 99;
      -- Relase the resources associated with the temporary LOB.
      DBMS_LOB.freetemporary (l_clob);

      OPEN cursor_search_results FOR
         SELECT EXTRACTVALUE (
                   VALUE (p),
                   '/entry/title',
                   'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/')
                   title,
                EXTRACTVALUE (
                   VALUE (p),
                   '/entry/link/@href',
                   'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/')
                   link,
                EXTRACTVALUE (
                   VALUE (p),
                   '/entry/summary',
                   'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/')
                   description --               ,EXTRACTVALUE ( VALUE (p), '/entry/updated', 'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/')
                              --                   pubdate
                ,
                TO_DATE (
                   SUBSTR (
                      EXTRACTVALUE (
                         VALUE (p),
                         '/entry/updated',
                         'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/'),
                      1,
                      19),
                   'YYYY-MM-DD"T"HH24:MI:SS')
           FROM TABLE (
                   XMLSEQUENCE (
                      EXTRACT (
                         l_xml,
                         '/feed/entry',
                         'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/'))) p;

      LOOP
         FETCH cursor_search_results
         INTO v_title, v_link, v_description, v_pubdate;                                       --, v_link, v_location, v_industry;

         EXIT WHEN cursor_search_results%NOTFOUND;

         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_goog_rss_row_type ('google',
                                    v_title,
                                    v_link,
                                    v_description,
                                    v_pubdate);
      END LOOP;

      RETURN v_tab;
   END search_table;
/*
   PROCEDURE search_table (p_search_pattern IN VARCHAR2 := 'MicroStrategy RSS')
   --RETURN mstr_goog_rss_type
   IS
      url                                VARCHAR2 (4000)
         := 'https://www.googleapis.com/customsearch/v1?alt=atom&cx=010722013183089041389:ab5yj_rbe5q&key=AIzaSyAN80EPArspHpyxtisnqFRSe0fCkOW8w_k&q=MicroStrategy';
      con_str_wallet_path       CONSTANT VARCHAR2 (50) := 'file:C:\oracle\product\11.2.0';
      con_str_wallet_pass       CONSTANT VARCHAR2 (50) := 'Lepanto1571';
      req                                UTL_HTTP.req;
      resp                               UTL_HTTP.resp;
      name                               VARCHAR2 (256);
      VALUE                              VARCHAR2 (1024);
      l_clob                             CLOB;
      l_text                             VARCHAR2 (32767);
      l_xml                              XMLTYPE;
      cursor_search_results              SYS_REFCURSOR;
      v_title                            VARCHAR2 (1024);
      v_link                             VARCHAR2 (4000);
      v_description                      CLOB;
      v_pubdate                          VARCHAR2 (20);
      v_tab                              mstr_goog_rss_type := mstr_goog_rss_type ();
   BEGIN
      -- Initialize the CLOB.
      DBMS_LOB.createtemporary ( l_clob, FALSE);
      -- When going through a firewall, pass requests through this host.
      -- Specify sites inside the firewall that don't need the proxy host.
      UTL_HTTP.set_proxy ('10.234.23.117:8080');
      UTL_HTTP.set_wallet ( PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);

      -- Ask UTL_HTTP not to raise an exception for 4xx and 5xx status codes,
      -- rather than just returning the text of the error page.
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);

      -- Begin retrieving this Web page.
      req         := UTL_HTTP.begin_request (url);

      -- Identify ourselves. Some sites serve special pages for particular browsers.
      UTL_HTTP.set_header ( req, 'User-Agent', 'Mozilla/4.0');

      BEGIN
         -- Start receiving the HTML text.
         resp        := UTL_HTTP.get_response (req);

         LOOP
            --UTL_HTTP.read_line ( resp, VALUE);
            --DBMS_OUTPUT.put_line (VALUE);
            UTL_HTTP.read_text ( resp, l_text, 32766);
            DBMS_LOB.writeappend ( l_clob, LENGTH (l_text), l_text);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (resp);
      l_xml       := xmltype (l_clob);
      DBMS_OUTPUT.put_line (l_xml.getclobval ());

      UPDATE XML_CONSTANTS
         SET CONST_VALUE  = l_xml
       WHERE CONST_ID = 99;

      -- Relase the resources associated with the temporary LOB.
      DBMS_LOB.freetemporary (l_clob);

      OPEN cursor_search_results FOR
         SELECT EXTRACTVALUE ( VALUE (p), '/entry/title') title
               ,EXTRACTVALUE ( VALUE (p), '/entry/link') link
               ,EXTRACTVALUE ( VALUE (p), '/entry/description') description
               ,EXTRACTVALUE ( VALUE (p), '/entry/pubDate') pubdate
           FROM TABLE (
                   XMLSEQUENCE (
                      EXTRACT ( l_xml, '/feed/entry', 'xmlns="http://www.w3.org/2005/Atom" xmlns:cse="http://schemas.google.com/cseapi/2010" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/'))) p;

      LOOP
         FETCH cursor_search_results
         INTO v_title, v_link, v_description, v_pubdate; --, v_link, v_location, v_industry;

         DBMS_OUTPUT.put_line (v_title);

         EXIT WHEN cursor_search_results%NOTFOUND;

         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_goog_rss_row_type ('google'
                                   ,v_title
                                   ,v_link
                                   ,v_description
                                   ,v_pubdate);
      END LOOP;
   --RETURN v_tab;
   END;
   */
END;
/
