DROP PACKAGE MSTR_LNKD_DOLOGIN;

CREATE OR REPLACE PACKAGE          mstr_lnkd_dologin
AS
   PROCEDURE jsp (token IN VARCHAR2 := NULL);
END mstr_lnkd_dologin;
/
