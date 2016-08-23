DROP PACKAGE MSTR_LNKD_CHECK_TOKEN;

CREATE OR REPLACE PACKAGE          mstr_lnkd_check_token
AS
   PROCEDURE jsp (nexturl IN VARCHAR2 := 'about:blank');
END mstr_lnkd_check_token;
/
