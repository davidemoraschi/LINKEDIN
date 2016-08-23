DROP PROCEDURE SHOW_URL;

CREATE OR REPLACE PROCEDURE          show_url (url        IN VARCHAR2,
                                               username   IN VARCHAR2 DEFAULT NULL,
                                               password   IN VARCHAR2 DEFAULT NULL)
AS
   req         UTL_HTTP.REQ;
   resp        UTL_HTTP.RESP;
   name        VARCHAR2 (256);
   VALUE       VARCHAR2 (1024);
   data        VARCHAR2 (255);
   my_scheme   VARCHAR2 (256);
   my_realm    VARCHAR2 (256);
   my_proxy    BOOLEAN;
BEGIN
   -- When going through a firewall, pass requests through this host.
   -- Specify sites inside the firewall that don't need the proxy host.

   --   UTL_HTTP.SET_PROXY ('proxy.example.com', 'corp.example.com');
   UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   -- Ask UTL_HTTP not to raise an exception for 4xx and 5xx status codes,
   -- rather than just returning the text of the error page.

   UTL_HTTP.SET_RESPONSE_ERROR_CHECK (FALSE);

   -- Begin retrieving this Web page.
   req := UTL_HTTP.BEGIN_REQUEST (url);

   -- Identify yourself.
   --  Some sites serve special pages for particular browsers.
   UTL_HTTP.SET_HEADER (req, 'User-Agent', 'Mozilla/4.0');
   UTL_HTTP.SET_HEADER (req, 'Accept', 'application/xml');

   -- Specify user ID and password for pages that require them.
   IF (username IS NOT NULL)
   THEN
      UTL_HTTP.SET_AUTHENTICATION (req, username, password);
   END IF;

   -- Start receiving the HTML text.
   resp := UTL_HTTP.GET_RESPONSE (req);

   -- Show status codes and reason phrase of response.
   --DBMS_OUTPUT.PUT_LINE ('HTTP response status code: ' || resp.status_code);
   --DBMS_OUTPUT.PUT_LINE ('HTTP response reason phrase: ' || resp.reason_phrase);

   -- Look for client-side error and report it.
   IF (resp.status_code >= 400) AND (resp.status_code <= 499)
   THEN
      -- Detect whether page is password protected
      -- and you didn't supply the right authorization.

      IF (resp.status_code = UTL_HTTP.HTTP_UNAUTHORIZED)
      THEN
         UTL_HTTP.GET_AUTHENTICATION (resp,
                                      my_scheme,
                                      my_realm,
                                      my_proxy);

         IF (my_proxy)
         THEN
            DBMS_OUTPUT.PUT_LINE ('Web proxy server is protected.');
            DBMS_OUTPUT.PUT (
                  'Please supply the required '
               || my_scheme
               || ' authentication username/password for realm '
               || my_realm
               || ' for the proxy server.');
         ELSE
            DBMS_OUTPUT.PUT_LINE ('Web page ' || url || ' is protected.');
            DBMS_OUTPUT.PUT (
                  'Please supplied the required '
               || my_scheme
               || ' authentication username/password for realm '
               || my_realm
               || ' for the Web page.');
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE ('Check the URL.');
      END IF;

      UTL_HTTP.END_RESPONSE (resp);
      RETURN;
   -- Look for server-side error and report it.
   ELSIF (resp.status_code >= 500) AND (resp.status_code <= 599)
   THEN
      DBMS_OUTPUT.PUT_LINE ('Check if the Web site is up.');
      UTL_HTTP.END_RESPONSE (resp);
      RETURN;
   END IF;

   -- HTTP header lines contain information about cookies, character sets,
   -- and other data that client and server can use to customize each
   -- session.

   FOR i IN 1 .. UTL_HTTP.GET_HEADER_COUNT (resp)
   LOOP
      UTL_HTTP.GET_HEADER (resp,
                           i,
                           name,
                           VALUE);
      --DBMS_OUTPUT.PUT_LINE (name || ': ' || VALUE);
   END LOOP;

   -- Read lines until none are left and an exception is raised.
   LOOP
      UTL_HTTP.READ_LINE (resp, VALUE);
      DBMS_OUTPUT.PUT_LINE (VALUE);
   END LOOP;
EXCEPTION
   WHEN UTL_HTTP.END_OF_BODY
   THEN
      UTL_HTTP.END_RESPONSE (resp);
END;
/
