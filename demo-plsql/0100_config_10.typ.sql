/* ******************************************************************
** TYP_CONFIG
** ******************************************************************/

BEGIN
    PKG_UTIL.PRC_DROP_TABLE('TAB_CONFIG');
END;
/

CREATE OR REPLACE TYPE TYP_CONFIG FORCE
AS OBJECT(
    CONFIG_ID           VARCHAR2(64),
    CONFIG_CODE         VARCHAR2(64), -- MKT, PUR
    CONFIG_NAME         VARCHAR2(512),
    CONFIG_VALUE        VARCHAR2(512),
    CONFIG_TYPE         VARCHAR2(64), -- LOGGING, STATE, OBJECT
    CONFIG_DESCRIPTION  VARCHAR2(4000),
    STATUS              VARCHAR2(64), -- ACTIVE, INACTIVE
    CREATED_TS          TIMESTAMP,
    UPDATED_TS          TIMESTAMP,
-- STATIC METHODS
    STATIC FUNCTION FNC_CREATE_CONFIG_ID RETURN VARCHAR2,
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO,
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_CONFIG(
        PI_CONFIG_CODE      VARCHAR2,
        PI_CONFIG_NAME      VARCHAR2,
        PI_CONFIG_VALUE     VARCHAR2,
        PI_CONFIG_TYPE      VARCHAR2
    ) RETURN SELF AS RESULT,
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_CONFIG_INFO RETURN VARCHAR2,
    MEMBER FUNCTION FNC_GET_INFO RETURN VARCHAR2,
    MEMBER PROCEDURE PRC_PRINT_INFO
-- MANIPULATAION METHODS

)NOT FINAL;
/

CREATE OR REPLACE TYPE BODY TYP_CONFIG
AS
-- STATIC METHODS
    STATIC FUNCTION FNC_CREATE_CONFIG_ID RETURN VARCHAR2
    IS
    BEGIN
        RETURN TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHHMISS')||ROUND(DBMS_RANDOM.VALUE(1, 9)*1000);
    END;

    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
    IS
    BEGIN
        PKG_META_DATA.PRC_PRINT_TYPE_INFO('TYP_CONFIG');
    END;
-- CONSTRUCTOR
    CONSTRUCTOR FUNCTION TYP_CONFIG(
        PI_CONFIG_CODE      VARCHAR2,
        PI_CONFIG_NAME      VARCHAR2,
        PI_CONFIG_VALUE     VARCHAR2,
        PI_CONFIG_TYPE      VARCHAR2
    ) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        CONFIG_ID       := TYP_CONFIG.FNC_CREATE_CONFIG_ID();
        CONFIG_CODE     := PI_CONFIG_CODE;
        CONFIG_NAME     := PI_CONFIG_NAME;
        CONFIG_VALUE    := PI_CONFIG_VALUE;
        CONFIG_TYPE     := PI_CONFIG_TYPE;
        STATUS          := 'ACTIVE';
        CREATED_TS      := CURRENT_TIMESTAMP;
        UPDATED_TS      := CURRENT_TIMESTAMP;
        RETURN;
    END;
-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_CONFIG_INFO 
    RETURN VARCHAR2
    IS
        L_INFO          VARCHAR2(4000);
        L_DICTIONARY    PKG_UTIL.DICTIONARY;
    BEGIN
        L_DICTIONARY('CONFIG_ID')            := CONFIG_ID;
        L_DICTIONARY('CONFIG_CODE')          := CONFIG_CODE;
        L_DICTIONARY('CONFIG_NAME')          := CONFIG_NAME;
        L_DICTIONARY('CONFIG_VALUE')         := CONFIG_VALUE;
        L_DICTIONARY('CONFIG_TYPE')          := CONFIG_TYPE;
        L_DICTIONARY('CONFIG_DESCRIPTION')   := CONFIG_DESCRIPTION;
        L_DICTIONARY('STATUS')               := STATUS;
        L_DICTIONARY('CREATED_TS')           := CREATED_TS;
        L_DICTIONARY('UPDATED_TS')           := UPDATED_TS;
        
        L_INFO := PKG_UTIL.FNC_GET_INFO(L_DICTIONARY);
        RETURN L_INFO;
    END;

    MEMBER FUNCTION FNC_GET_INFO 
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN SELF.FNC_GET_CONFIG_INFO();
    END;

    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
        L_INFO          VARCHAR2(4000);
    BEGIN
        L_INFO := SELF.FNC_GET_INFO();
        DBMS_OUTPUT.PUT_LINE(L_INFO);
    END;
-- MANIPULATAION METHODS

 
END;
/
