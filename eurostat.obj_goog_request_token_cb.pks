DROP PACKAGE OBJ_GOOG_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE          obj_goog_request_token_cb
AS
   PROCEDURE jsp (oauth_verifier IN VARCHAR2 := NULL, oauth_token IN VARCHAR2 := NULL);
END obj_goog_request_token_cb;
/
