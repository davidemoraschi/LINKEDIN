DROP PACKAGE BODY PKG_AMAZON_AWS_SES;

CREATE OR REPLACE PACKAGE BODY          PKG_AMAZON_AWS_SES
IS
   FUNCTION SendEmail (p_Sender      IN VARCHAR2,
                       p_Recipient   IN VARCHAR2,
                       p_Subject     IN VARCHAR2,
                       p_Html_Body   IN VARCHAR2)
      RETURN BOOLEAN
   IS
      var_str_AmazonSES_api_Endpoint   VARCHAR2 (1000) := 'https://email.us-east-1.amazonaws.com/';
      var_str_AmazonSES_api_Action     VARCHAR2 (1000) := 'Action=SendEmail';
      var_str_AmazonSES_api_url        VARCHAR2 (32767)
                                          :=    var_str_AmazonSES_api_Endpoint
                                             || '?'
                                             || var_str_AmazonSES_api_Action
                                             || '&Source='
                                             || utl_linkedin.urlencode (p_Sender)
                                             || '&Destination.ToAddresses.member.1='
                                             || utl_linkedin.urlencode (p_Recipient)
                                             || '&Message.Subject.Data='
                                             || REPLACE (utl_linkedin.urlencode (p_Subject), ' ', '%20')
                                             || '&Message.Body.Html.Data='
                                             || REPLACE (
                                                   REPLACE (REPLACE (utl_linkedin.urlencode (p_Html_Body), ' ', '%20'),
                                                            CHR (10)),
                                                   CHR (13));
      http_method                      CONSTANT VARCHAR2 (5) := 'GET';
      http_req                         UTL_HTTP.req;
      http_resp                        UTL_HTTP.resp;
      var_http_header_name             VARCHAR2 (255);
      var_http_header_value            VARCHAR2 (1023);
      var_str_AWSDateHeader            VARCHAR2 (250)
                                          := TO_CHAR (SYSTIMESTAMP,
                                                      'Dy, DD Mon YYYY HH24:MI:SS ',
                                                      'NLS_DATE_LANGUAGE=ENGLISH')
                                             || REPLACE (TO_CHAR (SYSTIMESTAMP, 'TZR', 'NLS_DATE_LANGUAGE=ENGLISH'),
                                                         ':',
                                                         '');
      var_str_AWSRequestSignature      VARCHAR2 (2500);
      var_str_XAmznAuthorization       VARCHAR2 (2500);
      var_http_resp_value              VARCHAR2 (32767);

      l_clob                           CLOB;
      l_xml                            XMLTYPE;
   BEGIN
      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      UTL_HTTP.set_response_error_check (FALSE);
      UTL_HTTP.set_detailed_excp_support (FALSE);

      var_str_AWSRequestSignature :=
         UTL_RAW.
         cast_to_varchar2 (
            UTL_ENCODE.
            base64_encode (
               DBMS_CRYPTO.
               mac (UTL_I18N.string_to_raw (var_str_AWSDateHeader, 'AL32UTF8'),
                    DBMS_CRYPTO.hmac_sh1,
                    UTL_I18N.string_to_raw (pq_constants.con_str_AWSSecretKeyId, 'AL32UTF8'))));

      var_str_XAmznAuthorization :=
            'AWS3-HTTPS AWSAccessKeyId='
         || pq_constants.con_str_AWSAccessKeyId
         || ', Algorithm=HmacSHA1, Signature='
         || var_str_AWSRequestSignature;

      --      DBMS_OUTPUT.put_line ('var_str_AmazonSES_api_url: ' || var_str_AmazonSES_api_url);
      --      DBMS_OUTPUT.put_line ('var_str_AWSDateHeader: ' || var_str_AWSDateHeader);
      --      DBMS_OUTPUT.put_line ('var_str_AWSRequestSignature: ' || var_str_AWSRequestSignature);
      --      DBMS_OUTPUT.put_line ('var_str_XAmznAuthorization: ' || var_str_XAmznAuthorization);

      http_req := UTL_HTTP.begin_request (var_str_AmazonSES_api_url, http_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r => http_req, name => 'Date', VALUE => var_str_AWSDateHeader);
      UTL_HTTP.set_header (r => http_req, name => 'X-Amzn-Authorization', VALUE => var_str_XAmznAuthorization);
      http_resp := UTL_HTTP.get_response (http_req);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp,
                              i,
                              var_http_header_name,
                              var_http_header_value);
      --DBMS_OUTPUT.put_line (var_http_header_name || var_http_header_value);
      END LOOP;

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

      --l_xml := xmltype (l_clob);
      UTL_HTTP.end_response (http_resp);
      --DBMS_OUTPUT.put_line (l_xml.getclobval ());
      DBMS_LOB.freetemporary (l_clob);
      RETURN TRUE;
   END SendEmail;
END;
/
