DROP PACKAGE MSTR_SOAP_EXECUTEGRAPH;

CREATE OR REPLACE PACKAGE          mstr_soap_executegraph
AS
   crlf                      CONSTANT VARCHAR2 (2) := CHR (13) || CHR (10);
   soap_request                       XMLTYPE;
   con_http_ws_method        CONSTANT VARCHAR2 (5) := 'POST';
   con_str_mstrwsj_server    CONSTANT VARCHAR2 (200) := 'fraterno';
   --   con_str_mstrwsj_server CONSTANT VARCHAR2 (200) := 'localhost';
   con_str_mstrwsj_user      CONSTANT VARCHAR2 (200) := 'IUSR_WEBSERVICE';
   con_str_mstrwsj_password  CONSTANT VARCHAR2 (200) := 'aumentanun4,9%';
   con_str_mstrwsj_project   CONSTANT VARCHAR2 (200) := 'Cuenta de Resultados';
   --   con_str_mstrwsj_project CONSTANT VARCHAR2 (200) := 'MicroStrategy Tutorial';
   con_str_ws_url            CONSTANT VARCHAR2 (250) := 'http://fraterno:8080/MicroStrategyWS/services/MSTRWSJ';
   --   con_str_ws_url    CONSTANT VARCHAR2 (250) := 'http://localhost:8081/MicroStrategyWS/services/MSTRWSJ';
   con_str_ws_action         CONSTANT VARCHAR2 (250) := '"http://microstrategy.com/webservices/v1_0/ExecuteReport"';

   --   con_http_xsl_uri   CONSTANT VARCHAR2 (1024) := 'http://localhost:8081/MicroStrategyWS/MWS_EXT.xsl';

   PROCEDURE png (preportid IN VARCHAR2);

   PROCEDURE png ( pprojectid IN VARCHAR2, preportid IN VARCHAR2);
END mstr_soap_executegraph;
/
