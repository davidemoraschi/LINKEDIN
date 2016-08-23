DROP PACKAGE OBJ_GOOG_OAUTH2_PROFILES;

CREATE OR REPLACE PACKAGE          obj_goog_oauth2_profiles
AS
   PROCEDURE jsp ( --access_token IN VARCHAR2 := NULL, token_type IN VARCHAR2 := NULL,
                  state IN VARCHAR2 := NULL);
END obj_goog_oauth2_profiles;
/
