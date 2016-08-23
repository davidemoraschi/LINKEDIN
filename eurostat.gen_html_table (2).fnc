DROP FUNCTION GEN_HTML_TABLE;

CREATE OR REPLACE FUNCTION          gen_html_table (rf IN SYS_REFCURSOR)
   RETURN VARCHAR2
AS
   lhtmloutput   XMLTYPE;
   lxsl          XMLTYPE;
   lxmldata      XMLTYPE;
   lcontext      DBMS_XMLGEN.ctxhandle;
BEGIN
   lcontext := DBMS_XMLGEN.newcontext (rf);
   -- setNullHandling to 1 (or 2) to allow null columns
   -- to be displayed
   DBMS_XMLGEN.setnullhandling (lcontext, 1);
   -- create XML from ref cursor --
   lxmldata := DBMS_XMLGEN.getxmltype (lcontext, DBMS_XMLGEN.NONE);

   -- this is a generic XSL for Oracle's default
   -- XML row and rowset tags --
   -- " " is a non-breaking space --
   SELECT CONST_VALUE
     INTO lxsl
     FROM XML_CONSTANTS
    WHERE XML_CONSTANTS.const_name = 'html_table';

   -- XSL transformation to convert XML to HTML --
   lhtmloutput := lxmldata.transform (lxsl);
   -- convert XMLType to Clob --
   DBMS_XMLGEN.closecontext (lcontext);
   RETURN DBMS_LOB.SUBSTR (lhtmloutput.getclobval ());
END gen_html_table;
/
