DROP PACKAGE BODY PKG_FRESHBOOKS_TIME_ENTRY;

CREATE OR REPLACE PACKAGE BODY pkg_freshbooks_time_entry
IS
   PROCEDURE "create" (p_client_id IN NUMBER := 3, p_project_id IN NUMBER := 2, p_task_id IN NUMBER := 9
     ,p_date IN VARCHAR2 := TO_CHAR (SYSDATE, 'yyyy-mm-dd'), p_hours IN VARCHAR2 := 1)
   IS
   BEGIN
      --      var_calendar_entry := '<?xml version="1.0" encoding="utf-8"?><request method="language.list"></request>';
      var_calendar_entry :=
         '<?xml version="1.0" encoding="utf-8"?><request method="time_entry.create"><time_entry><project_id>2</project_id><task_id>9</task_id><hours>'
         || p_hours
         || '</hours><notes>Database usage</notes><date>'
         || p_date
         || '</date></time_entry></request>';
      --UTL_HTTP.set_proxy ('10.234.23.117:8080');
      UTL_HTTP.set_wallet (PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);

      var_http_request :=
         UTL_HTTP.begin_request (url => 'https://moraschi.freshbooks.com/api/2.1/xml-in', method => 'POST'
        ,http_version => UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_authentication (var_http_request, '6aeb006f0b13a4f5b87a572daecf4405', 'x', 'Basic', FALSE);
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Type', VALUE => 'application/atom+xml;charset=iso-8859-1');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Length', VALUE => LENGTH (var_calendar_entry));
      UTL_HTTP.set_cookie_support (r => var_http_request, ENABLE => TRUE);
      UTL_HTTP.write_text (var_http_request, var_calendar_entry);
      var_http_response := UTL_HTTP.get_response (r => var_http_request);

      BEGIN
         ret_val := var_http_response.status_code || ' - ' || var_http_response.reason_phrase;

         LOOP
            UTL_HTTP.read_line (r => var_http_response, DATA => var_http_value, remove_crlf => TRUE);
            DBMS_OUTPUT.put_line (VAR_HTTP_VALUE);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => var_http_response);
      END;
   END "create";
END pkg_freshbooks_time_entry;
/
