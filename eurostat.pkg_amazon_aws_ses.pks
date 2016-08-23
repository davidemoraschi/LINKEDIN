DROP PACKAGE PKG_AMAZON_AWS_SES;

CREATE OR REPLACE PACKAGE          PKG_AMAZON_AWS_SES
IS
   FUNCTION SendEmail (p_Sender      IN VARCHAR2,
                       p_Recipient   IN VARCHAR2,
                       p_Subject     IN VARCHAR2,
                       p_Html_Body   IN VARCHAR2)
      RETURN BOOLEAN;
END;
/
