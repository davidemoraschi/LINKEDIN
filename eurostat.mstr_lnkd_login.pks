DROP PACKAGE MSTR_LNKD_LOGIN;

CREATE OR REPLACE PACKAGE          mstr_lnkd_login
AS
   PROCEDURE jsp (OriginalURL   IN VARCHAR2:= NULL,
                  Server        IN VARCHAR2:= NULL,
                  Project       IN VARCHAR2:= NULL,
                  loginFail     IN VARCHAR2:= NULL,
                  ErrorCode     IN VARCHAR2:= NULL,
                  ErrorMessage  IN VARCHAR2:= NULL);
END mstr_lnkd_login;
/
