DROP PROCEDURE FFSQL_0001_AIRCRAFTS;

CREATE OR REPLACE PROCEDURE          FFSQL_0001_AIRCRAFTS (EmpID INT, cResults IN OUT types.cursorType)
AS
BEGIN
   OPEN cResults FOR SELECT PKEY_AIRCRAFT, CODE_AIRCRAFT, NAME_AIRCRAFT FROM DIME_AIRCRAFT;
--WHERE PKEY_AIRCRAFT = EmpID;
END;
/
