DROP PACKAGE BODY MSTR_LNKD_LOGIN;

CREATE OR REPLACE PACKAGE BODY          mstr_lnkd_login
AS
   PROCEDURE jsp (OriginalURL    IN VARCHAR2:= NULL,
                  Server         IN VARCHAR2:= NULL,
                  Project        IN VARCHAR2:= NULL,
                  loginFail      IN VARCHAR2:= NULL,
                  ErrorCode      IN VARCHAR2:= NULL,
                  ErrorMessage   IN VARCHAR2:= NULL)
   IS
      --MicroStrategy Web Base URL. Please change according to your MicroStrategy Installation
      mstrBase   CONSTANT VARCHAR2 (2000) := 'http://moraschi.eu/MicroStrategy/servlet/';

      --Authentication Server Login Page. Please change according to your authenticatiion or identity server setting.
      loginURL   CONSTANT VARCHAR2 (2000) := pq_constants.con_str_hostname_port||'/sso/mstr_lnkd_check_token.jsp';

      --Please change it to the defalut URL you need.
      defaultMSTRReportURL CONSTANT VARCHAR2 (2000)
            := 'mstrWeb?server=localhost&port=0&project=MicroStrategy Tutorial&evt=4001&reportName=Regional Profit and Margins' ;
   BEGIN
      IF ErrorCode IS NOT NULL
      THEN
         HTP.p (ErrorMessage);
         RETURN;
      END IF;

      IF loginFail IS NOT NULL
      THEN
         HTP.p ('Login failed.');
      ELSE
         IF OriginalURL IS NULL
         THEN
            HTP.p (defaultMSTRReportURL);
         ELSE
            --HTP.p (mstrBase || OriginalURL);
            HTP.
            p (
                  '<body onload="submitform()" >
                    <form name="preloginForm" action="'
               || loginURL
               || '" method="post" >
                        <input type="hidden" name="nextURL" value="'
               || mstrBase
               || OriginalURL
               || '" size="150">
                    </form>
                    <SCRIPT language="JavaScript">
                    function submitform()
                    {
                      document.preloginForm.submit();
                    }
                    </SCRIPT> 
                    </body>');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END mstr_lnkd_login;
/
