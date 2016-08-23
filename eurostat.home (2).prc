DROP PROCEDURE HOME;

CREATE OR REPLACE PROCEDURE home
IS
BEGIN
   HTP.htmlOpen;
      HTP.headOpen;
         HTP.title ('This is a test page!');
      HTP.headClose;
      HTP.bodyOpen;
	   OWA_UTIL.PRINT_CGI_ENV;
	   OWA_UTIL.SIGNATURE;
      HTP.bodyClose;
   HTP.htmlClose;
END home;
/
