DROP PACKAGE BODY MAIN;

CREATE OR REPLACE PACKAGE BODY          main
AS
   PROCEDURE jsp
   IS
/*
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
   "http://www.w3.org/TR/html4/frameset.dtd">
<HTML>
<HEAD>
<TITLE>A well-designed frameset document</TITLE>
</HEAD>
<FRAMESET cols="20%, 80%">
   <FRAME src="table_of_contents.html">
   <FRAME src="ostrich-container.html">
</FRAMESET>
</HTML>
    <!-- HTML -->
    <a class="a-thumb"><img src="/img/proxy-thumb.gif" /><span> </span></a>
     
    a.a-thumb {
    border: 1px solid black;
    position: relative;}
    a.a-thumb img {
    width: 60px;
    height: 60px;
    border: 0;}
    a.a-thumb span {
    background-color: #000000;
    position: absolute;
    top: 0;
    left: 0;
    width: 60px;
    height: 60px;
    z-index: 100;
    filter: alpha(opacity=20);
    -moz-opacity: 0.2;
    opacity: 0.2;}

*/
   BEGIN
      HTP.p ('<frameset cols="20%, 80%"><frame src="main.frame_001" name="frame_001"><frame src="main.frame_002" name="frame_002"></frameset>');
   END jsp;
   procedure frame_001
   is
   begin
   --HTP.p ('frame 1');
   HTP.p ('<a target="frame_002" href="obj_goog_request_token.jsp"><img src="http://dl.dropbox.com/u/1737369/32px/google.png" alt="HTML basic concepts" border=0></a><br><br>');
   HTP.p ('<a target="frame_002" href="obj_lnkd_request_token.jsp"><img src="http://dl.dropbox.com/u/1737369/32px/linkedin.png" alt="HTML tags and links" border=0></a><br><br>');
   HTP.p ('<a target="parent" href="obj_drbx_request_token.jsp"><img src="http://dl.dropbox.com/u/1737369/32px/dropbox.png" alt="HTML tags and links" border=0></a><br><br>');

   HTP.p ('<a target="frame_002" href="frames2.html"><img src="http://dl.dropbox.com/u/1737369/32px/msn.png" alt="HTML tags and links" border=0></a><br><br>');
   HTP.p ('<a target="frame_002" href="frames2.html"><img src="http://dl.dropbox.com/u/1737369/32px/yahoo.png" alt="HTML tags and links" border=0></a><br><br>');

   end;
   procedure frame_002
   is
   begin
   HTP.p ('frame 2');
   end;
END main;
/
