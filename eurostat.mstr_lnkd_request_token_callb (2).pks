DROP PACKAGE MSTR_LNKD_REQUEST_TOKEN_CALLB;

CREATE OR REPLACE PACKAGE          mstr_lnkd_request_token_callb
AS
   PROCEDURE jsp (oauth_token      IN VARCHAR2:= NULL,
                  oauth_verifier   IN VARCHAR2:= NULL,
                  oauth_problem    IN VARCHAR2:= NULL);
END mstr_lnkd_request_token_callb;
/
