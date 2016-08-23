DROP PROCEDURE DOWNLOAD_FILE;

CREATE OR REPLACE PROCEDURE          DOWNLOAD_FILE (p_filename IN VARCHAR2)
AS
BEGIN
   oauth.download.
   text ('http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?sort=1&downfile=' || p_filename,
         'EUROSTAT',
         p_filename);
   oauth.twitter.update_status ('downloaded ' || p_filename, 'valme_twit_04');

   BEGIN
      INSERT INTO log_table_of_contents
           VALUES (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4), SYSTIMESTAMP);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE log_table_of_contents
            SET CONTENT_LAST_DOWNLOAD = SYSTIMESTAMP
          WHERE CONTENT_CODE = SUBSTR (p_filename, 1, LENGTH (p_filename) - 4);
   END;
END;
/
