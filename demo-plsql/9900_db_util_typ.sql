/* ******************************************************************
**
** AUTHOR               : Vinhpt
** CREATED DATE         : 09-JAN-19
** LAST UPDATED DATE    : 11-JAN-19
** 
** ******************************************************************/

/* ******************************************************************
** *******************************************************************
**
** LOGGER
**
** ******************************************************************
** ******************************************************************/
/*
DROP TYPE LOGGER FORCE;
DROP TYPE LOGGING_EXCEPTION FORCE;
DROP TYPE LOGGING_RUNNING_TIME FORCE;
*/
CREATE OR REPLACE TYPE LOGGER
AS OBJECT(
    APP_USER            VARCHAR2(4000),
    TRANSACTION_ID      VARCHAR2(4000),
    TRANSACTION_CODE    VARCHAR2(4000),
    UNIT_NAME           VARCHAR2(4000),
    UNIT_TYPE           VARCHAR2(4000),
    DESCRIPTION         VARCHAR2(4000), 
    CREATED_NUMBER      NUMBER,
    PREVIOUS_NUMBER     NUMBER,
    UPDATED_NUMBER      NUMBER,
    DURATION            NUMBER,
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO,
    CONSTRUCTOR FUNCTION LOGGER RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION LOGGER(
        PI_APP_USER             VARCHAR2,
        PI_TRANSACTION_CODE     VARCHAR2,
        PI_UNIT_NAME            VARCHAR2,
        PI_UNIT_TYPE            VARCHAR2,
        PI_DESCRIPTION          VARCHAR2) RETURN SELF AS RESULT,
    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER,
    MEMBER FUNCTION FNC_INIT_TRANSACTION_ID RETURN VARCHAR2,
    MEMBER FUNCTION FNC_GET_LOGGER_INFO RETURN VARCHAR2,
    MEMBER PROCEDURE PRC_PRINT_INFO,
    MEMBER PROCEDURE PRC_UPDATE_TIME_NUMBER,
    MEMBER PROCEDURE PRC_INIT_FROM_LOGGER(
        PI_LOGGER       LOGGER,
        PI_UNIT_NAME    VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE    VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL),
    MEMBER PROCEDURE PRC_UPDATE(
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL)
)NOT FINAL;
/

CREATE OR REPLACE TYPE BODY LOGGER
AS
-- STATIC METHODS
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('
** ******************************************************************
** DESCRIPTION
** ******************************************************************
** PROGRAMING UNIT: '|| 'LOGGER' ||'
** PROGRAMING TYPE: '|| 'OBJECT TYPE' ||'
** ******************************************************************
** SUMMARY: THIS TYPE IS USING FOR TRACKING EXCEPTION LOG WHEN CATCHING ERROR
** METHODS:
** FEATURES:
** ******************************************************************');
    END;

-- INITIALIZE METHODS
    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER
    IS
    BEGIN
        RETURN ROUND((CAST(CURRENT_TIMESTAMP AS DATE) - DATE '1970-01-01')*24*60*60);
    END;

    MEMBER FUNCTION FNC_INIT_TRANSACTION_ID RETURN VARCHAR2
    IS
    BEGIN
        RETURN DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);
    END;

    CONSTRUCTOR FUNCTION LOGGER RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();   
        TRANSACTION_ID      := SELF.FNC_INIT_TRANSACTION_ID;
        UNIT_NAME           := 'UNDEFINED';
        UNIT_TYPE           := 'LOGGING';
        DESCRIPTION         := 'INITIALIZE LOGGER';
        RETURN;
    END;

    CONSTRUCTOR FUNCTION LOGGER(
        PI_APP_USER             VARCHAR2,
        PI_TRANSACTION_CODE     VARCHAR2,
        PI_UNIT_NAME            VARCHAR2,
        PI_UNIT_TYPE            VARCHAR2,
        PI_DESCRIPTION          VARCHAR2) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();   
        APP_USER            := PI_APP_USER;
        TRANSACTION_ID      := SELF.FNC_INIT_TRANSACTION_ID;
        TRANSACTION_CODE    := PI_TRANSACTION_CODE;
        UNIT_NAME           := PI_UNIT_NAME;
        UNIT_TYPE           := PI_UNIT_TYPE;
        DESCRIPTION         := PI_DESCRIPTION;
        RETURN; 
    END;

-- PRINT INFO
    MEMBER FUNCTION FNC_GET_LOGGER_INFO RETURN VARCHAR2
    IS 
    BEGIN
        RETURN ''
            ||'APP_USER             :'||APP_USER           ||CHR(10)
            ||'TRANSACTION_ID       :'||TRANSACTION_ID     ||CHR(10)
            ||'TRANSACTION_CODE     :'||TRANSACTION_CODE   ||CHR(10)
            ||'UNIT_NAME            :'||UNIT_NAME          ||CHR(10)
            ||'UNIT_TYPE            :'||UNIT_TYPE          ||CHR(10)
            ||'DESCRIPTION          :'||DESCRIPTION        ||CHR(10)
            ||'CREATED_NUMBER       :'||CREATED_NUMBER     ||CHR(10)
            ||'PREVIOUS_NUMBER      :'||PREVIOUS_NUMBER    ||CHR(10)
            ||'UPDATED_NUMBER       :'||UPDATED_NUMBER     ||CHR(10)
            ||'DURATION             :'||DURATION           ||CHR(10);
    END;

    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(SELF.FNC_GET_LOGGER_INFO());
    END;

-- MODIFY INFO
    MEMBER PROCEDURE PRC_UPDATE_TIME_NUMBER
    IS
    BEGIN
        CREATED_NUMBER     := NVL(CREATED_NUMBER, SELF.FNC_GET_START_NUMBER);
        PREVIOUS_NUMBER    := NVL(UPDATED_NUMBER, SELF.FNC_GET_START_NUMBER);
        UPDATED_NUMBER     := SELF.FNC_GET_START_NUMBER();
        DURATION           := UPDATED_NUMBER - PREVIOUS_NUMBER;
    END;

    MEMBER PROCEDURE PRC_UPDATE(
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();
        DESCRIPTION        := PI_DESCRIPTION;
    END;

    MEMBER PROCEDURE PRC_INIT_FROM_LOGGER(
        PI_LOGGER       LOGGER,
        PI_UNIT_NAME    VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE    VARCHAR2 DEFAULT NULL,
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();
        APP_USER            := PI_LOGGER.APP_USER;
        TRANSACTION_ID      := PI_LOGGER.TRANSACTION_ID;
        TRANSACTION_CODE    := PI_LOGGER.TRANSACTION_CODE;
        UNIT_NAME           := NVL(PI_UNIT_NAME     ,PI_LOGGER.UNIT_NAME);
        UNIT_TYPE           := NVL(PI_UNIT_TYPE     ,PI_LOGGER.UNIT_TYPE);
        DESCRIPTION         := NVL(PI_DESCRIPTION   ,PI_LOGGER.DESCRIPTION);
    END;
END;
/


/* ******************************************************************
** ******************************************************************
**
** LOGGING_EXCEPTION
**
** ******************************************************************
** ******************************************************************/

CREATE OR REPLACE TYPE LOGGING_EXCEPTION
UNDER LOGGER(
    MESSAGE             VARCHAR2(4000),
    LOG_SQLCODE         VARCHAR2(4000),
    LOG_SQLERRM         VARCHAR2(4000),
    LOG_PLSQL_LINE      VARCHAR2(4000),
    ERROR_BACKTRACE     VARCHAR2(4000),
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO,
    CONSTRUCTOR FUNCTION LOGGING_EXCEPTION RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE PRC_PRINT_INFO,
    MEMBER FUNCTION FNC_GET_BACKTRACE(
        SELF IN OUT NOCOPY LOGGING_EXCEPTION) RETURN VARCHAR2,
    MEMBER PROCEDURE PRC_GET_BACKTRACE,
    MEMBER PROCEDURE PRC_INIT_ERROR(
        PI_MESSAGE          VARCHAR2 DEFAULT NULL,
        PI_LOG_PLSQL_LINE   VARCHAR2 DEFAULT NULL)
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY LOGGING_EXCEPTION
AS
-- STATIC METHODS
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('
** ******************************************************************
** DESCRIPTION
** ******************************************************************
** PROGRAMING UNIT: '|| 'LOGGING_EXCEPTION' ||'
** PROGRAMING TYPE: '|| 'OBJECT TYPE' ||'
** ******************************************************************
** SUMMARY: THIS TYPE IS USING FOR TRACKING EXCEPTION LOG WHEN CATCHING ERROR
** METHODS:
** FEATURES:
** ******************************************************************');
    END;

-- INITIALIZE METHODS
    CONSTRUCTOR FUNCTION LOGGING_EXCEPTION 
    RETURN SELF AS RESULT
    IS 
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();   
        TRANSACTION_ID      := SELF.FNC_INIT_TRANSACTION_ID;
        UNIT_NAME           := 'LOGGING_EXCEPTION';
        UNIT_TYPE           := 'LOGGING_EXCEPTION';
        MESSAGE             := 'INITIALIZE HANDLER';
        RETURN;
    END;

-- PRINT INFO
    OVERRIDING MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(SELF.FNC_GET_LOGGER_INFO()
            ||'MESSAGE              :'||MESSAGE            ||CHR(10)
            ||'LOG_SQLCODE          :'||LOG_SQLCODE        ||CHR(10)
            ||'LOG_SQLERRM          :'||LOG_SQLERRM        ||CHR(10)
            ||'LOG_PLSQL_LINE       :'||LOG_PLSQL_LINE     ||CHR(10)
            ||'ERROR_BACKTRACE      :'||ERROR_BACKTRACE    ||CHR(10));
    END;
    
-- MODIFY INFO
    MEMBER PROCEDURE PRC_GET_BACKTRACE
    IS
    BEGIN
        ERROR_BACKTRACE   := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    END;

    MEMBER FUNCTION FNC_GET_BACKTRACE(
        SELF IN OUT NOCOPY LOGGING_EXCEPTION) 
    RETURN VARCHAR2
    IS
    BEGIN
        PRC_GET_BACKTRACE();
        RETURN ERROR_BACKTRACE;
    END;

    MEMBER PROCEDURE PRC_INIT_ERROR(
        PI_MESSAGE          VARCHAR2 DEFAULT NULL,
        PI_LOG_PLSQL_LINE   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();
        SELF.PRC_GET_BACKTRACE();
        MESSAGE             := PI_MESSAGE;
        LOG_SQLCODE         := SQLCODE;
        LOG_SQLERRM         := SQLERRM(SQLCODE);
        LOG_PLSQL_LINE      := PI_LOG_PLSQL_LINE;
    END;
END;
/


/* ******************************************************************
** ******************************************************************
**
** LOGGING_RUNNING_TIME
**
** ******************************************************************
** ******************************************************************/

CREATE OR REPLACE TYPE LOGGING_RUNNING_TIME
UNDER LOGGER(
    PREVIOUS_STEP_NAME  VARCHAR2(4000),
    STEP_NAME           VARCHAR2(4000),
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO,
    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE PRC_PRINT_INFO,
    MEMBER PROCEDURE PRC_UPDATE_STEP(
        PI_STEP_NAME        VARCHAR2 DEFAULT '000',
        PI_DESCRIPTION      VARCHAR2 DEFAULT NULL)
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY LOGGING_RUNNING_TIME 
IS
-- STATIC METHODS
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('
** ******************************************************************
** DESCRIPTION
** ******************************************************************
** PROGRAMING UNIT: '|| 'LOGGING_RUNNING_TIME' ||'
** PROGRAMING TYPE: '|| 'OBJECT TYPE' ||'
** ******************************************************************
** SUMMARY: THIS TYPE IS USING FOR LOGGING START TIME OF RUNNING QUERY
** METHODS:
** FEATURES:
** ******************************************************************');
    END;
    
-- INITIALIZE METHODS
    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME 
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();   
        UNIT_NAME           := 'LOGGING_RUNNING_TIME';
        UNIT_TYPE           := 'LOGGING_RUNNING_TIME';
        DESCRIPTION         := 'INITIALIZE LOGGING_RUNNING_TIME';
        STEP_NAME           := '000';
        RETURN;
    END;
    
-- PRINT INFO
    OVERRIDING MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(SELF.FNC_GET_LOGGER_INFO()
            ||'PREVIOUS_STEP_NAME   :'||PREVIOUS_STEP_NAME ||CHR(10)
            ||'STEP_NAME            :'||STEP_NAME          ||CHR(10));
    END;

    MEMBER PROCEDURE PRC_UPDATE_STEP(
        PI_STEP_NAME        VARCHAR2 DEFAULT '000',
        PI_DESCRIPTION      VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        SELF.PRC_UPDATE_TIME_NUMBER();
        PREVIOUS_STEP_NAME  := STEP_NAME;
        STEP_NAME           := PI_STEP_NAME;
        DESCRIPTION         := PI_DESCRIPTION;
    END;

END;
/










