DROP PACKAGE UTL_DTF;

CREATE OR REPLACE PACKAGE          UTL_DTF
AS
   /******************************************************************************
      NAME:       UTL_DTF
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        6/6/2011      Davide       1. Created this package.
   ******************************************************************************/
   TYPE str_array IS TABLE OF VARCHAR2 (8000);


   FUNCTION STRING_SPLIT (str VARCHAR2, delimiter VARCHAR2)
      RETURN str_array;

   FUNCTION get_token (the_list VARCHAR2, the_index NUMBER, delim VARCHAR2 := ',')
      RETURN VARCHAR2;

   PROCEDURE read_dft_file (p_filename IN VARCHAR2 := 'aact_eaa02.dft', p_folder IN VARCHAR2 := 'EUROSTAT');
END UTL_DTF;
/
