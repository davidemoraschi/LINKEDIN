DROP PACKAGE BODY MSTR_LNKD_CONTEXT;

CREATE OR REPLACE PACKAGE BODY mstr_lnkd_context
AS
   PROCEDURE set_value_in_context (some_attribute IN VARCHAR2, some_value IN VARCHAR2)
   IS
   BEGIN
      DBMS_SESSION.set_context ('eurostat_context', some_attribute, some_value);
   END set_value_in_context;
END mstr_lnkd_context;
/
