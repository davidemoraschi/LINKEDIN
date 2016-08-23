DROP PACKAGE BODY UTL_TSV;

CREATE OR REPLACE PACKAGE BODY          UTL_TSV
AS
   /******************************************************************************
      NAME:       UTL_TSV
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        6/30/2011      Davide       1. Created this package body.
   ******************************************************************************/

   PROCEDURE read_tsv_file (p_filename IN VARCHAR2 := 'avia_paoac.tsv', p_folder IN VARCHAR2 := 'EUROSTAT')
   IS
      l_file_tsv          UTL_FILE.file_type;
      l_file_tsv_row      VARCHAR2 (32767);
      l_dimension_list    parse.items_tt;
      l_dimvalues_list    parse.items_tt;
      l_timeslots_list    parse.items_tt;
      l_indvalues_list    parse.items_tt;
      l_DEBUG             BOOLEAN := TRUE;
      l_dynamic_SQL       VARCHAR2 (32767);
      l_fact_table_name   VARCHAR2 (30);
      l_line_counter      NUMBER := 0;
      l_cursor_id         INTEGER;
      exec_stat           INTEGER;
      TABLE_MISSING       EXCEPTION;
      PRAGMA EXCEPTION_INIT (TABLE_MISSING, -942);
   BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS=''.,''';

      l_fact_table_name := UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4));
      l_file_tsv := UTL_FILE.fopen (p_folder, p_filename, 'r', 32767);

      -- Reads first line with dimension names and time slots
      UTL_FILE.get_line (l_file_tsv, l_file_tsv_row);
      --log_it ('Read: ' || TO_CHAR (LENGTH (l_file_tsv_row)) || ' chars.', l_DEBUG);

      -- Split dimension names into array of strings
      l_dimension_list := parse.string_to_list (SUBSTR (l_file_tsv_row, 1, INSTR (l_file_tsv_row, '\') - 1), ',');
      log_it ('Data has: ' || TO_CHAR (l_dimension_list.LAST) || ' dimensions (' || SUBSTR (l_file_tsv_row, 1, INSTR (l_file_tsv_row, '\') - 1) || ')', l_DEBUG);

      -- Split time slots into array of strings
      l_timeslots_list := parse.string_to_list (SUBSTR (l_file_tsv_row, INSTR (l_file_tsv_row, '\time') + 6), CHR (9));
      --log_it ('Time has: ' || TO_CHAR (l_timeslots_list.LAST) || ' slots (' || SUBSTR (l_file_tsv_row, INSTR (l_file_tsv_row, '\time') + 6) || ')', l_DEBUG);

      -- Creates temp table
      l_dynamic_SQL := 'DROP TABLE STAGE_' || l_fact_table_name;

      --log_it (l_dynamic_SQL, l_DEBUG);

      BEGIN
         EXECUTE IMMEDIATE l_dynamic_SQL;
      EXCEPTION
         WHEN TABLE_MISSING
         THEN
            NULL; -- use default error handling behaviour if you feel like or use your own error number and message..
      END;

      l_dynamic_SQL := 'CREATE TABLE STAGE_' || l_fact_table_name || ' (';

      FOR i IN l_dimension_list.FIRST .. l_dimension_list.LAST
      LOOP
         l_dynamic_SQL := l_dynamic_SQL || l_dimension_list (i) || ' VARCHAR2(100), ';
      END LOOP;

      l_dynamic_SQL :=
         l_dynamic_SQL
         || ' CODE_TIME VARCHAR2(50), IND_VALUE NUMBER)  NOLOGGING NOMONITORING PARALLEL 6';

      --log_it (l_dynamic_SQL, l_DEBUG);

      EXECUTE IMMEDIATE l_dynamic_SQL;

      -- Builds the SQL sentence
      l_dynamic_SQL := 'INSERT INTO STAGE_' || l_fact_table_name || ' VALUES(';

      FOR i IN l_dimension_list.FIRST .. l_dimension_list.LAST
      LOOP
         l_dynamic_SQL := l_dynamic_SQL || ':n' || TO_CHAR (i) || ', ';
      END LOOP;

      l_dynamic_SQL := l_dynamic_SQL || ' :t1, :n0)';

      -- Creates and parse the dynamic cursor
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor_id, l_dynamic_SQL, DBMS_SQL.native);

      -- Reads lines of data
      BEGIN
         LOOP
            UTL_FILE.get_line (l_file_tsv, l_file_tsv_row);
            l_line_counter := l_line_counter + 1;
            l_dimvalues_list :=
               parse.string_to_list (SUBSTR (l_file_tsv_row, 1, INSTR (l_file_tsv_row, CHR (9)) - 1), ',');
            l_indvalues_list :=
               parse.string_to_list (SUBSTR (l_file_tsv_row, INSTR (l_file_tsv_row, CHR (9)) + 1), CHR (9));

            -- Binds variables for dimensions
            FOR i IN l_dimvalues_list.FIRST .. l_dimvalues_list.LAST
            LOOP
               DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'n' || TO_CHAR (i), l_dimvalues_list (i));
            END LOOP;

            FOR i IN l_timeslots_list.FIRST .. l_timeslots_list.LAST
            LOOP
               -- Binds variable for timeslots
               DBMS_SQL.BIND_VARIABLE (l_cursor_id, 't1', l_timeslots_list (i));

               -- If the value is NULL skip the time slot, reducing rows by about 30% (depends on fact table)
               -- May have NULL values with flag, we disregard them. Will change in the next release
               IF INSTR (l_indvalues_list (i), ':') > 0 --TRIM (l_indvalues_list (i)) = ':'
               THEN
                  l_indvalues_list (i) := NULL;
               ELSE
                  -- Binds variable for values
                  /*
                  EUROSTAT Observation status code list
                    b=Break in series
                    c=Confidential
                    e=Estimated value
                    f=Forecast
                    i=See explanatory text
                    n=Not significant
                    p=Provisional value
                    r=Revised value
                    s=Eurostat estimate
                    u=Unreliable or uncertain data
                    z=Not applicable or Real zero or Zero by default
                  CASE
                     WHEN INSTR (l_indvalues_list (i), 'c') > 0
                     THEN
                        log_it ('Confidential', l_DEBUG);
                        DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'f0', 'c');
                        l_indvalues_list (i) := REPLACE (l_indvalues_list (i), 'c', NULL);
                     WHEN INSTR (l_indvalues_list (i), 'i') > 0
                     THEN
                        log_it ('See explanatory text', l_DEBUG);
                        DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'f0', 'i');
                        l_indvalues_list (i) := REPLACE (l_indvalues_list (i), 'i', NULL);
                     WHEN INSTR (l_indvalues_list (i), 'u') > 0
                     THEN
                        log_it ('Unreliable or uncertain data', l_DEBUG);
                        DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'f0', 'u');
                        l_indvalues_list (i) := REPLACE (l_indvalues_list (i), 'u', NULL);
                     ELSE
                        --NULL;
                        DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'f0', TO_CHAR (NULL));
                  END CASE;
                  */

                  BEGIN
                     DBMS_SQL.BIND_VARIABLE (l_cursor_id, 'n0', TO_NUMBER (TRIM (l_indvalues_list (i))));
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_it ('Error with value=<' || TRIM (l_indvalues_list (i)) || '>');
                        --RAISE;
                  END;

                  -- Executes the cursor.
                  -- Space for improvement: use FORALL and bulk loading from arrays.
                  exec_stat := DBMS_SQL.EXECUTE (l_cursor_id);
               -- Space for improvement: use FORALL and bulk loading from arrays.
               END IF;
            END LOOP;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- At EOF closes the file
            UTL_FILE.fclose (l_file_tsv);
      END;

      --   log_it ('Slot 1: ' || l_indvalues_list (1));
      --   log_it ('Slot 2: ' || l_indvalues_list (1));
      --   log_it ('Last Slot: ' || l_indvalues_list (l_indvalues_list.LAST));
      --
      log_it (l_line_counter || ' lines processed.');
      -- Is it open? this line is not needed.
      UTL_FILE.FCLOSE (l_file_tsv);
      COMMIT;
      DBMS_SQL.CLOSE_CURSOR (l_cursor_id);

      -- Primary Key
      l_dynamic_SQL :=
            'ALTER TABLE STAGE_'
         || l_fact_table_name
         || ' ADD CONSTRAINT STAGE_'
         || l_fact_table_name
         || '_PK'
         || ' PRIMARY KEY (';

      FOR i IN l_dimension_list.FIRST .. l_dimension_list.LAST
      LOOP
         l_dynamic_SQL := l_dynamic_SQL || l_dimension_list (i) || ', ';
      END LOOP;

      l_dynamic_SQL := l_dynamic_SQL || ' CODE_TIME) ENABLE VALIDATE PARALLEL 6 NOLOGGING COMPRESS';

      --log_it (l_dynamic_SQL, l_DEBUG);

      EXECUTE IMMEDIATE l_dynamic_SQL;

      -- Foreign Keys
      FOR i IN l_dimension_list.FIRST .. l_dimension_list.LAST
      LOOP
         l_dynamic_SQL :=
               'ALTER TABLE STAGE_'
            || l_fact_table_name
            || ' ADD CONSTRAINT STAGE_'
            || l_fact_table_name
            || '_R'
            || (i)
            || ' FOREIGN KEY ('
            || l_dimension_list (i)
            || ') REFERENCES DIME_'
            || l_dimension_list (i)
            || ' (CODE_'
            || l_dimension_list (i)
            || ') ENABLE VALIDATE PARALLEL 6 NOLOGGING COMPRESS';

         --log_it (l_dynamic_SQL, l_DEBUG);
         EXECUTE IMMEDIATE l_dynamic_SQL;
      END LOOP;
   END;
END UTL_TSV;
/
