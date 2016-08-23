DROP PACKAGE OBJ_GOOG_OAUTH2_AUTH_CB;

CREATE OR REPLACE PACKAGE          obj_goog_oauth2_auth_cb
AS
   http_method                   CONSTANT VARCHAR2 (5) := 'POST';
   con_str_goog_token_endpoint   CONSTANT VARCHAR2 (100) := 'https://accounts.google.com/o/oauth2/token';

   PROCEDURE jsp (state IN VARCHAR2 := NULL, code IN VARCHAR2 := NULL, error IN VARCHAR2 := NULL);
END obj_goog_oauth2_auth_cb;
/
