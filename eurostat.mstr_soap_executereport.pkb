DROP PACKAGE BODY MSTR_SOAP_EXECUTEREPORT;

CREATE OR REPLACE PACKAGE BODY          mstr_soap_executereport
AS
   PROCEDURE jsp (p_reportid IN VARCHAR2, p_format IN VARCHAR2 DEFAULT 'html', p_deliver_to VARCHAR2 DEFAULT NULL)
   IS
      con_xml_result_starttag   CONSTANT VARCHAR2 (20) := '<ns2:ResultXML>';
      con_xml_result_endtag     CONSTANT VARCHAR2 (20) := '</ns2:ResultXML>';
      con_num_bytes_of_data     CONSTANT PLS_INTEGER := 32767;
      http_request              UTL_HTTP.req;
      http_response             UTL_HTTP.resp;
      l_clob                    CLOB;
      l_raw                     RAW (32767);
      soap_startp               PLS_INTEGER;
      soap_length               PLS_INTEGER;
      xml_report                XMLTYPE;
      v_clob                    CLOB;
      v_obj_dropbox             dropbox;
   BEGIN
      soap_request :=
         XMLTYPE (
            xmlData      => '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://microstrategy.com/webservices/v1_0">
   <soapenv:Header>
   </soapenv:Header>
   <soapenv:Body>
      <v1:ExecuteReport>
         <!--Optional:-->
         <v1:cInfo>
            <!--Optional:-->
            <v1:Login>'
                           || con_str_mstrwsj_user
                           || '</v1:Login>
            <!--Optional:-->
            <v1:Password>'
                           || con_str_mstrwsj_password
                           || '</v1:Password>
            <!--Optional:-->
            <v1:ProjectName>'
                           || con_str_mstrwsj_project
                           || '</v1:ProjectName>
            <!--Optional:-->
            <v1:ProjectSource>'
                           || con_str_mstrwsj_server
                           || '</v1:ProjectSource>
            <!--Optional:-->
            <v1:AuthMode>MWSStandard</v1:AuthMode>
            <v1:HasHeuristics>false</v1:HasHeuristics>
            <v1:PortNumber>0</v1:PortNumber>
            <!--Optional:-->
            <v1:ClientIPAddress></v1:ClientIPAddress>
         </v1:cInfo>
         <!--Optional:-->
         <v1:sReportName></v1:sReportName>
         <!--Optional:-->
         <v1:sReportID>'
                           || p_reportid
                           || '</v1:sReportID>
         <!--Optional:-->
         <v1:sAnswerPrompt>
         </v1:sAnswerPrompt>
         <v1:eFlags>MWSUseDefaultPrompts</v1:eFlags>
         <!--Optional:-->
         <v1:ResultsWindow>
            <v1:MaxRows>1000</v1:MaxRows>
            <v1:MaxCols>100</v1:MaxCols>
            <v1:StartRow>0</v1:StartRow>
            <v1:StartCol>0</v1:StartCol>
            <v1:PopulatePageBy>true</v1:PopulatePageBy>
         </v1:ResultsWindow>
         <!--Optional:-->
         <v1:sStyle></v1:sStyle>
         <v1:eResults>MWSReturnAsXML</v1:eResults>
      </v1:ExecuteReport>
   </soapenv:Body>
</soapenv:Envelope>
',
            validated    => 1,
            wellformed   => 1);

      http_request :=
         UTL_HTTP.begin_request (url => con_str_ws_url, method => con_http_ws_method, http_version => UTL_HTTP.http_version_1_1);

      UTL_HTTP.set_header (r => http_request, name => 'Content-Type', VALUE => 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (r => http_request, name => 'Content-Length', VALUE => LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (r => http_request, name => 'SOAPAction', VALUE => con_str_ws_action);

      UTL_HTTP.write_text (r => http_request, data => soap_request.getstringval ());

      http_response := UTL_HTTP.get_response (r => http_request);

      DBMS_LOB.createtemporary (lob_loc => l_clob, cache => TRUE, dur => DBMS_LOB.CALL);

      BEGIN
         LOOP
            UTL_HTTP.read_raw (r => http_response, data => l_raw, len => con_num_bytes_of_data);
            DBMS_LOB.
            writeappend (
               lob_loc   => l_clob,
               amount    => LENGTH (UTL_RAW.cast_to_varchar2 (r => l_raw)),
               buffer    => SUBSTR (UTL_RAW.cast_to_varchar2 (r => l_raw), 1, LENGTH (UTL_RAW.cast_to_varchar2 (r => l_raw))));
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_HTTP.end_response (r => http_response);

      soap_startp := DBMS_LOB.INSTR (lob_loc => l_clob, pattern => con_xml_result_starttag) + LENGTH (con_xml_result_starttag);
      soap_length := DBMS_LOB.INSTR (lob_loc => l_clob, pattern => con_xml_result_endtag) - soap_startp;
      xml_report :=
         xmltype (
            xmlData      => DBMS_XMLGEN.
                           CONVERT (xmlData => SUBSTR (l_clob, soap_startp, soap_length), flag => DBMS_XMLGEN.ENTITY_DECODE),
            validated    => 1,
            wellformed   => 1);

      CASE UPPER (p_format)
         WHEN 'HTML'
         THEN
            v_clob := urifactory.geturi (url => con_http_xsl_uri).getclob ();
            xml_report := xml_report.transform (xsl => xmltype (xmlData => v_clob, validated => 1, wellformed => 1));

            CASE UPPER (p_deliver_to)
               WHEN 'DROPBOX'
               THEN
                  SELECT (obj_dropbox)
                    INTO v_obj_dropbox
                    FROM objs_dropbox
                   WHERE ACCOUNT = '35291135';                               --Luego hay que cambiar y poner la cuenta del usuario

                  v_clob := xml_report.getclobval ();
                  v_obj_dropbox.post_html_file (p_filecontent => v_clob, p_filename => p_reportid || '.html');
               ELSE
                  streamhtml (p_data_set => xml_report);
            END CASE;
         ELSE
            usage;
      END CASE;

      DBMS_LOB.freetemporary (lob_loc => l_clob);
   EXCEPTION
      WHEN OTHERS
      THEN
         senderroroutput (p_sqlerr => SQLERRM, p_error_backtrace => DBMS_UTILITY.format_error_backtrace);
   END jsp;

   PROCEDURE streamhtml (p_data_set XMLTYPE := NULL)
   IS
      v_data_blob    BLOB := NULL;
      l_len          PLS_INTEGER;
      v_doc_clob     CLOB := p_data_set.getclobval ();
      l_offset       PLS_INTEGER := 1;
      l_amount       PLS_INTEGER := 16000;
      l_buffer       VARCHAR2 (32767);
      l_buffer_raw   RAW (32767);
   BEGIN
      DBMS_LOB.createtemporary (lob_loc => v_data_blob, cache => TRUE, dur => DBMS_LOB.CALL);
      l_len := DBMS_LOB.getlength (lob_loc => v_doc_clob);

      WHILE l_offset < l_len
      LOOP
         DBMS_LOB.READ (lob_loc   => v_doc_clob,
                        amount    => l_amount,
                        offset    => l_offset,
                        buffer    => l_buffer);
         l_buffer_raw := UTL_RAW.cast_to_raw (c => l_buffer);
         DBMS_LOB.writeappend (LOB_LOC => v_data_blob, AMOUNT => UTL_RAW.LENGTH (l_buffer_raw), BUFFER => l_buffer_raw);
         l_offset := l_offset + l_amount;

         IF l_len - l_offset < 16000
         THEN
            l_amount := l_len - l_offset;
         END IF;
      END LOOP;

      OWA_UTIL.mime_header (ccontent_type => 'text/html', bclose_header => FALSE, ccharset => 'utf-8');
      HTP.p (cbuf => 'Content-Length: ' || (DBMS_LOB.getlength (LOB_LOC => v_data_blob)) || crlf);
      OWA_UTIL.http_header_close;
      WPG_DOCLOAD.download_file (p_blob => v_data_blob);
   END streamhtml;

   PROCEDURE usage
   IS
   BEGIN
      HTP.p (cbuf => 'Usage: mstr_soap_executereport.jsp?p_reportid=<>&p_format=[html],p_deliver_to=[dropbox]');
   END usage;

   PROCEDURE SendErrorOutput (p_sqlerr IN VARCHAR2, p_error_backtrace IN VARCHAR2)
   IS
   BEGIN
      OWA_UTIL.mime_header (ccontent_type => 'text/html', bclose_header => TRUE, ccharset => 'utf-8');
      HTP.
      p (cbuf => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
      HTP.p (cbuf => '<html xmlns="http://www.w3.org/1999/xhtml">');
      HTP.p (cbuf => '<head>');
      HTP.p (cbuf => '<link rel="Stylesheet" href="http://dl.dropbox.com/u/35291135/css/EUROSTAT.css" />');
      HTP.p (cbuf => '</head>');
      HTP.p (cbuf => '<body>');
      HTP.p (cbuf => '<div class="DefaultRedAndBlack">');
      HTP.p (cbuf => p_sqlerr);
      HTP.p (cbuf => '<br>' || p_error_backtrace);
      HTP.p (cbuf => '</div>');
      HTP.p (cbuf => '</body>');
      HTP.p (cbuf => '</html>');
   END SendErrorOutput;
END mstr_soap_executereport;
/
