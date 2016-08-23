DROP PACKAGE BODY MSTR_EAN0_FFSQL;

CREATE OR REPLACE PACKAGE BODY          mstr_ean0_FFSQL
AS
   --   FUNCTION getAirAvailability_SegmentList
   --      RETURN SegmentList_table_type
   --   IS
   --      v_tab                          SegmentList_table_type := SegmentList_table_type ();
   --      v_cursor                       SYS_REFCURSOR;
   --
   --      "v_Segment key"                VARCHAR2 (30);
   --      "v_airlineCode"                VARCHAR2 (2);
   --      "v_airline"                    VARCHAR2 (120);
   --      "v_flightNumber"               VARCHAR2 (20);
   --      "v_originCityCode"             VARCHAR2 (3);
   --      "v_destinationCityCode"        VARCHAR2 (3);
   --      "v_departureDateTime"          DATE;
   --      "v_arrivalDateTime"            DATE;
   --      "v_equipmentCode"              VARCHAR2 (3);
   --      "v_originCity"                 VARCHAR2 (100);
   --      "v_originStateProvince"        VARCHAR2 (20);
   --      "v_originCountry"              VARCHAR2 (20);
   --      "v_destinationCity"            VARCHAR2 (100);
   --      "v_desintationStateProvince"   VARCHAR2 (20);
   --      "v_destinationCountry"         VARCHAR2 (20);
   --
   --      var_http_request               UTL_HTTP.req;
   --      var_http_response              UTL_HTTP.resp;
   --      var_http_value                 VARCHAR2 (32767);
   --   var_http_api_url   VARCHAR2 (30000) := 'http://api.ean.com/ean-services/rs/air/200919/xmlinterface.jsp?';
   --   xml_request        XMLTYPE
   --                         := xmltype (
   --                               '<AirSessionRequest method="getAirAvailability"><AirAvailabilityQuery><originCityCode>SVQ</originCityCode><destinationCityCode>MXP</destinationCityCode><departureDateTime>'
   --                               || TO_CHAR (SYSDATE + 2, 'MM/DD/YYYY HH:MI AM')
   --                               || '</departureDateTime><returnDateTime>'
   --                               || TO_CHAR (SYSDATE + 4, 'MM/DD/YYYY HH:MI AM')
   --                               || '</returnDateTime><fareClass>Y</fareClass><tripType>R</tripType><Passengers><adultPassengers>1</adultPassengers></Passengers><xmlResultFormat>2</xmlResultFormat><searchType>2</searchType></AirAvailabilityQuery></AirSessionRequest>');
   --
   --      xml_clob_response              CLOB;
   --      xml_xml_response               XMLTYPE;
   --   BEGIN
   --      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   --      --UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   --      UTL_HTTP.set_response_error_check (FALSE);
   --      UTL_HTTP.set_detailed_excp_support (FALSE);
   --
   --      var_http_api_url :=
   --            var_http_api_url
   --         || 'cid=55505&resType=air&intfc=ws&apiKey=nah82c9ffkdmje6sqc8j4qjz&xml='
   --         || REPLACE (utl_linkedin.urlencode (xml_request.getstringval ()), ' ', '%20');
   --
   --      SELECT urifactory.getUri (var_http_api_url).getclob () INTO xml_clob_response FROM DUAL;
   --
   --      xml_xml_response := xmltype (xml_clob_response);
   --
   --      OPEN v_cursor FOR
   --         SELECT EXTRACTVALUE (VALUE (p), '/Segment/@key') "Segment key",
   --                EXTRACTVALUE (VALUE (p), '/Segment/airlineCode') "airlineCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/airline') "airline",
   --                EXTRACTVALUE (VALUE (p), '/Segment/flightNumber') "flightNumber",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCityCode') "originCityCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCityCode') "destinationCityCode",
   --                TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/departureDateTime'), 'MM/DD/YYYY HH:MI AM')
   --                   "departureDateTime",
   --                TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/arrivalDateTime'), 'MM/DD/YYYY HH:MI AM') "arrivalDateTime",
   --                EXTRACTVALUE (VALUE (p), '/Segment/equipmentCode') "equipmentCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCity') "originCity",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originStateProvince') "originStateProvince",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCountry') "originCountry",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCity') "destinationCity",
   --                EXTRACTVALUE (VALUE (p), '/Segment/desintationStateProvince') "desintationStateProvince",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCountry') "destinationCountry"
   --           FROM TABLE (XMLSEQUENCE (EXTRACT (xml_xml_response, 'AirAvailabilityResults/SegmentList/Segment'))) p;
   --
   --      LOOP
   --         FETCH v_cursor
   --         INTO "v_Segment key",
   --              "v_airlineCode",
   --              "v_airline",
   --              "v_flightNumber",
   --              "v_originCityCode",
   --              "v_destinationCityCode",
   --              "v_departureDateTime",
   --              "v_arrivalDateTime",
   --              "v_equipmentCode",
   --              "v_originCity",
   --              "v_originStateProvince",
   --              "v_originCountry",
   --              "v_destinationCity",
   --              "v_desintationStateProvince",
   --              "v_destinationCountry";
   --
   --         EXIT WHEN v_cursor%NOTFOUND;
   --
   --         v_tab.EXTEND;
   --         v_tab (v_tab.LAST) :=
   --            SegmentList_row_type ("v_Segment key",
   --                                  "v_airlineCode",
   --                                  "v_airline",
   --                                  "v_flightNumber",
   --                                  "v_originCityCode",
   --                                  "v_destinationCityCode",
   --                                  "v_departureDateTime",
   --                                  "v_arrivalDateTime",
   --                                  "v_equipmentCode",
   --                                  "v_originCity",
   --                                  "v_originStateProvince",
   --                                  "v_originCountry",
   --                                  "v_destinationCity",
   --                                  "v_desintationStateProvince",
   --                                  "v_destinationCountry");
   --      END LOOP;
   --
   --      CLOSE v_cursor;
   --
   --      RETURN v_tab;
   --   END getAirAvailability_SegmentList;
   --
   --   FUNCTION getAirAvailability_SegmentList (p_originCityCode IN VARCHAR2, p_destinationCityCode IN VARCHAR2)
   --      RETURN SegmentList_table_type
   --   IS
   --      v_tab                          SegmentList_table_type := SegmentList_table_type ();
   --      v_cursor                       SYS_REFCURSOR;
   --
   --      "v_Segment key"                VARCHAR2 (30);
   --      "v_airlineCode"                VARCHAR2 (2);
   --      "v_airline"                    VARCHAR2 (120);
   --      "v_flightNumber"               VARCHAR2 (20);
   --      "v_originCityCode"             VARCHAR2 (3);
   --      "v_destinationCityCode"        VARCHAR2 (3);
   --      "v_departureDateTime"          DATE;
   --      "v_arrivalDateTime"            DATE;
   --      "v_equipmentCode"              VARCHAR2 (3);
   --      "v_originCity"                 VARCHAR2 (100);
   --      "v_originStateProvince"        VARCHAR2 (20);
   --      "v_originCountry"              VARCHAR2 (20);
   --      "v_destinationCity"            VARCHAR2 (100);
   --      "v_desintationStateProvince"   VARCHAR2 (20);
   --      "v_destinationCountry"         VARCHAR2 (20);
   --
   --      var_http_request               UTL_HTTP.req;
   --      var_http_response              UTL_HTTP.resp;
   --      var_http_value                 VARCHAR2 (32767);
   --      var_http_api_url               VARCHAR2 (30000)
   --                                        := 'http://api.ean.com/ean-services/rs/air/200919/xmlinterface.jsp?';
   --      xml_request                    XMLTYPE
   --                                        := xmltype (
   --                                              '<AirSessionRequest method="getAirAvailability"><AirAvailabilityQuery><originCityCode>'
   --                                              || TRIM (p_originCityCode)
   --                                              || '</originCityCode><destinationCityCode>'
   --                                              || TRIM (p_destinationCityCode)
   --                                              || '</destinationCityCode><departureDateTime>'
   --                                              || TO_CHAR (SYSDATE + 2, 'MM/DD/YYYY HH:MI AM')
   --                                              || '</departureDateTime><returnDateTime>'
   --                                              || TO_CHAR (SYSDATE + 4, 'MM/DD/YYYY HH:MI AM')
   --                                              || '</returnDateTime><fareClass>Y</fareClass><tripType>R</tripType><Passengers><adultPassengers>1</adultPassengers></Passengers><xmlResultFormat>2</xmlResultFormat><searchType>2</searchType></AirAvailabilityQuery></AirSessionRequest>');
   --      xml_clob_response              CLOB;
   --      xml_xml_response               XMLTYPE;
   --   BEGIN
   --      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
   --      --UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
   --      UTL_HTTP.set_response_error_check (FALSE);
   --      UTL_HTTP.set_detailed_excp_support (FALSE);
   --
   --      var_http_api_url :=
   --            var_http_api_url
   --         || 'cid=55505&resType=air&intfc=ws&apiKey=nah82c9ffkdmje6sqc8j4qjz&xml='
   --         || REPLACE (utl_linkedin.urlencode (xml_request.getstringval ()), ' ', '%20');
   --
   --      SELECT urifactory.getUri (var_http_api_url).getclob () INTO xml_clob_response FROM DUAL;
   --
   --      xml_xml_response := xmltype (xml_clob_response);
   --
   --      OPEN v_cursor FOR
   --         SELECT EXTRACTVALUE (VALUE (p), '/Segment/@key') "Segment key",
   --                EXTRACTVALUE (VALUE (p), '/Segment/airlineCode') "airlineCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/airline') "airline",
   --                EXTRACTVALUE (VALUE (p), '/Segment/flightNumber') "flightNumber",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCityCode') "originCityCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCityCode') "destinationCityCode",
   --                TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/departureDateTime'), 'MM/DD/YYYY HH:MI AM')
   --                   "departureDateTime",
   --                TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/arrivalDateTime'), 'MM/DD/YYYY HH:MI AM') "arrivalDateTime",
   --                EXTRACTVALUE (VALUE (p), '/Segment/equipmentCode') "equipmentCode",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCity') "originCity",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originStateProvince') "originStateProvince",
   --                EXTRACTVALUE (VALUE (p), '/Segment/originCountry') "originCountry",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCity') "destinationCity",
   --                EXTRACTVALUE (VALUE (p), '/Segment/desintationStateProvince') "desintationStateProvince",
   --                EXTRACTVALUE (VALUE (p), '/Segment/destinationCountry') "destinationCountry"
   --           FROM TABLE (XMLSEQUENCE (EXTRACT (xml_xml_response, 'AirAvailabilityResults/SegmentList/Segment'))) p;
   --
   --      LOOP
   --         FETCH v_cursor
   --         INTO "v_Segment key",
   --              "v_airlineCode",
   --              "v_airline",
   --              "v_flightNumber",
   --              "v_originCityCode",
   --              "v_destinationCityCode",
   --              "v_departureDateTime",
   --              "v_arrivalDateTime",
   --              "v_equipmentCode",
   --              "v_originCity",
   --              "v_originStateProvince",
   --              "v_originCountry",
   --              "v_destinationCity",
   --              "v_desintationStateProvince",
   --              "v_destinationCountry";
   --
   --         EXIT WHEN v_cursor%NOTFOUND;
   --
   --         v_tab.EXTEND;
   --         v_tab (v_tab.LAST) :=
   --            SegmentList_row_type ("v_Segment key",
   --                                  "v_airlineCode",
   --                                  "v_airline",
   --                                  "v_flightNumber",
   --                                  "v_originCityCode",
   --                                  "v_destinationCityCode",
   --                                  "v_departureDateTime",
   --                                  "v_arrivalDateTime",
   --                                  "v_equipmentCode",
   --                                  "v_originCity",
   --                                  "v_originStateProvince",
   --                                  "v_originCountry",
   --                                  "v_destinationCity",
   --                                  "v_desintationStateProvince",
   --                                  "v_destinationCountry");
   --      END LOOP;
   --
   --      CLOSE v_cursor;
   --
   --      RETURN v_tab;
   --   END getAirAvailability_SegmentList;
   FUNCTION getAirAvailability_V2 (p_originCityCode        IN VARCHAR2,
                                   p_destinationCityCode   IN VARCHAR2,
                                   p_departureDateTime     IN DATE:= SYSDATE + 2,
                                   p_returnDateTime        IN DATE:= SYSDATE + 4,
                                   p_currencyCode          IN VARCHAR2:= 'EUR',
                                   p_fareClass             IN VARCHAR2:= 'B')
      RETURN mstr_ean0_Segment_table_type
   IS
      v_tab                          mstr_ean0_Segment_table_type := mstr_ean0_Segment_table_type ();
      v_syscursor                    SYS_REFCURSOR;
      "v_segmentKey"                 VARCHAR2 (30);
      "v_supplierType"               VARCHAR2 (2);
      "v_tripType"                   VARCHAR2 (1);
      "v_ticketType"                 VARCHAR2 (1);
      "v_displayTotalPrice"          NUMBER;
      "v_displayCurrencyCode"        VARCHAR2 (3);
      "v_fareClass"                  VARCHAR2 (2);
      "v_airlineCode"                VARCHAR2 (2);
      "v_airline"                    VARCHAR2 (120);
      "v_flightNumber"               VARCHAR2 (20);
      "v_originCityCode"             VARCHAR2 (3);
      "v_destinationCityCode"        VARCHAR2 (3);
      "v_departureDateTime"          DATE;
      "v_arrivalDateTime"            DATE;
      "v_equipmentCode"              VARCHAR2 (3);
      "v_originCity"                 VARCHAR2 (100);
      "v_originStateProvince"        VARCHAR2 (20);
      "v_originCountry"              VARCHAR2 (20);
      "v_destinationCity"            VARCHAR2 (100);
      "v_desintationStateProvince"   VARCHAR2 (20);
      "v_destinationCountry"         VARCHAR2 (20);
      --
      --      var_http_request               UTL_HTTP.req;
      --      var_http_response              UTL_HTTP.resp;
      --      var_http_value                 VARCHAR2 (32767);
      var_http_api_url               VARCHAR2 (30000)
                                        := 'http://api.ean.com/ean-services/rs/air/200919/xmlinterface.jsp?';
      xml_request                    XMLTYPE
                                        := xmltype (
                                              '<AirSessionRequest method="getAirAvailability"><AirAvailabilityQuery><originCityCode>'
                                              || TRIM (p_originCityCode)
                                              || '</originCityCode><destinationCityCode>'
                                              || TRIM (p_destinationCityCode)
                                              || '</destinationCityCode><departureDateTime>'
                                              || TO_CHAR (p_departureDateTime, 'MM/DD/YYYY HH:MI AM')
                                              || '</departureDateTime><returnDateTime>'
                                              || TO_CHAR (p_returnDateTime, 'MM/DD/YYYY HH:MI AM')
                                              || '</returnDateTime><fareClass>'
                                              || p_fareClass
                                              || '</fareClass><tripType>R</tripType><currencyCode>'
                                              || p_currencyCode
                                              || '</currencyCode><numResultsRequested>10</numResultsRequested><Passengers><adultPassengers>1</adultPassengers></Passengers><xmlResultFormat>2</xmlResultFormat><searchType>2</searchType></AirAvailabilityQuery></AirSessionRequest>');
      --      xml_clob_response              CLOB;
      xml_xml_response               XMLTYPE;
   BEGIN
      --      UTL_HTTP.set_proxy (pq_constants.con_str_http_proxy);
      --      --UTL_HTTP.set_wallet (PATH => pq_constants.con_str_wallet_path, password => pq_constants.con_str_wallet_pass);
      --      UTL_HTTP.set_response_error_check (FALSE);
      --      UTL_HTTP.set_detailed_excp_support (FALSE);
      --
      var_http_api_url :=
            var_http_api_url
         || 'cid=55505&resType=air&intfc=ws&apiKey=nah82c9ffkdmje6sqc8j4qjz&xml='
         || REPLACE (utl_linkedin.urlencode (xml_request.getstringval ()), ' ', '%20');

      SELECT xmltype (urifactory.getUri (var_http_api_url).getclob ()) INTO xml_xml_response FROM DUAL;

      --
      --      xml_xml_response := xmltype (xml_clob_response);
      --
      OPEN v_syscursor FOR
         SELECT "segmentKey",
                "supplierType",
                "tripType",
                "ticketType",
                "displayTotalPrice",
                "displayCurrencyCode",
                "fareClass",
                "airlineCode",
                "airline",
                "flightNumber",
                "originCityCode",
                "destinationCityCode",
                "departureDateTime",
                "arrivalDateTime",
                "equipmentCode",
                "originCity",
                "originStateProvince",
                "originCountry",
                "destinationCity",
                "desintationStateProvince",
                "destinationCountry"
           FROM    (SELECT EXTRACTVALUE (VALUE (p), '/AirAvailabilityReply/supplierType') "supplierType" --, entry
                                                                                                        ,
                           EXTRACTVALUE (VALUE (p), '/AirAvailabilityReply/tripType') "tripType" --, entry
                                                                                                ,
                           EXTRACTVALUE (VALUE (p), '/AirAvailabilityReply/ticketType') "ticketType" --, entry
                                                                                                    ,
                           TO_NUMBER (EXTRACTVALUE (VALUE (p), '/AirAvailabilityReply/RateInfo/displayTotalPrice'),
                                      '999999999999999D9999999999',
                                      'NLS_NUMERIC_CHARACTERS=''.,''')
                              "displayTotalPrice" --, entry
                                                 ,
                           EXTRACTVALUE (VALUE (p), '/AirAvailabilityReply/RateInfo/displayCurrencyCode')
                              "displayCurrencyCode" --, entry
                                                   ,
                           EXTRACTVALUE (VALUE (q), '/FlightSegment/segmentKey') "segmentKey" --, entry
                                                                                             ,
                           EXTRACTVALUE (VALUE (q), '/FlightSegment/fareClass') "fareClass" --, entry
                      FROM TABLE (
                              XMLSEQUENCE (EXTRACT (xml_xml_response, '/AirAvailabilityResults/AirAvailabilityReply'))) p,
                           TABLE (XMLSEQUENCE (EXTRACT (VALUE (p), '/AirAvailabilityReply/FlightSegment'))) q)
                JOIN
                   (SELECT EXTRACTVALUE (VALUE (p), '/Segment/@key') "segmentKey" --, entry
                                                                                 ,
                           EXTRACTVALUE (VALUE (p), '/Segment/airlineCode') "airlineCode",
                           EXTRACTVALUE (VALUE (p), '/Segment/airline') "airline",
                           EXTRACTVALUE (VALUE (p), '/Segment/flightNumber') "flightNumber",
                           EXTRACTVALUE (VALUE (p), '/Segment/originCityCode') "originCityCode",
                           EXTRACTVALUE (VALUE (p), '/Segment/destinationCityCode') "destinationCityCode",
                           TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/departureDateTime'), 'MM/DD/YYYY HH:MI AM')
                              "departureDateTime",
                           TO_DATE (EXTRACTVALUE (VALUE (p), '/Segment/arrivalDateTime'), 'MM/DD/YYYY HH:MI AM')
                              "arrivalDateTime",
                           EXTRACTVALUE (VALUE (p), '/Segment/equipmentCode') "equipmentCode",
                           EXTRACTVALUE (VALUE (p), '/Segment/originCity') "originCity",
                           EXTRACTVALUE (VALUE (p), '/Segment/originStateProvince') "originStateProvince",
                           EXTRACTVALUE (VALUE (p), '/Segment/originCountry') "originCountry",
                           EXTRACTVALUE (VALUE (p), '/Segment/destinationCity') "destinationCity",
                           EXTRACTVALUE (VALUE (p), '/Segment/desintationStateProvince') "desintationStateProvince",
                           EXTRACTVALUE (VALUE (p), '/Segment/destinationCountry') "destinationCountry"
                      FROM TABLE (
                              XMLSEQUENCE (EXTRACT (xml_xml_response, '/AirAvailabilityResults/SegmentList/Segment'))) p)
                USING ("segmentKey");

      LOOP
         FETCH v_syscursor
         INTO "v_segmentKey",
              "v_supplierType",
              "v_tripType",
              "v_ticketType",
              "v_displayTotalPrice",
              "v_displayCurrencyCode",
              "v_fareClass",
              "v_airlineCode",
              "v_airline",
              "v_flightNumber",
              "v_originCityCode",
              "v_destinationCityCode",
              "v_departureDateTime",
              "v_arrivalDateTime",
              "v_equipmentCode",
              "v_originCity",
              "v_originStateProvince",
              "v_originCountry",
              "v_destinationCity",
              "v_desintationStateProvince",
              "v_destinationCountry";

         EXIT WHEN v_syscursor%NOTFOUND;

         v_tab.EXTEND;
         v_tab (v_tab.LAST) :=
            mstr_ean0_Segment_row_type ("v_segmentKey",
                                        "v_supplierType",
                                        "v_tripType",
                                        "v_ticketType",
                                        "v_displayTotalPrice",
                                        "v_displayCurrencyCode",
                                        "v_fareClass",
                                        "v_airlineCode",
                                        "v_airline",
                                        "v_flightNumber",
                                        "v_originCityCode",
                                        "v_destinationCityCode",
                                        "v_departureDateTime",
                                        "v_arrivalDateTime",
                                        "v_equipmentCode",
                                        "v_originCity",
                                        "v_originStateProvince",
                                        "v_originCountry",
                                        "v_destinationCity",
                                        "v_desintationStateProvince",
                                        "v_destinationCountry");
      END LOOP;

      CLOSE v_syscursor;

      --
      RETURN v_tab;
   END getAirAvailability_V2;
END mstr_ean0_FFSQL;
/
