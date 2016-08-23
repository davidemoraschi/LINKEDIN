DROP PROCEDURE CHECK_TOKEN;

CREATE OR REPLACE PROCEDURE          check_token (nexturl IN VARCHAR2 := 'about:blank')
AS
	v_oauth_token						OWA_COOKIE.cookie;
	v_token_secret 					OWA_COOKIE.cookie;
BEGIN
	OWA_UTIL.mime_header ('text/html', FALSE);
	OWA_COOKIE.send ('nexturl', nexturl);
	OWA_UTIL.http_header_close;
	v_oauth_token := OWA_COOKIE.get ('oauth_access_token');
	v_token_secret := OWA_COOKIE.get ('oauth_token_secret');
	IF v_oauth_token.num_vals = 0 AND v_token_secret.num_vals = 0
	THEN
		HTP.p (
			'<script type="text/javascript">window.location = "' || '/sso/request_token?originalurl=' || nexturl --   || '&port='
																																				  --	|| port
			|| '"</script>');
	ELSE
		--  HTP.p ('<script type="text/javascript">window.location = "' || '/sso/get_profile' || '"</script>');
		HTP.p (
				'<script type="text/javascript">window.location = "'
			|| 'http://moraschi.eu/sso/jsp/doLogin.jsp?token='
			|| v_oauth_token.vals (1)
			|| '&nextURL='
			|| utl_linkedin.urlencode(nexturl)
			|| '"</script>');
	END IF;
END;
/
