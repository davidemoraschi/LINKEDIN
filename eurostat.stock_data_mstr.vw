DROP VIEW STOCK_DATA_MSTR;

/* Formatted on 10/08/2012 10:58:39 (QP5 v5.139.911.3011) */
CREATE OR REPLACE FORCE VIEW STOCK_DATA_MSTR
(
   TICKER,
   QUOTE_DATE,
   OPEN,
   HIGH,
   LOW,
   CLOSE,
   VOLUME,
   ADJ_CLOSE
)
AS
   SELECT 'MSTR' ticker,
          TO_DATE (c001, 'YYYY-MM-DD') quote_Date,
          TO_NUMBER (c002) Open,
          TO_NUMBER (c003) High,
          TO_NUMBER (c004) Low,
          TO_NUMBER (c005) Close,
          TO_NUMBER (c006) Volume,
          TO_NUMBER (c007) Adj_Close
     FROM TABLE (
             csv_util_pkg.
             clob_to_csv (
                httpuritype ('http://ichart.finance.yahoo.com/table.csv?s=MSTR&d=2&e=21&f=2012&g=d&a=1&b=1&c=2012&ignore=.csv').
                getclob ()))
    WHERE line_number > 1 AND c001 IS NOT NULL;
