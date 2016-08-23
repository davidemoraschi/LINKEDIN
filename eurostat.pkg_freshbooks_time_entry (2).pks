DROP PACKAGE PKG_FRESHBOOKS_TIME_ENTRY;

CREATE OR REPLACE PACKAGE pkg_freshbooks_time_entry
IS
--   con_str_wallet_path   CONSTANT VARCHAR2 (50) := 'file:/u01/app/oracle/product/11.2.0/wallet';
   con_str_wallet_path   CONSTANT VARCHAR2 (50) := 'file:/mnt/oradata/wallet';
   con_str_wallet_pass   CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   var_http_request               UTL_HTTP.req;
   var_http_response              UTL_HTTP.resp;
   var_resp_header_name           VARCHAR2 (1024);
   var_resp_header_value          VARCHAR2 (1024);
   var_http_value                 VARCHAR2 (32767);
   var_http_value_raw             RAW (32767);
   var_calendar_entry             VARCHAR2 (32767);
   ret_val                        VARCHAR2 (1024);

   PROCEDURE "create" (p_client_id IN NUMBER := 3, p_project_id IN NUMBER := 2, p_task_id IN NUMBER := 9
     ,p_date IN VARCHAR2 := TO_CHAR (SYSDATE, 'yyyy-mm-dd'), p_hours IN VARCHAR2 := 1);
END pkg_freshbooks_time_entry;
/
