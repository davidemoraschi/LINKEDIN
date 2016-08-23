DROP PACKAGE OBJ_GOOG_OAUTH2_AUTH;

CREATE OR REPLACE PACKAGE          obj_goog_oauth2_auth
AS
   con_str_goog_auth_endpoint   CONSTANT VARCHAR2 (100) := 'https://accounts.google.com/o/oauth2/auth';
   con_str_goog_auth_scope      CONSTANT VARCHAR2 (100) := 'https://www.googleapis.com/auth/analytics.readonly';
   con_str_goog_client_id       CONSTANT VARCHAR2 (100) := '560216110065.apps.googleusercontent.com';
   con_str_goog_client_secret   CONSTANT VARCHAR2 (100) := '50sQBHAsM76cVPuMNH6xaE2Z';
   con_str_mstr_auth_callback   CONSTANT VARCHAR2 (100) := 'http://moraschi.eu:8081/sso/obj_goog_oauth2_auth_cb.jsp';

   PROCEDURE jsp (state IN VARCHAR2);
END obj_goog_oauth2_auth;
/
