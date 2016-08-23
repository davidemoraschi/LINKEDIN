DROP PACKAGE BODY MSTR_LNKD_DOLOGIN;

CREATE OR REPLACE PACKAGE BODY          mstr_lnkd_dologin
AS
   PROCEDURE jsp (token IN VARCHAR2 := NULL)
   IS
   BEGIN
      HTP.
      p (
         '<head>
            <style type="text/css">
                body {
                    background-image:url(''http://moraschi.eu/MicroStrategy/style/mstr/images/wait2.gif''); 
                    background-repeat:no-repeat; 
                    background-position:center center;
                    font-family:helvetica, impact, sans-serif;
                    font-size:20px;
                    color:light-grey;
                    }
            </style>
        </head>
        <body onload=''submitform()''>
        <div>Redirecting ...</div>
            <form name="loginForm" action="'||pq_constants.con_str_hostname||'/MicroStrategy/servlet/mstrWeb?server=ip-10-203-1-178&port=0&project=EUROSTAT&evt=2001&src=mstrWeb.2001&systemFolder=7&hiddenSections=header" method="post" >
            <input type="hidden" name="token" value='
         || token
         || ' >
            </form>
        <SCRIPT language="JavaScript">
        function submitform()
        {
          document.loginForm.submit();
        }
        </SCRIPT> 
        </body>
');
   EXCEPTION
      WHEN OTHERS
      THEN
         utl_linkedin.senderroroutput (SQLERRM, DBMS_UTILITY.format_error_backtrace);
   END jsp;
END mstr_lnkd_dologin;
/
