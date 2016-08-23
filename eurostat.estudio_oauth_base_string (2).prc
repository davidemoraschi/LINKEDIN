DROP PROCEDURE ESTUDIO_OAUTH_BASE_STRING;

CREATE OR REPLACE procedure estudio_oauth_base_string
as
   TYPE url_parameters IS TABLE OF VARCHAR2 (2048)
                             INDEX BY VARCHAR2 (2048);

   oauth_url_parameters            url_parameters;
   l_current_parameter             VARCHAR2 (2048);
   oauth_url_parameters_base_str   VARCHAR2 (32767) := '';
   l_idx                           INTEGER;
BEGIN
   oauth_url_parameters ('string3') := 'tre';
   oauth_url_parameters ('string2') := 'due';
   oauth_url_parameters ('string1') := 'uno';
   oauth_url_parameters ('string4') := 'quattro';
   oauth_url_parameters ('string0') := 'zero';

   l_current_parameter := oauth_url_parameters.FIRST;

   LOOP
      EXIT WHEN l_current_parameter IS NULL;
      oauth_url_parameters_base_str :=
            oauth_url_parameters_base_str
         || CASE l_current_parameter WHEN oauth_url_parameters.FIRST THEN '?' ELSE '&' END
         || l_current_parameter
         || '='
         || oauth_url_parameters (l_current_parameter);
      l_current_parameter := oauth_url_parameters.NEXT (l_current_parameter);
   END LOOP;

   DBMS_OUTPUT.put_line (oauth_url_parameters_base_str);
END;
/
