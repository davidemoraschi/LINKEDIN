DROP PROCEDURE LOGIN;

CREATE OR REPLACE PROCEDURE login
AS
BEGIN
   HTP.p ('<FRAMESET cols="20%, 80%">
  <FRAMESET rows="100, 200">
      <FRAME name="top_left" src="request_token">
      <FRAME name="bottom_left" src="about:blank">
  </FRAMESET>
  <FRAME name="right" src="about:blank">
</FRAMESET>');
END;
/
