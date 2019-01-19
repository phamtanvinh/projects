/* ******************************************************************
** TYP_ALL_TS_DIM
** ******************************************************************/

CREATE OR REPLACE TYPE TYP_ALL_TS_DIM FORCE
UNDER TYP_TS_DIM(
    UPDATED_TS          TIMESTAMP,
    UPDATED_UNIX_TS     NUMBER,
    UPDATED_DATE        DATE,
    UPDATED_DNUM        NUMBER,
    DURATION            NUMBER,
-- STATIC METHODS
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_ALL_TS_DIM RETURN SELF AS RESULT,
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_UPDATED_TS_DIM_INFO RETURN VARCHAR2,
    MEMBER FUNCTION FNC_ALL_TS_DIM_INFO RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION FNC_GET_INFO RETURN VARCHAR2,
-- MANIPULATAION METHODS
    MEMBER PROCEDURE PRC_UPDATE_UPDATED_TS_DIM,
    MEMBER PROCEDURE PRC_UPDATE_ALL_TS_DIM,
    MEMBER PROCEDURE PRC_UPDATE_DURATION(PI_START_UNIX_TS NUMBER DEFAULT NULL, PI_UPDATED_UNIX_TS NUMBER DEFAULT NULL)
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY TYP_ALL_TS_DIM
AS
-- STATIC METHODS
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_ALL_TS_DIM 
    RETURN SELF AS RESULT
    IS
    BEGIN
        TYPE_NAME       := 'TYP_ALL_TS_DIM';
        SELF.PRC_UPDATE_ALL_TS_DIM();
        RETURN;
    END;
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_UPDATED_TS_DIM_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
        L_DICTIONARY    PKG_UTIL.DICTIONARY;
    BEGIN
        L_DICTIONARY('UPDATED_TS')      := UPDATED_TS;
        L_DICTIONARY('UPDATED_UNIX_TS') := UPDATED_UNIX_TS;
        L_DICTIONARY('UPDATED_DATE')    := UPDATED_DATE;
        L_DICTIONARY('UPDATED_DNUM')    := UPDATED_DNUM;
        L_INFO          := PKG_UTIL.FNC_GET_INFO(L_DICTIONARY);
        RETURN L_INFO;
    END;

    MEMBER FUNCTION FNC_ALL_TS_DIM_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
    BEGIN
        L_INFO          := L_INFO || SELF.FNC_GET_TS_DIM_INFO();
        L_INFO          := L_INFO || SELF.FNC_GET_UPDATED_TS_DIM_INFO();
        L_INFO          := L_INFO || PKG_UTIL.FNC_GET_STRING_FORMAT('DURATION', DURATION);
        RETURN L_INFO;
    END;

    OVERRIDING MEMBER FUNCTION FNC_GET_INFO RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
    BEGIN
        L_INFO          := PKG_UTIL.FNC_GET_STRING_FORMAT('TYPE_NAME', TYPE_NAME);
        L_INFO          := L_INFO || SELF.FNC_ALL_TS_DIM_INFO();
        RETURN L_INFO;
    END;
-- MANIPULATAION METHODS
    MEMBER PROCEDURE PRC_UPDATE_UPDATED_TS_DIM
    IS
    BEGIN
        SELF.PRC_UPDATE_DURATION();
        SELF.PRC_UPDATE_TS_DIM(UPDATED_TS, UPDATED_UNIX_TS, UPDATED_DATE, UPDATED_DNUM);
    END;

    MEMBER PROCEDURE PRC_UPDATE_ALL_TS_DIM
    IS
    BEGIN
        SELF.PRC_UPDATE_START_TS_DIM();
        SELF.PRC_UPDATE_UPDATED_TS_DIM();
    END;

    MEMBER PROCEDURE PRC_UPDATE_DURATION(PI_START_UNIX_TS NUMBER DEFAULT NULL, PI_UPDATED_UNIX_TS NUMBER DEFAULT NULL)
    IS
        L_UPDATED_UNIX_TS   NUMBER;
    BEGIN
        L_UPDATED_UNIX_TS   := NVL(PKG_UTIL.FNC_GET_UNIX_TS(CURRENT_TIMESTAMP), UPDATED_UNIX_TS);
        DURATION            := L_UPDATED_UNIX_TS - NVL(PI_START_UNIX_TS, START_UNIX_TS);
    END;
END;
/