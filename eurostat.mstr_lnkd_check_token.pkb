DROP PACKAGE BODY MSTR_LNKD_CHECK_TOKEN;

CREATE OR REPLACE PACKAGE BODY          mstr_lnkd_check_token
AS
   PROCEDURE jsp (nexturl IN VARCHAR2 := 'about:blank')
   IS
   BEGIN
      OWA_UTIL.mime_header ('text/html', FALSE);
      --OWA_COOKIE.send ('nexturl', nexturl);
      OWA_UTIL.http_header_close;

      HTP.
      p (
            '<script type="text/javascript">window.location = "'
         || '/sso/mstr_lnkd_request_token.jsp?originalurl='
         || nexturl
         || '"</script>');
   END jsp;
END mstr_lnkd_check_token;
/
