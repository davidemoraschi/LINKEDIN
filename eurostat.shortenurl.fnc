DROP FUNCTION SHORTENURL;

CREATE OR REPLACE FUNCTION shortenurl (p_long_url IN VARCHAR2)
   RETURN VARCHAR2
AS
BEGIN
   RETURN REPLACE (
             REPLACE (
                REPLACE (
                   UTL_HTTP.request (
                         'http://api.bit.ly/v3/shorten?login=valme&apiKey=R_27491eb4f42590a3f1ba5a4f0ad8dd6b&longUrl='
                      || urlencode (p_long_url)
                      || '&format=txt',
                      pq_constants.con_str_http_proxy),
                   CHR (10)),
                CHR (13)),
             CHR (9));
END shortenurl;
/
