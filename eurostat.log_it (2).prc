DROP PROCEDURE LOG_IT;

CREATE OR REPLACE PROCEDURE LOG_IT (p_string IN VARCHAR2, l_debug boolean := true )/******************************************************************************
   NAME:       LOG_IT
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/08/2011   Administrador       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     LOG_IT
      Sysdate:         01/08/2011
      Date and Time:   01/08/2011, 22:32:44, and 01/08/2011 22:32:44
      Username:        Administrador (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
IS
BEGIN
 DBMS_OUTPUT.put_line(p_string);
END;
/
