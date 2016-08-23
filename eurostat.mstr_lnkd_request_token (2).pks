DROP PACKAGE MSTR_LNKD_REQUEST_TOKEN;

CREATE OR REPLACE PACKAGE          mstr_lnkd_request_token
AS
   PROCEDURE jsp (originalurl IN VARCHAR2 := 'about:blank', port IN VARCHAR2 := '0', src IN VARCHAR2 := NULL);
END mstr_lnkd_request_token;
/
