DROP PACKAGE MSTR_LNKD_AUTHENTICATE;

CREATE OR REPLACE PACKAGE          mstr_lnkd_authenticate
AS
   PROCEDURE jsp (token IN VARCHAR2 := NULL);
END mstr_lnkd_authenticate;
/
