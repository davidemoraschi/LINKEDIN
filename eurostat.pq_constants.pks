DROP PACKAGE PQ_CONSTANTS;

CREATE OR REPLACE PACKAGE          pq_constants
AS
   CONST_NL_CHAR               CONSTANT VARCHAR2 (1) := CHR (10);
   con_str_http_get            CONSTANT VARCHAR2 (5) := 'GET';
   con_str_http_post           CONSTANT VARCHAR2 (5) := 'POST';
   con_str_http_proxy          CONSTANT VARCHAR2 (50) := NULL;                                             --'10.234.23.117:8080';
   con_str_wallet_path         CONSTANT VARCHAR2 (50) := 'file:/usr/lib/oracle/xe/wallet';
   con_str_wallet_pass         CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   con_str_hostname            CONSTANT VARCHAR2 (1024) := 'http://23.21.233.106';
   con_str_hostname_port       CONSTANT VARCHAR2 (1024) := 'http://23.21.233.106:8081';
   --linkedin_shares_api_url   VARCHAR2 (1000) := 'http://api.linkedin.com/v1/people/~/shares';
   con_num_timestamp_tz_diff   CONSTANT NUMBER := 0;

   con_str_AWSAccessKeyId      CONSTANT VARCHAR2 (1024) := '04RWSJQ86Z9RGQFHJM82';
   con_str_AWSSecretKeyId      CONSTANT VARCHAR2 (1024) := 'QOe+0daE61eF7qURmz87yaP8VSY3H54u5sAAYa+N';

   PROCEDURE set_proxy;

   PROCEDURE set_wallet;

   PROCEDURE http_init (p_response_error_check IN BOOLEAN := FALSE, p_detailed_excp_support IN BOOLEAN := FALSE);

   FUNCTION http_begin_request (p_url IN VARCHAR2, p_method IN VARCHAR2 := 'GET', p_gzip IN BOOLEAN := TRUE)
      RETURN UTL_HTTP.req;

   PROCEDURE http_return_response (p_http_req IN OUT UTL_HTTP.req, p_content IN OUT CLOB, p_gzip IN BOOLEAN := TRUE);
--RETURN UTL_HTTP.req;
END pq_constants;
/
