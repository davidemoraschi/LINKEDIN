DROP PACKAGE UTL_TSV;

CREATE OR REPLACE PACKAGE          UTL_TSV
AS
   /******************************************************************************
      NAME:       UTL_TSV
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        6/30/2011      Davide       1. Created this package.
   ******************************************************************************/

   PROCEDURE read_tsv_file (p_filename IN VARCHAR2 := 'avia_paoac.tsv', p_folder IN VARCHAR2 := 'EUROSTAT');
END UTL_TSV;
/
