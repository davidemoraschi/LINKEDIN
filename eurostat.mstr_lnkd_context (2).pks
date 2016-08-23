DROP PACKAGE MSTR_LNKD_CONTEXT;

CREATE OR REPLACE PACKAGE mstr_lnkd_context
AS
   PROCEDURE set_value_in_context (some_attribute IN VARCHAR2, some_value IN VARCHAR2);
END mstr_lnkd_context;
/
