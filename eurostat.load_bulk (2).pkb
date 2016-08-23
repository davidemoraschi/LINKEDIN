DROP PACKAGE BODY LOAD_BULK;

CREATE OR REPLACE PACKAGE BODY          load_bulk
IS
	PROCEDURE table_of_contents_en
	IS
		p_url 								VARCHAR2 (2500)
			:= 'http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?sort=1&file=table_of_contents_en.txt';
		p_filename							VARCHAR2 (250) := 'table_of_contents_en.txt';
		--l_clob 					 CLOB;
		p_result_in_response 			XMLTYPE;
		v_obj_twitter						twitter;
	BEGIN
		text (p_url => p_url, p_dir => 'EUROSTAT', p_filename => p_filename);

		BEGIN
			INSERT INTO log_table_of_contents
			VALUES		(SUBSTR (p_filename, 1, LENGTH (p_filename) - 4), SYSTIMESTAMP);
		EXCEPTION
			WHEN DUP_VAL_ON_INDEX
			THEN
				UPDATE log_table_of_contents
				SET	 content_last_download = SYSTIMESTAMP
				WHERE  content_code = SUBSTR (p_filename, 1, LENGTH (p_filename) - 4);
		END;

		--twitter_old.update_status ('downloaded ' || p_filename);
		SELECT (obj_twitter)
		INTO	 v_obj_twitter
		FROM	 objs_twitter
		WHERE  account = '382533930';

		v_obj_twitter.post_status (p_status => 'downloaded ' || p_filename, p_result_in_response => p_result_in_response);
	END table_of_contents_en;

	--   FUNCTION TABLE_OF_CONTENTS_EN
	-- 	  RETURN table_of_contents_table_type
	--   IS
	-- 	  l_TABLE_OF_CONTENTS_EN	CLOB;
	-- 	  v_tab							table_of_contents_table_type
	-- 											:= table_of_contents_table_type ();
	-- 	  cursor_contents 			SYS_REFCURSOR;
	-- 	  v_r 							VARCHAR2 (32767);
	--   BEGIN
	-- 	  TABLE_OF_CONTENTS_EN (l_clob => l_TABLE_OF_CONTENTS_EN);
	--
	-- 	  OPEN cursor_contents FOR
	-- 		  WITH t
	-- 					 AS (SELECT 'Call me Ishmael. Some years ago - never mind how long precisely - having little or no money in my purse,
	--  and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world.
	--  It is a way I have of driving off the spleen, and regulating the circulation.
	--  Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find
	--  myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially
	--  whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately
	--  stepping into the street, and methodically knocking people''s hats off - then, I account it high time to get to sea as
	--  soon as I can.
	--  This is my substitute for pistol and ball.
	--  With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship.
	--  There is nothing surprising in this.
	--  If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the
	--  ocean with me.
	--  There now is your insular city of the Manhattoes, belted round by wharves as Indian isles by coral reefs - commerce
	--  surrounds it with her surf.
	--  Right and left, the streets take you waterward.
	--  Its extreme down-town is the battery, where that noble mole is washed by waves, and cooled by breezes, which a few hours
	--  previous were out of sight of land.
	--  Look at the crowds of water-gazers there.
	--  Circumambulate the city of a dreamy Sabbath afternoon.
	--  Go from Corlears Hook to Coenties Slip, and from thence, by Whitehall northward.
	--  What do you see? - Posted like silent sentinels all around the town, stand thousands upon thousands of mortal men fixed in
	--  ocean reveries.
	-- Some leaning against the spiles; some seated upon the pier-heads; some looking over the bulwarks'
	-- 										AS txt
	-- 							 FROM DUAL)
	-- 		  SELECT EXTRACTVALUE (VALUE (p), '/y')
	-- 			 FROM t,
	-- 					TABLE (
	-- 						XMLSEQUENCE (
	-- 							EXTRACT (
	-- 								xmltype (
	-- 									REPLACE (
	-- 										'<x><y>'
	-- 										|| DBMS_LOB.
	-- 											SUBSTR (l_TABLE_OF_CONTENTS_EN, 2000, 1)
	-- 										|| '</y></x>',
	-- 										CHR (10),
	-- 										'</y><y>')),
	-- 								'/x/y'))) p;
	--
	--
	-- 	  LOOP
	-- 		  FETCH cursor_contents INTO v_r;
	--
	-- 		  EXIT WHEN cursor_contents%NOTFOUND;
	--
	-- 		  v_tab.EXTEND;
	-- 		  v_tab (v_tab.LAST) := table_of_contents_row_type (v_r);
	-- 	  END LOOP;
	--
	-- 	  RETURN v_tab;
	--   END;
	--
	PROCEDURE dpr_clobtofile (p_filename IN VARCHAR2, p_dir IN VARCHAR2, p_clob IN CLOB)
	IS
		c_amount 				CONSTANT BINARY_INTEGER := 32767;
		l_buffer 							VARCHAR2 (32767);
		l_chr10								PLS_INTEGER;
		l_cloblen							PLS_INTEGER;
		l_fhandler							UTL_FILE.file_type;
		l_pos 								PLS_INTEGER := 1;
	BEGIN
		l_cloblen := DBMS_LOB.getlength (p_clob);
		l_fhandler := UTL_FILE.fopen (p_dir, p_filename, 'W', c_amount);

		WHILE l_pos < l_cloblen
		LOOP
			l_buffer := DBMS_LOB.SUBSTR (p_clob, c_amount, l_pos);
			EXIT WHEN l_buffer IS NULL;
			l_chr10 := INSTR (l_buffer, CHR (10), -1);

			IF l_chr10 != 0
			THEN
				l_buffer := SUBSTR (l_buffer, 1, l_chr10 - 1);
			END IF;

			UTL_FILE.put_line (l_fhandler, l_buffer, TRUE);
			l_pos := l_pos + LEAST (LENGTH (l_buffer) + 1, c_amount);
		END LOOP;

		UTL_FILE.fclose (l_fhandler);
	EXCEPTION
		WHEN OTHERS
		THEN
			IF UTL_FILE.is_open (l_fhandler)
			THEN
				UTL_FILE.fclose (l_fhandler);
			END IF;

			RAISE;
	END dpr_clobtofile;

	PROCEDURE dpr_blobtofile (p_filename IN VARCHAR2, p_dir IN VARCHAR2, p_blob IN BLOB)
	IS
		c_amount 				CONSTANT BINARY_INTEGER := 32767;
		l_buffer 							RAW (32000);
		l_chr10								PLS_INTEGER;
		l_bloblen							PLS_INTEGER;
		l_fhandler							UTL_FILE.file_type;
		l_pos 								PLS_INTEGER := 1;
		bytelen								NUMBER := 32000;
		x										NUMBER;
	BEGIN
		l_bloblen := DBMS_LOB.getlength (p_blob);
		x := l_bloblen;
		l_fhandler := UTL_FILE.fopen (p_dir, p_filename, 'wb', c_amount);

		-- 		  UTL_FILE.FOPEN (p_dir,
		-- 								p_fileName,
		-- 								'W',
		-- 								c_amount);
		IF l_bloblen < 32760
		THEN
			UTL_FILE.put_raw (l_fhandler, p_blob);
			UTL_FILE.fflush (l_fhandler);
		ELSE -- write in pieces
			WHILE l_pos < l_bloblen AND bytelen > 0
			LOOP
				DBMS_LOB.read (p_blob, bytelen, l_pos, l_buffer);
				UTL_FILE.put_raw (l_fhandler, l_buffer);
				UTL_FILE.fflush (l_fhandler);
				-- set the start position for the next cut
				l_pos := l_pos + bytelen;
				-- set the end position if less than 32000 bytes
				x := x - bytelen;

				IF x < 32000
				THEN
					bytelen := x;
				END IF;
			--   l_buffer := DBMS_LOB.SUBSTR (p_blob, c_amount, l_pos);
			-- 			  EXIT WHEN l_buffer IS NULL;
			-- 			  l_chr10 := INSTR (l_buffer, CHR (10), -1);
			--
			-- 			  IF l_chr10 != 0
			-- 			  THEN
			-- 				  l_buffer := SUBSTR (l_buffer, 1, l_chr10 - 1);
			-- 			  END IF;
			--
			-- 			  UTL_FILE.PUT_LINE (l_fHandler, l_buffer, TRUE);
			-- 			  l_pos := l_pos + LEAST (LENGTH (l_buffer) + 1, c_amount);
			END LOOP;
		END IF;


		UTL_FILE.fclose (l_fhandler);
	EXCEPTION
		WHEN OTHERS
		THEN
			IF UTL_FILE.is_open (l_fhandler)
			THEN
				UTL_FILE.fclose (l_fhandler);
			END IF;

			RAISE;
	END dpr_blobtofile;

	PROCEDURE text (p_url		  IN VARCHAR2 := 'http://www.google.com'
						,p_dir		  IN VARCHAR2 := 'OAUTH'
						,p_filename   IN VARCHAR2 := 'test.txt')
	IS
		l_clob								CLOB;
	BEGIN
		l_clob := httpuritype.createuri (p_url).getclob ();
		dpr_clobtofile (p_filename => p_filename, p_dir => p_dir, p_clob => l_clob);
	--twitter.update_status('downloaded '||p_filename);
	END text;

	PROCEDURE binary (p_url 		 IN VARCHAR2 := 'http://www.google.com/images/logos/mail_logo.png'
						  ,p_dir 		 IN VARCHAR2 := 'OAUTH'
						  ,p_filename	 IN VARCHAR2 := 'mail_logo.png')
	IS
		l_blob								BLOB;
	BEGIN
		l_blob := httpuritype.createuri (p_url).getblob ();
		dpr_blobtofile (p_filename => p_filename, p_dir => p_dir, p_blob => l_blob);
	--twitter.update_status('downloaded '||p_filename);
	END binary;
END;
/
