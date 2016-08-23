DROP PROCEDURE TEST_FRESHBOOKS;

CREATE OR REPLACE PROCEDURE          test_freshbooks
as
	my_freshbooks						freshbooks;
BEGIN
	my_freshbooks :=
		NEW freshbooks (id							 => 'freshbooks'
							,oauth_consumer_key		 => 'moraschi'
							,oauth_consumer_secret	 => '3bmqaMUQDxzBiNqX8ptm6dGYWDEJNRaBiA');
-- my_dropbox.save;
--   DBMS_OUTPUT.put_line ('Consumer key:         ' || my_linkedin.oauth_consumer_key);
--   DBMS_OUTPUT.put_line ('Consumer Secret:      ' || my_linkedin.oauth_consumer_secret);
--   DBMS_OUTPUT.put_line ('api_url:              ' || my_linkedin.oauth_api_url);
--   DBMS_OUTPUT.put_line ('oauth_timestamp:      ' || my_linkedin.oauth_timestamp);
--   DBMS_OUTPUT.put_line ('oauth_nonce:          ' || my_linkedin.oauth_nonce);
--   DBMS_OUTPUT.put_line ('oauth_callback:       ' || my_linkedin.oauth_callback);
--   DBMS_OUTPUT.put_line ('oauth_base_string:    ' || my_linkedin.oauth_base_string);
--   DBMS_OUTPUT.put_line ('oauth_signature:      ' || my_linkedin.oauth_signature);
--   DBMS_OUTPUT.put_line ('authorization_header: ' || my_linkedin.var_http_authorization_header);
END;
/
