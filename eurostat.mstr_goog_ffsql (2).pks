DROP PACKAGE MSTR_GOOG_FFSQL;

CREATE OR REPLACE PACKAGE          MSTR_GOOG_FFSQL
AS
   FUNCTION search_table (p_search_pattern IN VARCHAR2 := 'MicroStrategy RSS')
      RETURN mstr_goog_rss_type;
--   PROCEDURE search_table (p_search_pattern IN VARCHAR2 := 'MicroStrategy RSS');
--RETURN mstr_goog_rss_type;
END;
/
