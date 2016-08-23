DROP PACKAGE OBJ_TWIT_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE          obj_twit_request_token_cb
AS
   PROCEDURE jsp (oauth_token IN VARCHAR2 := NULL, oauth_verifier IN VARCHAR2 := NULL, denied IN VARCHAR2 := NULL);
END obj_twit_request_token_cb;
/
