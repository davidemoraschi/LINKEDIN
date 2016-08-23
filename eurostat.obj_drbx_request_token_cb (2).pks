DROP PACKAGE OBJ_DRBX_REQUEST_TOKEN_CB;

CREATE OR REPLACE PACKAGE          obj_drbx_request_token_cb
AS
   PROCEDURE jsp (oauth_token IN VARCHAR2 := NULL, UID IN VARCHAR2 := NULL);
END obj_drbx_request_token_cb;
/
