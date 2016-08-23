DROP PACKAGE MSTR_LNKD_FFSQL;

CREATE OR REPLACE PACKAGE          mstr_lnkd_FFSQL
AS
   PROCEDURE connections (lnkd_id IN VARCHAR2, cursor_connections IN OUT SYS_REFCURSOR);

   FUNCTION connections_table (lnkd_id IN VARCHAR2)
      RETURN mstr_lnkd_connections_type;

   PROCEDURE groups (lnkd_id IN VARCHAR2, cursor_groups IN OUT SYS_REFCURSOR);

   FUNCTION groups_table (lnkd_id IN VARCHAR2)
      RETURN mstr_lnkd_groups_type;

   PROCEDURE share_EuroStrategy (lnkd_id IN VARCHAR2, p_comment IN VARCHAR2 := 'See how you can use your LinkedIn account to log in to MicroStrategy.', cursor_groups IN OUT SYS_REFCURSOR);

END mstr_lnkd_FFSQL;
/
