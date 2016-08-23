DROP FUNCTION URLENCODE;

CREATE OR REPLACE FUNCTION urlencode (p_str IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_tmp    VARCHAR2 (6000);
      l_bad    VARCHAR2 (100) DEFAULT ' ,>%}\~];?@&<#{|^[`/:=$+''"';
      l_char   CHAR (1);
   BEGIN
      FOR i IN 1 .. NVL (LENGTH (p_str), 0)
      LOOP
         l_char := SUBSTR (p_str, i, 1);

         IF (INSTR (l_bad, l_char) > 0)
         THEN
            l_tmp := l_tmp || '%' || TO_CHAR (ASCII (l_char), 'fmXX');
         ELSE
            l_tmp := l_tmp || l_char;
         END IF;
      END LOOP;

      RETURN l_tmp;
   END urlencode;
/
