DROP PACKAGE PKG_HARVEST;

CREATE OR REPLACE PACKAGE          PKG_HARVEST
IS
   con_str_api_request_url   CONSTANT VARCHAR2 (1000) := 'https://dmoraschi.harvestapp.com/';
   con_str_api_username      CONSTANT VARCHAR2 (1000) := 'dmoraschi@gmail.com';
   con_str_api_password      CONSTANT VARCHAR2 (1000) := 'araknion';
   http_req                           UTL_HTTP.req;
   http_resp                          UTL_HTTP.resp;
   var_http_resp_value                VARCHAR2 (32767);
   l_gzcompressed_blob                BLOB;
   l_uncompressed_blob                BLOB;
   l_raw                              RAW (32767);

   FUNCTION account_who_am_i
      RETURN XMLTYPE;

   FUNCTION projects
      RETURN XMLTYPE;

   FUNCTION tasks
      RETURN XMLTYPE;

   FUNCTION daily_add (p_project_id IN NUMBER, p_task_id IN NUMBER, p_notes IN VARCHAR2)
      RETURN XMLTYPE;

   PROCEDURE daily_add (p_project_id IN NUMBER, p_task_id IN NUMBER, p_notes IN VARCHAR2);
--      RETURN XMLTYPE;

   PROCEDURE init;

   PROCEDURE get_request (p_str_api_request_url IN VARCHAR2);

   PROCEDURE post_request (p_str_api_request_url IN VARCHAR2, p_http_api_post_data IN VARCHAR2);

   FUNCTION urlencode_advanced (p_str IN VARCHAR2, p_firsttime IN BOOLEAN := TRUE)
      RETURN VARCHAR2;
END;
/
