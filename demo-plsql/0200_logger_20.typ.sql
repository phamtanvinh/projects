/* ******************************************************************
** TYP_LOGGER
** ******************************************************************/
CREATE OR REPLACE TYPE TYP_LOGGER FORCE
UNDER TYP_ALL_TS_DIM(
    TRANSACTION_ID         VARCHAR2(64),
    TRANSACTION_CODE       VARCHAR2(64),
    APP_USER               VARCHAR2(64),
    UNIT_NAME               VARCHAR2(64),
    UNIT_TYPE               VARCHAR2(64),
    DESCRIPTION             VARCHAR2(1024),
-- STATIC METHODS
    STATIC FUNCTION FNC_INIT_TRANSACTION_ID RETURN VARCHAR2,
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_LOGGER RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION TYP_LOGGER(
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL)  RETURN SELF AS RESULT,
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_TRANSACTION_INFO RETURN VARCHAR2,
    MEMBER FUNCTION FNC_GET_LOGGER_INFO RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION FNC_GET_INFO RETURN VARCHAR2,
-- MANIPULATAION METHODS
    MEMBER PROCEDURE PRC_UPDATE_LOGGER,
    MEMBER PROCEDURE PRC_UPDATE_TRANSACTION(
        PI_TRANSACTION_ID       VARCHAR2 DEFAULT NULL,
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL),
    MEMBER PROCEDURE PRC_INIT_LOGGER(
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL)
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY TYP_LOGGER
AS
-- STATIC METHODS
    STATIC FUNCTION FNC_INIT_TRANSACTION_ID RETURN VARCHAR2
    IS
    BEGIN
        RETURN DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);
    END;
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_LOGGER 
    RETURN SELF AS RESULT
    IS
    BEGIN
        TYPE_NAME           := 'TYP_LOGGER';
        SELF.PRC_INIT_LOGGER();
        RETURN;
    END;

    CONSTRUCTOR FUNCTION TYP_LOGGER(
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        TYPE_NAME           := 'TYP_LOGGER';
        SELF.PRC_INIT_LOGGER(
            PI_TRANSACTION_CODE     => PI_TRANSACTION_CODE,
            PI_APP_USER             => PI_APP_USER,
            PI_UNIT_NAME            => PI_UNIT_NAME,
            PI_UNIT_TYPE            => PI_UNIT_TYPE,
            PI_DESCRIPTION          => PI_DESCRIPTION);
        RETURN;
    END;
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_TRANSACTION_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
        L_DICTIONARY    PKG_UTIL.DICTIONARY;
    BEGIN
        L_DICTIONARY('TRANSACTION_ID')      := TRANSACTION_ID;
        L_DICTIONARY('TRANSACTION_CODE')    := TRANSACTION_CODE;
        L_DICTIONARY('APP_USER')            := APP_USER;
        L_DICTIONARY('UNIT_NAME')           := UNIT_NAME;
        L_DICTIONARY('UNIT_TYPE')           := UNIT_TYPE;
        L_DICTIONARY('DESCRIPTION')         := DESCRIPTION;
        L_INFO          := PKG_UTIL.FNC_GET_INFO(L_DICTIONARY);
        RETURN L_INFO;
    END;

    MEMBER FUNCTION FNC_GET_LOGGER_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
    BEGIN
        L_INFO          := L_INFO || SELF.FNC_GET_TRANSACTION_INFO();
        L_INFO          := L_INFO || SELF.FNC_ALL_TS_DIM_INFO();
        RETURN L_INFO;
    END;

    OVERRIDING MEMBER FUNCTION FNC_GET_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
    BEGIN
        L_INFO          := PKG_UTIL.FNC_GET_STRING_FORMAT('TYPE_NAME', TYPE_NAME);
        L_INFO          := L_INFO || SELF.FNC_GET_LOGGER_INFO();
        RETURN L_INFO;
    END;
-- MANIPULATAION METHODS
    MEMBER PROCEDURE PRC_UPDATE_TRANSACTION(
        PI_TRANSACTION_ID       VARCHAR2 DEFAULT NULL,
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        TRANSACTION_ID          := NVL(PI_TRANSACTION_ID, TRANSACTION_ID);
        TRANSACTION_CODE        := PI_TRANSACTION_CODE;
        APP_USER                := PI_APP_USER;
        UNIT_NAME               := PI_UNIT_NAME;
        UNIT_TYPE               := PI_UNIT_TYPE;
        DESCRIPTION             := PI_DESCRIPTION;
    END;
    MEMBER PROCEDURE PRC_INIT_LOGGER(
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL,
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION          VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        TRANSACTION_ID      := TYP_LOGGER.FNC_INIT_TRANSACTION_ID();
        SELF.PRC_UPDATE_ALL_TS_DIM();
        SELF.PRC_UPDATE_TRANSACTION(
            PI_TRANSACTION_CODE     => PI_TRANSACTION_CODE,
            PI_UNIT_NAME            => PI_UNIT_NAME,
            PI_APP_USER             => PI_APP_USER,
            PI_UNIT_TYPE            => PI_UNIT_TYPE,
            PI_DESCRIPTION          => PI_DESCRIPTION);
    END;

    MEMBER PROCEDURE PRC_UPDATE_LOGGER
    IS
    BEGIN
        SELF.PRC_UPDATE_UPDATED_TS_DIM();
    END;

END;
/