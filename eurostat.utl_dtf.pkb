DROP PACKAGE BODY UTL_DTF;

CREATE OR REPLACE PACKAGE BODY          UTL_DTF
AS
   /******************************************************************************
      NAME:       UTL_DTF
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        6/6/2011      Davide       1. Created this package body.
   ******************************************************************************/

   FUNCTION STRING_SPLIT (str VARCHAR2, delimiter VARCHAR2)
      RETURN str_array
   AS
      val_list   str_array;
      head       VARCHAR2 (4000);
      tail       VARCHAR2 (4000);
      i          NUMBER := 1;

      do_loop    BOOLEAN := TRUE;
   BEGIN
      -- Initialize array
      val_list := str_array ('');
      tail := str;

      WHILE do_loop
      LOOP
         head := SUBSTR (tail, 1, INSTR (tail, delimiter, 1, 1) - 1);
         IF INSTR (tail, delimiter, 1, 1) > 0
         THEN
            IF i = 1
            THEN
               val_list.DELETE (1);
               val_list (i) := head;
            ELSE
               val_list.EXTEND;
               val_list (i) := head;
            END IF;
         ELSE
            IF i <> 1
            THEN
               val_list.EXTEND;
            END IF;
            val_list (i) := tail;
            do_loop := FALSE;
         END IF;
         i := i + 1;
         tail := SUBSTR (tail, INSTR (tail, delimiter, 1, 1) + 1, LENGTH (tail));
      END LOOP;

      RETURN val_list;
   END;

   FUNCTION get_token (the_list VARCHAR2, the_index NUMBER, delim VARCHAR2 := ',')
      RETURN VARCHAR2
   IS
      start_pos   NUMBER;
      end_pos     NUMBER;
   BEGIN
      IF the_index = 1
      THEN
         start_pos := 1;
      ELSE
         start_pos := INSTR (the_list, delim, 1, the_index - 1);
         IF start_pos = 0
         THEN
            RETURN NULL;
         ELSE
            start_pos := start_pos + LENGTH (delim);
         END IF;
      END IF;

      end_pos := INSTR (the_list, delim, start_pos, 1);

      IF end_pos = 0
      THEN
         RETURN SUBSTR (the_list, start_pos);
      ELSE
         RETURN SUBSTR (the_list, start_pos, end_pos - start_pos);
      END IF;
   END get_token;

   PROCEDURE read_dft_file (p_filename IN VARCHAR2 := 'aact_eaa02.dft', p_folder IN VARCHAR2 := 'EUROSTAT')
   IS
      f              UTL_FILE.file_type;
      s              VARCHAR2 (200);
      s2             VARCHAR2 (8000);
      s3             VARCHAR2 (8000);
      l_DIMLST_len   PLS_INTEGER := 1;
      l_DIMLST       DBMS_UTILITY.uncl_array;
      l_DIMUSE_len   PLS_INTEGER := 1;
      l_DIMUSE       DBMS_UTILITY.uncl_array;
      cnt            PLS_INTEGER := 0;
      cnt2           PLS_INTEGER := 0;
      cnt3           PLS_INTEGER := 0;

      TYPE cnt_array IS TABLE OF PLS_INTEGER;

      outCursor      SYS_REFCURSOR;
      cnta           cnt_array;
      l_sql_dml      VARCHAR2 (4000);
      l_length       NUMBER;
      P_DIME_ARRAY   EUROSTAT.UTL_DTF.str_array;
      l_NULL         VARCHAR2 (1);

      TYPE dime_value_tab IS TABLE OF VARCHAR2 (100); -- first level

      TYPE dime_tab IS TABLE OF dime_value_tab
                          INDEX BY VARCHAR2 (100);

      --      SUBTYPE maxvarchar2_t IS VARCHAR2 (32767);
      --
      --      TYPE items_tt IS TABLE OF maxvarchar2_t
      --                          INDEX BY PLS_INTEGER;
      --
      --      TYPE nested_items_tt IS TABLE OF items_tt
      --                                 INDEX BY PLS_INTEGER;
      --
      --      TYPE named_nested_items_tt IS TABLE OF items_tt
      --                                       INDEX BY maxvarchar2_t;

      dimensions     parse.named_nested_items_tt; -- dime_tab;
   BEGIN
      cnta := cnt_array (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

      SELECT COUNT (table_name)
        INTO l_length
        FROM user_tables
       WHERE table_name = UPPER (SUBSTR ('aact_eaa02.dft', 1, LENGTH ('aact_eaa02.dft') - 4));

      IF l_length > 0
      THEN
         l_sql_dml := 'DROP TABLE ' || SUBSTR (p_filename, 1, LENGTH (p_filename) - 4);

         EXECUTE IMMEDIATE l_sql_dml;
      END IF;
      l_sql_dml := 'CREATE TABLE '; -- || SUBSTR (p_filename, 1, LENGTH (p_filename) - 4);

      l_sql_dml := l_sql_dml || UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4));

      l_sql_dml := l_sql_dml || ' (';
      f := UTL_FILE.fopen (p_folder, p_filename, 'R');
      --INFO HEADER
      UTL_FILE.get_line (f, s);
      --INFO Value
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('INFO: ' || s);
      --LASTUP HEADER
      UTL_FILE.get_line (f, s);
      --LASTUP Value
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('LASTUP: ' || s);
      --TYPE HEADER
      UTL_FILE.get_line (f, s);
      --TYPE Value
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('TYPE: ' || s);
      --DELIMS HEADER
      UTL_FILE.get_line (f, s);
      --DELIMS Value
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('DELIMS: ' || s);
      --DIMLST HEADER
      UTL_FILE.get_line (f, s);
      --DIMLST Value
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('DIMLST: ' || s);
      s := REPLACE (s, '(', '');
      s := REPLACE (s, ')', '');

      BEGIN
         LOOP
            IF get_token (s, l_DIMLST_len) IS NULL
            THEN
               EXIT;
            ELSE
               l_DIMLST (l_DIMLST_len) := get_token (s, l_DIMLST_len);
               l_DIMLST_len := l_DIMLST_len + 1;
            END IF;
         END LOOP;
      END;

      UTL_FILE.get_line (f, s);
      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('DIMUSE: ' || s);
      s := REPLACE (s, '(', '');
      s := REPLACE (s, ')', '');

      BEGIN
         LOOP
            IF get_token (s, l_DIMUSE_len) IS NULL
            THEN
               EXIT;
            ELSE
               l_DIMUSE (l_DIMUSE_len) := get_token (s, l_DIMUSE_len);
               l_DIMUSE_len := l_DIMUSE_len + 1;
            END IF;
         END LOOP;
      END;

      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      LOOP
         IF l_DIMUSE (cnt) = 'V'
         THEN
            --DBMS_OUTPUT.put_line (l_DIMLST (cnt));
            l_sql_dml :=
                  l_sql_dml
               || 'PKEY_'
               || UPPER (l_DIMLST (cnt))
               || ' NUMBER '
               || 'NOT NULL REFERENCES DIME_'
               || UPPER (l_DIMLST (cnt))
               || '('
               || 'PKEY_'
               || UPPER (l_DIMLST (cnt))
               || ')'
               || ', ';
         END IF;
      END LOOP;

      l_sql_dml :=
            l_sql_dml
         || 'VALU_'
         || UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4))
         || ' NUMBER'
         || ', CONSTRAINT PK_'
         || UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4))
         || ' PRIMARY KEY (';

      UTL_FILE.get_line (f, s);

      --POSLST

      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      LOOP
         IF l_DIMUSE (cnt) = 'V'
         THEN
            l_sql_dml := l_sql_dml || 'PKEY_' || UPPER (l_DIMLST (cnt)) || ', ';
         ELSE
            UTL_FILE.get_line (f, s);
            DBMS_OUTPUT.put_line (l_DIMLST (cnt) || '=' || s);
         END IF;
      END LOOP;

      l_sql_dml := SUBSTR (l_sql_dml, 1, LENGTH (l_sql_dml) - 2) || ')) PARALLEL 6 NOLOGGING';


      DBMS_OUTPUT.put_line (l_sql_dml);

      EXECUTE IMMEDIATE l_sql_dml;

      --PARSE DIMENSIONS
      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      LOOP
         IF l_DIMUSE (cnt) = 'V'
         THEN
            s := '';
            s2 := '';

            UTL_FILE.get_line (f, s);
            s2 := s;
            cnt2 := 1;


            WHILE INSTR (s, ')') = 0
            LOOP
               UTL_FILE.get_line (f, s);
               s2 := s2 || s;
               cnt2 := cnt2 + 1;
            END LOOP;

            s2 := REPLACE (s2, '(', '');
            s2 := REPLACE (s2, ')', '');

            dimensions (l_DIMLST (cnt)) := parse.string_to_list (s2, ',');
            cnta (cnt) := dimensions (l_DIMLST (cnt)).COUNT;


            DBMS_OUTPUT.put_line (l_DIMLST (cnt) || '=' || s2);
         END IF;
      END LOOP;

      -- NOTAV
      WHILE s <> 'NOTAV'
      LOOP
         UTL_FILE.get_line (f, s);
      END LOOP;

      UTL_FILE.get_line (f, s);
      l_NULL := s;
      DBMS_OUTPUT.put_line ('NULL= ' || s);

      -- VALLST
      WHILE s <> 'VALLST'
      LOOP
         UTL_FILE.get_line (f, s);
      END LOOP;

      UTL_FILE.get_line (f, s);
      DBMS_OUTPUT.put_line ('VALLST= ' || s);

      --      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      --      LOOP
      --         IF l_DIMUSE (cnt) = 'V'
      --         THEN
      --            FOR cnt2 IN dimensions (l_DIMLST (cnt)).FIRST .. dimensions (l_DIMLST (cnt)).LAST
      --            LOOP
      --               DBMS_OUTPUT.put_line (dimensions (l_DIMLST (cnt)) (cnt2));
      --            END LOOP;
      --         END IF;
      --      END LOOP;
      --      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      --      LOOP
      --         IF l_DIMUSE (cnt) = 'V'
      --         THEN
      --            DBMS_OUTPUT.put_line (l_DIMLST (cnt) || ':' || TO_CHAR (cnta (cnt)) || ' valores ');
      --
      --            FOR cnt2 IN 1 .. cnta (cnt)
      --            LOOP
      --               --FOR cnt2 IN cnt + 1 .. (l_DIMUSE_len - 1)
      --               --LOOP
      --               l_sql_dml :=
      --                     'INSERT INTO '
      --                  || UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4))
      --                  || ' VALUES ('
      --                  || dimensions (l_DIMLST (cnt)) (cnt2);
      --               DBMS_OUTPUT.put_line (l_sql_dml);
      --            --END LOOP;
      --            END LOOP;
      --
      --            EXIT;
      --         END IF;
      --      END LOOP;
      s2 := 'SELECT * FROM ';
      s := ' ORDER BY ';
      s3 := 'INSERT INTO ' || UPPER (SUBSTR (p_filename, 1, LENGTH (p_filename) - 4)) || ' SELECT ';
      cnt3 := 1;

      FOR cnt IN 1 .. (l_DIMUSE_len - 1)
      LOOP
         IF l_DIMUSE (cnt) = 'V'
         THEN
            SELECT COUNT (table_name)
              INTO l_length
              FROM user_tables
             WHERE table_name = UPPER ('TMP_' || l_DIMLST (cnt));

            IF l_length > 0
            THEN
               l_sql_dml := 'DROP TABLE ' || 'TMP_' || l_DIMLST (cnt);

               EXECUTE IMMEDIATE l_sql_dml;
            END IF;
            l_sql_dml := 'CREATE TABLE ' || 'TMP_' || l_DIMLST (cnt) || '(N1 NUMBER, T1 VARCHAR2(200))';

            EXECUTE IMMEDIATE l_sql_dml;

            FOR cnt2 IN dimensions (l_DIMLST (cnt)).FIRST .. dimensions (l_DIMLST (cnt)).LAST
            LOOP
               --DBMS_OUTPUT.put_line (dimensions (l_DIMLST (cnt)) (cnt2));

               l_sql_dml :=
                     'INSERT INTO '
                  || 'TMP_'
                  || l_DIMLST (cnt)
                  || ' VALUES ('
                  || cnt2
                  || ','''
                  || dimensions (l_DIMLST (cnt)) (cnt2)
                  || ''')';

               --DBMS_OUTPUT.put_line(l_sql_dml);
               EXECUTE IMMEDIATE l_sql_dml;
            END LOOP;

            s2 :=
                  s2
               || '(SELECT N1 N'
               || cnt3
               || ', T1 T'
               || cnt3
               || ' FROM '
               || UPPER (' TMP_' || l_DIMLST (cnt))
               || '),';
            s := s || 'N' || cnt3 || ',';
            s3 := s3 || ' T' || cnt3 || ',';
            cnt3 := cnt3 + 2;
         END IF;
      END LOOP;

      s2 :=
            SUBSTR (s3, 1, LENGTH (s3) - 1)
         || ', NULL FROM ('
         || SUBSTR (s2, 1, LENGTH (s2) - 1)
         || SUBSTR (s, 1, LENGTH (s) - 1)
         || ')';

      DBMS_OUTPUT.put_line (s2);

      --      OPEN outCursor FOR s2;
      --
      --
      --
      --   LOOP
      --      FETCH outCursor into;-- INTO v_trip_id, v_hotel_id;
      --      EXIT WHEN outCursor%ROWCOUNT > 20 OR outCursor%NOTFOUND;
      --
      --   END LOOP;
      --      CLOSE outCursor;
      --
      UTL_FILE.fclose (f);
   END read_dft_file;
END UTL_DTF;
/
