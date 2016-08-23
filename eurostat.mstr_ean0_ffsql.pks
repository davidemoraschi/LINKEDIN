DROP PACKAGE MSTR_EAN0_FFSQL;

CREATE OR REPLACE PACKAGE          mstr_ean0_FFSQL
AS
   --   FUNCTION getAirAvailability_SegmentList /*obsolete*/
   --      RETURN SegmentList_table_type;
   --
   --   FUNCTION getAirAvailability_SegmentList /*obsolete*/
   --                                           (p_originCityCode IN VARCHAR2, p_destinationCityCode IN VARCHAR2)
   --      RETURN SegmentList_table_type;

   FUNCTION getAirAvailability_V2 (p_originCityCode        IN VARCHAR2,
                                   p_destinationCityCode   IN VARCHAR2,
                                   p_departureDateTime     IN DATE:= SYSDATE + 2,
                                   p_returnDateTime        IN DATE:= SYSDATE + 4,
                                   p_currencyCode          IN VARCHAR2:= 'EUR',
                                   p_fareClass             IN VARCHAR2:= 'B')
      RETURN mstr_ean0_Segment_table_type;
END mstr_ean0_FFSQL;
/
