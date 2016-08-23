DROP PACKAGE OBJ_GOOG_OAUTH2_DATAFEED;

CREATE OR REPLACE PACKAGE          obj_goog_oauth2_datafeed
AS
   PROCEDURE jsp (state IN VARCHAR2 := NULL);

   PROCEDURE "analytics#gaData" (lnkd_id IN VARCHAR2, cursor_gadata IN OUT sys_refcursor);

   FUNCTION "analytics#gaData" (lnkd_id IN VARCHAR2)
      RETURN mstr_goog_adata_table_type;
END obj_goog_oauth2_datafeed;
/
