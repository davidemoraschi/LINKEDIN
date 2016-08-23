DROP PACKAGE LOAD_BULK;

CREATE OR REPLACE PACKAGE          load_bulk
IS
	PROCEDURE table_of_contents_en;

	--   FUNCTION TABLE_OF_CONTENTS_EN
	-- 	  RETURN table_of_contents_table_type;

	http_req 							UTL_HTTP.req;
	http_resp							UTL_HTTP.resp;

	PROCEDURE dpr_clobtofile (p_filename IN VARCHAR2, p_dir IN VARCHAR2, p_clob IN CLOB);

	PROCEDURE dpr_blobtofile (p_filename IN VARCHAR2, p_dir IN VARCHAR2, p_blob IN BLOB);

	PROCEDURE text (p_url		  IN VARCHAR2 := 'http://www.google.com'
						,p_dir		  IN VARCHAR2 := 'OAUTH'
						,p_filename   IN VARCHAR2 := 'test.txt');

	PROCEDURE binary (p_url 		 IN VARCHAR2 := 'http://www.google.com/images/logos/mail_logo.png'
						  ,p_dir 		 IN VARCHAR2 := 'OAUTH'
						  ,p_filename	 IN VARCHAR2 := 'mail_logo.png');
END;
/
