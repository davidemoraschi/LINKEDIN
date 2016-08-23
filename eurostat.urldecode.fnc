DROP FUNCTION URLDECODE;

CREATE OR REPLACE FUNCTION urldecode (p_str IN VARCHAR2)
   RETURN VARCHAR2
IS
   /* Declare */
   l_hex                              VARCHAR2 (16) := '0123456789ABCDEF';
   l_idx                              NUMBER := 0;
   l_ret                              LONG := p_str;
BEGIN
   IF p_str IS NULL
   THEN
      RETURN p_str;
   END IF;

   LOOP
      l_idx       := INSTR ( l_ret, '%', l_idx + 1);
      EXIT WHEN l_idx = 0;
      l_ret       :=
         SUBSTR ( l_ret, 1, l_idx - 1)
         || CHR (
                 (INSTR ( l_hex, SUBSTR ( l_ret, l_idx + 1, 1)) - 1) * 16
               + INSTR ( l_hex, SUBSTR ( l_ret, l_idx + 2, 1))
               - 1)
         || SUBSTR ( l_ret, l_idx + 3);
   END LOOP;

   RETURN l_ret;
END urldecode;
/
