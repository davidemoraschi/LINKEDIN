DROP PACKAGE BODY JSON_XML;

CREATE OR REPLACE PACKAGE BODY          json_xml
AS
   FUNCTION escapeStr (str VARCHAR2)
      RETURN VARCHAR2
   AS
      buf   VARCHAR2 (32767) := '';
      ch    VARCHAR2 (4);
   BEGIN
      FOR i IN 1 .. LENGTH (str)
      LOOP
         ch := SUBSTR (str, i, 1);

         CASE ch
            WHEN '&'
            THEN
               buf := buf || '&amp;';
            WHEN '<'
            THEN
               buf := buf || '&lt;';
            WHEN '>'
            THEN
               buf := buf || '&gt;';
            WHEN '"'
            THEN
               buf := buf || '&quot;';
            ELSE
               buf := buf || ch;
         END CASE;
      END LOOP;

      RETURN buf;
   END escapeStr;

   /* Clob methods from printer */
   PROCEDURE add_to_clob (buf_lob IN OUT NOCOPY CLOB, buf_str IN OUT NOCOPY VARCHAR2, str VARCHAR2)
   AS
   BEGIN
      IF (LENGTH (str) > 32767 - LENGTH (buf_str))
      THEN
         DBMS_LOB.append (buf_lob, buf_str);
         buf_str := str;
      ELSE
         buf_str := buf_str || str;
      END IF;
   END add_to_clob;

   PROCEDURE flush_clob (buf_lob IN OUT NOCOPY CLOB, buf_str IN OUT NOCOPY VARCHAR2)
   AS
   BEGIN
      DBMS_LOB.append (buf_lob, buf_str);
   END flush_clob;

   PROCEDURE toString (obj json_value, tagname IN VARCHAR2, xmlstr IN OUT NOCOPY CLOB, xmlbuf IN OUT NOCOPY VARCHAR2)
   AS
      v_obj     json;
      v_list    json_list;

      v_keys    json_list;
      v_value   json_value;
      key_str   VARCHAR2 (4000);
   BEGIN
      IF (obj.is_object ())
      THEN
         add_to_clob (xmlstr, xmlbuf, '<' || tagname || '>');
         v_obj := json (obj);

         v_keys := v_obj.get_keys ();

         FOR i IN 1 .. v_keys.COUNT
         LOOP
            v_value := v_obj.get (i);
            key_str := v_keys.get_elem (i).str;

            IF (key_str = 'content')
            THEN
               IF (v_value.is_array ())
               THEN
                  DECLARE
                     v_l   json_list := json_list (v_value);
                  BEGIN
                     FOR j IN 1 .. v_l.COUNT
                     LOOP
                        IF (j > 1)
                        THEN
                           add_to_clob (xmlstr, xmlbuf, CHR (13) || CHR (10));
                        END IF;

                        add_to_clob (xmlstr, xmlbuf, escapeStr (v_l.get_elem (j).TO_CHAR ()));
                     END LOOP;
                  END;
               ELSE
                  add_to_clob (xmlstr, xmlbuf, escapeStr (v_value.TO_CHAR ()));
               END IF;
            ELSIF (v_value.is_array ())
            THEN
               DECLARE
                  v_l   json_list := json_list (v_value);
               BEGIN
                  FOR j IN 1 .. v_l.COUNT
                  LOOP
                     v_value := v_l.get_elem (j);

                     IF (v_value.is_array ())
                     THEN
                        add_to_clob (xmlstr, xmlbuf, '<' || key_str || '>');
                        add_to_clob (xmlstr, xmlbuf, escapeStr (v_value.TO_CHAR ()));
                        add_to_clob (xmlstr, xmlbuf, '</' || key_str || '>');
                     ELSE
                        toString (v_value, key_str, xmlstr, xmlbuf);
                     END IF;
                  END LOOP;
               END;
            ELSIF (v_value.is_null () OR (v_value.is_string AND v_value.get_string = ''))
            THEN
               add_to_clob (xmlstr, xmlbuf, '<' || key_str || '/>');
            ELSE
               toString (v_value, key_str, xmlstr, xmlbuf);
            END IF;
         END LOOP;

         add_to_clob (xmlstr, xmlbuf, '</' || tagname || '>');
      ELSIF (obj.is_array ())
      THEN
         v_list := json_list (obj);

         FOR i IN 1 .. v_list.COUNT
         LOOP
            v_value := v_list.get_elem (i);
            toString (v_value, NVL (tagname, 'array'), xmlstr, xmlbuf);
         END LOOP;
      ELSE
         add_to_clob (xmlstr, xmlbuf, '<' || tagname || '>' || escapeStr (obj.TO_CHAR ()) || '</' || tagname || '>');
      END IF;
   END toString;

   FUNCTION json_to_xml (obj json, tagname VARCHAR2 DEFAULT 'root')
      RETURN XMLTYPE
   AS
      xmlstr        CLOB := EMPTY_CLOB ();
      xmlbuf        VARCHAR2 (32767) := '';
      returnValue   XMLTYPE;
   BEGIN
      DBMS_LOB.createtemporary (xmlstr, TRUE);

      toString (obj.to_json_value (), tagname, xmlstr, xmlbuf);

      flush_clob (xmlstr, xmlbuf);
      /*    returnValue := xmltype('<?xml version="1.0"?>'||xmlstr);*/
      returnValue := xmltype (xmlstr);
      DBMS_LOB.freetemporary (xmlstr);
      RETURN returnValue;
   END;
END json_xml;
/
