DROP PACKAGE BODY MSTR_SOAP_EXECUTEGRAPH;

CREATE OR REPLACE PACKAGE BODY          mstr_soap_executegraph
AS
   PROCEDURE png (preportid IN VARCHAR2)
   IS
      l_blob                             BLOB;
      r_blob                             BLOB;
      l_raw                              RAW (32767);
      http_request                       UTL_HTTP.req;
      http_response                      UTL_HTTP.resp;
      vstart                             NUMBER := 1;
      len                                NUMBER;
      x                                  NUMBER;
   BEGIN
      soap_request :=
         XMLTYPE (
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://microstrategy.com/webservices/v1_0">

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
            || preportid
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

               <v1:eResults>MWSReturnGraphBytes</v1:eResults>

            </v1:ExecuteReport>

         </soapenv:Body>

      </soapenv:Envelope>

      ');
      http_request := UTL_HTTP.begin_request ( con_str_ws_url, con_http_ws_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header ( http_request, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header ( http_request, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header ( http_request, 'SOAPAction', con_str_ws_action);
      UTL_HTTP.write_text ( http_request, soap_request.getstringval ());
      http_response := UTL_HTTP.get_response (http_request);
      DBMS_LOB.createtemporary ( l_blob, FALSE);
      DBMS_LOB.createtemporary ( r_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw ( http_response, l_raw, 32767);
            DBMS_LOB.writeappend ( l_blob, UTL_RAW.LENGTH (l_raw), l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      --      INSERT INTO utl_http_blob_temp
      --           VALUES (utl_http_clob_temp_seq.nextval, NULL, l_blob);

      UTL_HTTP.end_response (http_response);
      vstart      := DBMS_LOB.INSTR ( l_blob, UTL_RAW.cast_to_raw ('PNG')) - 1;
      len         := DBMS_LOB.INSTR ( l_blob, UTL_RAW.cast_to_raw ('END')) + 4 - vstart;
      DBMS_LOB.COPY (r_blob
                    ,l_blob
                    ,len
                    ,1
                    ,vstart);
      x           := len;
      /*
            bytelen := 32000;
            l_output := UTL_FILE.fopen ('DATA_PUMP_DIR', preportid || '.png', 'wb', 32760);
            -- if small enough for a single write
            IF len < 32760
            THEN
               DBMS_LOB.READ (l_blob, len, vstart, my_vr);
               UTL_FILE.put_raw (l_output, my_vr);
               UTL_FILE.fflush (l_output);
            ELSE   -- write in pieces
               vstart :=   --1;
                        DBMS_LOB.INSTR (l_blob, UTL_RAW.cast_to_raw ('PNG')) - 1;   --application/octet-stream

               WHILE vstart < len AND bytelen > 0
               LOOP
                  DBMS_LOB.READ (l_blob, bytelen, vstart, my_vr);
                  UTL_FILE.put_raw (l_output, my_vr);
                  UTL_FILE.fflush (l_output);
                  -- set the start position for the next cut
                  vstart := vstart + bytelen;
                  -- set the end position if less than 32000 bytes
                  x := x - bytelen;

                  IF x < 32000
                  THEN
                     bytelen := x;
                  END IF;
               END LOOP;
            END IF;
            UTL_FILE.fclose (l_output);
      */
      OWA_UTIL.mime_header ( 'image/png', FALSE, 'utf-8');
      HTP.p ('Content-Length: ' || (DBMS_LOB.getlength (r_blob)) || crlf);
      OWA_UTIL.http_header_close;
      WPG_DOCLOAD.download_file (r_blob);
      DBMS_LOB.freetemporary (l_blob);
      DBMS_LOB.freetemporary (r_blob);
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput ( SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END png;

   PROCEDURE png ( pprojectid IN VARCHAR2, preportid IN VARCHAR2)
   IS
      l_blob                             BLOB;
      r_blob                             BLOB;
      l_raw                              RAW (32767);
      http_request                       UTL_HTTP.req;
      http_response                      UTL_HTTP.resp;
      vstart                             NUMBER := 1;
      len                                NUMBER;
      x                                  NUMBER;
   BEGIN
      soap_request :=
         XMLTYPE (
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://microstrategy.com/webservices/v1_0">

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
            || pprojectid
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
            || preportid
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

               <v1:eResults>MWSReturnGraphBytes</v1:eResults>

            </v1:ExecuteReport>

         </soapenv:Body>

      </soapenv:Envelope>

      ');
      http_request := UTL_HTTP.begin_request ( con_str_ws_url, con_http_ws_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header ( http_request, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header ( http_request, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header ( http_request, 'SOAPAction', con_str_ws_action);
      UTL_HTTP.write_text ( http_request, soap_request.getstringval ());
      http_response := UTL_HTTP.get_response (http_request);
      DBMS_LOB.createtemporary ( l_blob, FALSE);
      DBMS_LOB.createtemporary ( r_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw ( http_response, l_raw, 32767);
            DBMS_LOB.writeappend ( l_blob, UTL_RAW.LENGTH (l_raw), l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      --      INSERT INTO utl_http_blob_temp
      --           VALUES (utl_http_clob_temp_seq.nextval, NULL, l_blob);

      UTL_HTTP.end_response (http_response);
      vstart      := DBMS_LOB.INSTR ( l_blob, UTL_RAW.cast_to_raw ('PNG')) - 1;
      len         := DBMS_LOB.INSTR ( l_blob, UTL_RAW.cast_to_raw ('END')) + 4 - vstart;
      DBMS_LOB.COPY (r_blob
                    ,l_blob
                    ,len
                    ,1
                    ,vstart);
      x           := len;
      /*
            bytelen := 32000;
            l_output := UTL_FILE.fopen ('DATA_PUMP_DIR', preportid || '.png', 'wb', 32760);
            -- if small enough for a single write
            IF len < 32760
            THEN
               DBMS_LOB.READ (l_blob, len, vstart, my_vr);
               UTL_FILE.put_raw (l_output, my_vr);
               UTL_FILE.fflush (l_output);
            ELSE   -- write in pieces
               vstart :=   --1;
                        DBMS_LOB.INSTR (l_blob, UTL_RAW.cast_to_raw ('PNG')) - 1;   --application/octet-stream

               WHILE vstart < len AND bytelen > 0
               LOOP
                  DBMS_LOB.READ (l_blob, bytelen, vstart, my_vr);
                  UTL_FILE.put_raw (l_output, my_vr);
                  UTL_FILE.fflush (l_output);
                  -- set the start position for the next cut
                  vstart := vstart + bytelen;
                  -- set the end position if less than 32000 bytes
                  x := x - bytelen;

                  IF x < 32000
                  THEN
                     bytelen := x;
                  END IF;
               END LOOP;
            END IF;
            UTL_FILE.fclose (l_output);
      */
      OWA_UTIL.mime_header ( 'image/png', FALSE, 'utf-8');
      HTP.p ('Content-Length: ' || (DBMS_LOB.getlength (r_blob)) || crlf);
      OWA_UTIL.http_header_close;
      WPG_DOCLOAD.download_file (r_blob);
      DBMS_LOB.freetemporary (l_blob);
      DBMS_LOB.freetemporary (r_blob);
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput ( SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END png;
END mstr_soap_executegraph;
/
