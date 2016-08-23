DROP PACKAGE BODY PQ_CONSTANTS;

CREATE OR REPLACE PACKAGE BODY          pq_constants
AS
   PROCEDURE set_proxy
   AS
   BEGIN
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   END set_proxy;

   PROCEDURE set_wallet
   AS
   BEGIN
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   END set_wallet;

   PROCEDURE http_init (p_response_error_check IN BOOLEAN := FALSE, p_detailed_excp_support IN BOOLEAN := FALSE)
   AS
   BEGIN
      UTL_HTTP.set_proxy (proxy => pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (enable => p_response_error_check);
      UTL_HTTP.set_detailed_excp_support (enable => p_detailed_excp_support);
   END http_init;

   FUNCTION http_begin_request (p_url IN VARCHAR2, p_method IN VARCHAR2 := 'GET', p_gzip IN BOOLEAN := TRUE)
      RETURN UTL_HTTP.req
   AS
      l_http_req   UTL_HTTP.req;
   BEGIN
      l_http_req := UTL_HTTP.begin_request (p_url, p_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (l_http_req, 'Accept-Charset', 'utf-8');

      IF p_gzip
      THEN
         UTL_HTTP.set_header (r => l_http_req, name => 'Accept-Encoding', VALUE => 'gzip,deflate');
      END IF;

      RETURN l_http_req;
   END http_begin_request;

   PROCEDURE http_return_response (p_http_req IN OUT UTL_HTTP.req, p_content IN OUT CLOB, p_gzip IN BOOLEAN := TRUE)
   AS
      l_http_resp           UTL_HTTP.resp;
      l_gzcompressed_blob   BLOB;
      l_uncompressed_blob   BLOB;
      l_raw                 RAW (32767);
      v_blob_offset         NUMBER := 1;
      v_clob_offset         NUMBER := 1;
      v_lang_context        NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
      v_warning             NUMBER := DBMS_LOB.NO_WARNING;
   BEGIN
      l_http_resp := UTL_HTTP.get_response (p_http_req);
      DBMS_LOB.createtemporary (l_gzcompressed_blob, FALSE);
      DBMS_LOB.createtemporary (l_uncompressed_blob, FALSE);

      BEGIN
         LOOP
            UTL_HTTP.read_raw (l_http_resp, l_raw, 32766);
            DBMS_LOB.writeappend (l_gzcompressed_blob, UTL_RAW.LENGTH (l_raw), l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            NULL;
      END;
      UTL_HTTP.end_response (l_http_resp);

      IF p_gzip
      THEN
         UTL_COMPRESS.lz_uncompress (src => l_gzcompressed_blob, dst => l_uncompressed_blob);
         p_content := UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob);
      ELSE
         p_content := UTL_RAW.CAST_TO_VARCHAR2 (l_gzcompressed_blob);
         --l_uncompressed_blob := l_gzcompressed_blob;
         --         DBMS_LOB.CONVERTTOCLOB (dest_lob       => p_content,
         --                                 src_blob       => l_gzcompressed_blob,
         --                                 amount         => DBMS_LOB.LOBMAXSIZE,
         --                                 dest_offset    => 1,
         --                                 src_offset     => 1,
         --                                 blob_csid      => DBMS_LOB.default_csid,
         --                                 lang_context   => DBMS_LOB.default_lang_ctx,
         --                                 warning        => DBMS_LOB.NO_WARNING);
         --p_content := f (l_gzcompressed_blob);
--         DBMS_LOB.CONVERTTOCLOB (p_content,
--                                 l_gzcompressed_blob,
--                                 DBMS_LOB.LOBMAXSIZE,
--                                 v_clob_offset,
--                                 v_blob_offset,
--                                 1,
--                                 v_lang_context,
--                                 v_warning);
      END IF;

      --DBMS_OUTPUT.put_line ('Uncompressed Data: ' || UTL_RAW.CAST_TO_VARCHAR2 (l_uncompressed_blob));
      DBMS_LOB.freetemporary (l_gzcompressed_blob);
      DBMS_LOB.freetemporary (l_uncompressed_blob);
   END http_return_response;
END pq_constants;
/
