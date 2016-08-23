DROP PACKAGE BODY PKG_HARVEST;

CREATE OR REPLACE PACKAGE BODY          PKG_HARVEST
IS
   FUNCTION account_who_am_i
      RETURN XMLTYPE
   IS
      var_http_api_request   VARCHAR2 (1023) := 'account/who_am_i';
      l_xml_return_data      XMLTYPE;
   BEGIN
      init;
      get_request (con_str_api_request_url || var_http_api_request);
      http_resp := UTL_HTTP.get_response (http_req);
      DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
      DBMS_LOB.createtemporary (l_uncompressed_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw (http_resp, l_raw, 32766);
            DBMS_LOB.writeappend (l_gzcompressed_blob,
                                  UTL_RAW.LENGTH (l_raw),
                                  l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_COMPRESS.lz_uncompress (src   => l_gzcompressed_blob,
                                  dst   => l_uncompressed_blob);
      --DBMS_OUTPUT.put_line ('Uncompressed Data: ' || UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      l_xml_return_data :=
         xmltype (UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob),
                  NULL,
                  1,
                  1);
      DBMS_LOB.freetemporary (l_gzcompressed_blob);
      DBMS_LOB.freetemporary (l_uncompressed_blob);
      UTL_HTTP.end_response (http_resp);
      RETURN l_xml_return_data;
   END account_who_am_i;

   FUNCTION projects
      RETURN XMLTYPE
   IS
      var_http_api_request   VARCHAR2 (1023) := 'projects';
      l_xml_return_data      XMLTYPE;
   BEGIN
      init;
      get_request (con_str_api_request_url || var_http_api_request);
      http_resp := UTL_HTTP.get_response (http_req);
      DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
      DBMS_LOB.createtemporary (l_uncompressed_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw (http_resp, l_raw, 32766);
            DBMS_LOB.writeappend (l_gzcompressed_blob,
                                  UTL_RAW.LENGTH (l_raw),
                                  l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_COMPRESS.lz_uncompress (src   => l_gzcompressed_blob,
                                  dst   => l_uncompressed_blob);
      --DBMS_OUTPUT.put_line ('Uncompressed Data: ' || UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      l_xml_return_data :=
         xmltype (UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob),
                  NULL,
                  1,
                  1);
      DBMS_LOB.freetemporary (l_gzcompressed_blob);
      DBMS_LOB.freetemporary (l_uncompressed_blob);
      UTL_HTTP.end_response (http_resp);
      RETURN l_xml_return_data;
   END projects;

   FUNCTION tasks
      RETURN XMLTYPE
   IS
      var_http_api_request   VARCHAR2 (1023) := 'tasks';
      l_xml_return_data      XMLTYPE;
   BEGIN
      init;
      get_request (con_str_api_request_url || var_http_api_request);
      http_resp := UTL_HTTP.get_response (http_req);
      DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
      DBMS_LOB.createtemporary (l_uncompressed_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw (http_resp, l_raw, 32766);
            DBMS_LOB.writeappend (l_gzcompressed_blob,
                                  UTL_RAW.LENGTH (l_raw),
                                  l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      UTL_COMPRESS.lz_uncompress (src   => l_gzcompressed_blob,
                                  dst   => l_uncompressed_blob);
      --DBMS_OUTPUT.put_line ('Uncompressed Data: ' || UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      l_xml_return_data :=
         xmltype (UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob),
                  NULL,
                  1,
                  1);
      DBMS_LOB.freetemporary (l_gzcompressed_blob);
      DBMS_LOB.freetemporary (l_uncompressed_blob);
      UTL_HTTP.end_response (http_resp);
      RETURN l_xml_return_data;
   END tasks;

   FUNCTION daily_add (p_project_id   IN NUMBER,
                       p_task_id      IN NUMBER,
                       p_notes        IN VARCHAR2)
      RETURN XMLTYPE
   IS
      http_method     CONSTANT VARCHAR2 (5) := 'POST';
      var_http_api_request     VARCHAR2 (1023) := 'daily/add';
      var_http_api_post_data   VARCHAR2 (32767)
         :=    '<?xml version="1.0" encoding="utf-8"?><request><notes>'
            || '<![CDATA['
            || urlencode_advanced (p_notes)
            || ']]>'
            || '</notes><hours>'
            || TO_CHAR (1)
            || '</hours><project_id type="integer">'
            || p_project_id
            || '</project_id><task_id type="integer">'
            || p_task_id
            || '</task_id><spent_at type="date">'
            || TO_CHAR (SYSDATE,
                        'Dy, DD Mon YYYY',
                        'nls_date_language = american')
            || '</spent_at></request>';
      l_xml_return_data        XMLTYPE;
   BEGIN
      init;
      DBMS_OUTPUT.put_line ('Data: ' || var_http_api_post_data);
      post_request (con_str_api_request_url || var_http_api_request,
                    var_http_api_post_data);
      http_resp := UTL_HTTP.get_response (http_req);
      --DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
      DBMS_LOB.createtemporary (l_uncompressed_blob, FALSE);

      --      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      --      LOOP
      --         UTL_HTTP.get_header (http_resp,
      --                              i,
      --                              var_http_header_name,
      --                              var_http_header_value);
      --      --DBMS_OUTPUT.put_line (var_http_header_name || ': ' || var_http_header_value);
      --      END LOOP;
      BEGIN
         LOOP
            UTL_HTTP.read_raw (http_resp, l_raw, 32766);
            --            DBMS_LOB.writeappend (l_gzcompressed_blob, UTL_RAW.LENGTH (l_raw), l_raw);
            DBMS_LOB.writeappend (l_uncompressed_blob,
                                  UTL_RAW.LENGTH (l_raw),
                                  l_raw);
         --DBMS_OUTPUT.put_line ( 'Resp: ' || l_raw);
         --UTL_HTTP.read_line (http_resp, var_http_resp_value, TRUE);
         --DBMS_OUTPUT.put_line ('Resp: ' || var_http_resp_value);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;

      --UTL_COMPRESS.lz_uncompress (src => l_gzcompressed_blob, dst => l_uncompressed_blob);
      --DBMS_OUTPUT.put_line ('Uncompressed Data: ' || UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      --DBMS_LOB.freetemporary (l_gzcompressed_blob);
      l_xml_return_data :=
         XMLTYPE (UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      DBMS_LOB.freetemporary (l_uncompressed_blob);
      UTL_HTTP.end_response (http_resp);
      RETURN l_xml_return_data;
   EXCEPTION
      WHEN OTHERS
      THEN
         UTL_HTTP.end_response (http_resp);
         DBMS_OUTPUT.put_line (
               '<error>'
            || SQLERRM
            || ' - '
            || DBMS_UTILITY.format_error_backtrace
            || '</error>');
         RETURN l_xml_return_data;
   END daily_add;

   PROCEDURE daily_add (p_project_id   IN NUMBER,
                        p_task_id      IN NUMBER,
                        p_notes        IN VARCHAR2)
   IS
      l_xml_return_data   XMLTYPE;
   BEGIN
      l_xml_return_data := daily_add (p_project_id, p_task_id, p_notes);
   END daily_add;

   PROCEDURE init
   IS
   BEGIN
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH       => pq_constants.con_str_wallet_path,
                           password   => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);
   END init;

   PROCEDURE get_request (p_str_api_request_url IN VARCHAR2)
   IS
   BEGIN
      http_req :=
         UTL_HTTP.begin_request (p_str_api_request_url,
                                 'GET',
                                 UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r       => http_req,
                           name    => 'Accept',
                           VALUE   => 'application/xml');
      UTL_HTTP.set_header (r       => http_req,
                           name    => 'Accept-Encoding',
                           VALUE   => 'gzip,deflate');
      UTL_HTTP.SET_AUTHENTICATION (http_req,
                                   con_str_api_username,
                                   con_str_api_password);
   END get_request;

   PROCEDURE post_request (p_str_api_request_url   IN VARCHAR2,
                           p_http_api_post_data    IN VARCHAR2)
   IS
   BEGIN
      http_req :=
         UTL_HTTP.begin_request (p_str_api_request_url,
                                 'POST',
                                 UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r       => http_req,
                           name    => 'Accept',
                           VALUE   => 'application/xml');
      UTL_HTTP.set_header (r       => http_req,
                           name    => 'Accept-Encoding',
                           VALUE   => 'gzip,deflate');
      UTL_HTTP.set_header (r       => http_req,
                           NAME    => 'Content-Type',
                           VALUE   => 'application/atom+xml;charset=utf-8');
      --      UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/atom+xml;charset=iso-8859-1');
      UTL_HTTP.set_header (r       => http_req,
                           NAME    => 'Content-Length',
                           VALUE   => LENGTH (p_http_api_post_data));
      UTL_HTTP.SET_AUTHENTICATION (http_req,
                                   con_str_api_username,
                                   con_str_api_password);
      UTL_HTTP.set_cookie_support (r => http_req, ENABLE => TRUE);
      UTL_HTTP.write_text (http_req, p_http_api_post_data);
   END post_request;

   FUNCTION urlencode_advanced (p_str         IN VARCHAR2,
                                p_firsttime   IN BOOLEAN := TRUE)
      RETURN VARCHAR2
   AS
      l_tmp    VARCHAR2 (32767);
      l_out    VARCHAR2 (32767);
      --l_bad                              VARCHAR2 (100) DEFAULT ' ,>%}\~];?@&<#{|^[`/:=$+''"';
      l_char   VARCHAR2 (10);
   BEGIN
      FOR i IN 1 .. NVL (LENGTH (p_str), 0)
      LOOP
         l_char := SUBSTR (p_str, i, 1);

         BEGIN
            SELECT "Entity Name"
              INTO l_char
              FROM UTL_ENCODE_CHARS
             WHERE "Char" = l_char AND "Entity Name" IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         l_tmp := l_tmp || l_char;
      END LOOP;

      FOR i IN 1 .. NVL (LENGTH (l_tmp), 0)
      LOOP
         l_char := SUBSTR (l_tmp, i, 1);

         --         IF l_char = ' '
         --         THEN
         --            l_char := '%20';
         --         ELSE
         --            BEGIN
         --               SELECT UPPER ("URL Encode")
         --                 INTO l_char
         --                 FROM UTL_ENCODE_CHARS
         --                WHERE "Char" = l_char;
         --            EXCEPTION
         --               WHEN NO_DATA_FOUND
         --               THEN
         --                  NULL;
         --            END;
         --         END IF;

         l_out := l_out || l_char;
      END LOOP;

      RETURN l_out;
   END urlencode_advanced;
END;
/
