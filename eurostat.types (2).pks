DROP PACKAGE TYPES;

CREATE OR REPLACE PACKAGE          types
AS
   TYPE cursorType IS REF CURSOR;

   errorx   INT;
END;
/
