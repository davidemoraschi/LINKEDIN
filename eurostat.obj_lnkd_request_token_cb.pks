DROP PACKAGE OBJ_LNKD_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE          obj_lnkd_request_token_cb
AS
   PROCEDURE jsp (oauth_token      IN VARCHAR2:= NULL,
                  oauth_verifier   IN VARCHAR2:= NULL,
                  oauth_problem    IN VARCHAR2:= NULL);
END obj_lnkd_request_token_cb;
/
