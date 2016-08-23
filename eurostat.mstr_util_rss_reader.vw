DROP VIEW MSTR_UTIL_RSS_READER;

/* Formatted on 10/08/2012 10:58:25 (QP5 v5.139.911.3011) */
CREATE OR REPLACE FORCE VIEW MSTR_UTIL_RSS_READER
(
   RSS_ITEM_ID,
   RSS_ITEM_TITLE,
   RSS_ITEM_LINK_URL,
   RSS_ITEM_DESCRIPTION
)
AS
   SELECT ROWNUM RSS_ITEM_ID,
          EXTRACTVALUE (VALUE (p), '/item/title') RSS_ITEM_TITLE,
          EXTRACTVALUE (VALUE (p), '/item/link') RSS_ITEM_LINK_URL,
          EXTRACTVALUE (VALUE (p), '/item/description') RSS_ITEM_DESCRIPTION
     FROM TABLE (
             XMLSEQUENCE (EXTRACT (xmltype (HTTPURITYPE.createuri ('http://www.economist.com/rss/leaders_rss.xml').getclob (),
                                            NULL,
                                            1,
                                            1), '/rss/channel/item', 'xmlns:media="http://search.yahoo.com/mrss/"'))) p;
