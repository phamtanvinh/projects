/* ******************************************************************
**
** AUTHOR               : Vinhpt
** CREATED DATE         : 09-JAN-19
** LAST UPDATED DATE    : 09-JAN-19
** 
** ******************************************************************/

/* ******************************************************************
** *******************************************************************
**
** LOGGER
**
** ******************************************************************
** ******************************************************************/

CREATE OR REPLACE TYPE LOGGER
AS OBJECT(
    APP_USER            VARCHAR2(4000),
    UNIT_NAME           VARCHAR2(4000),
    UNIT_TYPE           VARCHAR2(4000),
    DESCRIPTION         VARCHAR2(4000), 
    CREATED_NUMBER      NUMBER,
    PREVIOUS_NUMBER     NUMBER,
    UPDATED_NUMBER      NUMBER,
    DURATION            NUMBER,
    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER,
    CONSTRUCTOR FUNCTION LOGGER RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION LOGGER(
        PI_APP_USER     VARCHAR2,
        PI_UNIT_TYPE    VARCHAR2,
        PI_UNIT_NAME    VARCHAR2,
        PI_DESCRIPTION  VARCHAR2) RETURN SELF AS RESULT,
    MEMBER PROCEDURE PRC_PRINT_INFO,
    MEMBER PROCEDURE PRC_UPDATE(
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL),
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
)
NOT FINAL;
/

CREATE OR REPLACE TYPE BODY LOGGER
AS
--
    MEMBER PROCEDURE PRC_UPDATE(
        PI_DESCRIPTION  VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        DESCRIPTION        := PI_DESCRIPTION;
        PREVIOUS_NUMBER    := NVL(UPDATED_NUMBER, CREATED_NUMBER);
        UPDATED_NUMBER     := FNC_GET_START_NUMBER();
        DURATION           := UPDATED_NUMBER - PREVIOUS_NUMBER;
    END;

--
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

    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER
    IS
    BEGIN
        RETURN ROUND((CAST(CURRENT_TIMESTAMP AS DATE) - DATE '1970-01-01')*24*60*60);
    END;

    CONSTRUCTOR FUNCTION LOGGER(
        PI_APP_USER     VARCHAR2,
        PI_UNIT_TYPE    VARCHAR2,
        PI_UNIT_NAME    VARCHAR2,
        PI_DESCRIPTION  VARCHAR2
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        APP_USER            := PI_APP_USER;
        UNIT_NAME           := PI_UNIT_TYPE;
        UNIT_TYPE           := PI_UNIT_NAME;
        DESCRIPTION         := PI_DESCRIPTION;
        CREATED_NUMBER      := FNC_GET_START_NUMBER();
        RETURN;
    END;

    CONSTRUCTOR FUNCTION LOGGER RETURN SELF AS RESULT
    IS
    BEGIN
        APP_USER            := 'UNDEFINED';
        UNIT_NAME           := 'UNDEFINED';
        UNIT_TYPE           := 'LOGGING';
        DESCRIPTION         := 'INITIALIZE LOGGER';
        CREATED_NUMBER      := FNC_GET_START_NUMBER();
        RETURN;
    END;

    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(''
        ||'APP_USER             :'||APP_USER           ||CHR(10)
        ||'UNIT_NAME            :'||UNIT_NAME          ||CHR(10)
        ||'UNIT_TYPE            :'||UNIT_TYPE          ||CHR(10)
        ||'DESCRIPTION          :'||DESCRIPTION        ||CHR(10)
        ||'CREATED_NUMBER       :'||CREATED_NUMBER     ||CHR(10)
        ||'PREVIOUS_NUMBER      :'||PREVIOUS_NUMBER    ||CHR(10)
        ||'UPDATED_NUMBER       :'||UPDATED_NUMBER     ||CHR(10)
        ||'DURATION             :'||DURATION           ||CHR(10));
    END;
END;
/


/* ******************************************************************
** ******************************************************************
**
** LOGGING_EXECEPTION
**
** ******************************************************************
** ******************************************************************/

CREATE OR REPLACE TYPE LOGGING_EXECEPTION
AS OBJECT(
    APP_USER            VARCHAR2(4000),
    MESSAGE             VARCHAR2(4000),
    UNIT_NAME           VARCHAR2(4000),
    UNIT_TYPE           VARCHAR2(4000),
    LOG_SQLCODE         VARCHAR2(4000),
    LOG_SQLERRM         VARCHAR2(4000),
    LOG_PLSQL_LINE      VARCHAR2(4000),
    ERROR_BACKTRACE     VARCHAR2(4000),
    CREATED_NUMBER      NUMBER,
    CONSTRUCTOR FUNCTION LOGGING_EXECEPTION RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION LOGGING_EXECEPTION(
        SELF IN OUT NOCOPY LOGGING_EXECEPTION,
        PI_APP_USER         VARCHAR2,
        PI_MESSAGE          VARCHAR2,
        PI_UNIT_NAME        VARCHAR2,
        PI_UNIT_TYPE        VARCHAR2,
        PI_LOG_SQLCODE      VARCHAR2,
        PI_LOG_SQLERRM      VARCHAR2,
        PI_PLSQL_LINE       VARCHAR2) RETURN SELF AS RESULT,
    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER,
    MEMBER FUNCTION FNC_GET_BACKTRACE(
        SELF IN OUT NOCOPY LOGGING_EXECEPTION) RETURN VARCHAR2,
    MEMBER PROCEDURE PRC_INIT_ERROR(
        PI_MESSAGE          VARCHAR2 DEFAULT 'ERROR',
        PI_PLSQL_LINE       VARCHAR2 DEFAULT 'UNDEFINED'),
    MEMBER PROCEDURE PRC_GET_BACKTRACE,
    MEMBER PROCEDURE PRC_PRINT_INFO,
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
);
/

CREATE OR REPLACE TYPE BODY LOGGING_EXECEPTION
AS
--
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

--
    MEMBER FUNCTION FNC_GET_START_NUMBER 
    RETURN NUMBER
    IS
    BEGIN
        RETURN ROUND((CAST(CURRENT_TIMESTAMP AS DATE) - DATE '1970-01-01')*24*60*60);
    END;
--
    CONSTRUCTOR FUNCTION LOGGING_EXECEPTION 
    RETURN SELF AS RESULT
    IS 
    BEGIN
        APP_USER            := 'UNDEFINED';
        MESSAGE             := 'INITIALIZE HANDLER';
        UNIT_NAME           := 'LOGGING_EXECEPTION';
        UNIT_TYPE           := 'LOGGING_EXECEPTION';
        LOG_SQLCODE         := 'UNDEFINED';
        LOG_SQLERRM         := 'UNDEFINED';
        LOG_PLSQL_LINE      := 'UNDEFINED';
        CREATED_NUMBER      := FNC_GET_START_NUMBER();
        RETURN;
    END;

--
    CONSTRUCTOR FUNCTION LOGGING_EXECEPTION(
        SELF IN OUT NOCOPY LOGGING_EXECEPTION,
        PI_APP_USER         VARCHAR2,
        PI_MESSAGE          VARCHAR2,
        PI_UNIT_NAME        VARCHAR2,
        PI_UNIT_TYPE        VARCHAR2,
        PI_LOG_SQLCODE      VARCHAR2,
        PI_LOG_SQLERRM      VARCHAR2,
        PI_PLSQL_LINE       VARCHAR2) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        APP_USER           := PI_APP_USER;
        MESSAGE            := PI_MESSAGE;
        UNIT_NAME          := PI_UNIT_NAME;
        UNIT_TYPE          := PI_UNIT_TYPE;
        LOG_SQLCODE        := PI_LOG_SQLCODE;
        LOG_SQLERRM        := PI_LOG_SQLERRM;
        LOG_PLSQL_LINE     := PI_PLSQL_LINE;
        CREATED_NUMBER     := FNC_GET_START_NUMBER();
        RETURN;
    END;

--
    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(''
            ||'APP_USER         :'||APP_USER   ||CHR(10)
            ||'MESSAGE          :'||MESSAGE    ||CHR(10)
            ||'UNIT_NAME        :'||UNIT_NAME  ||CHR(10)
            ||'UNIT_TYPE        :'||UNIT_TYPE  ||CHR(10)
            ||'LOG_SQLCODE      :'||LOG_SQLCODE    ||CHR(10)
            ||'LOG_SQLERRM      :'||LOG_SQLERRM    ||CHR(10)
            ||'LOG_PLSQL_LINE   :'||LOG_PLSQL_LINE ||CHR(10)
            ||'ERROR_BACKTRACE  :'||ERROR_BACKTRACE||CHR(10)
            ||'CREATED_NUMBER   :'||CREATED_NUMBER);
    END;
    
--
    MEMBER PROCEDURE PRC_INIT_ERROR(
        PI_MESSAGE          VARCHAR2 DEFAULT 'ERROR',
        PI_PLSQL_LINE       VARCHAR2 DEFAULT 'UNDEFINED')
    IS
    BEGIN
        MESSAGE             := PI_MESSAGE;
        LOG_SQLCODE         := SQLCODE;
        LOG_SQLERRM         := SQLERRM(SQLCODE);
        LOG_PLSQL_LINE      := PI_PLSQL_LINE;
        CREATED_NUMBER      := FNC_GET_START_NUMBER();
    END;
--
    MEMBER PROCEDURE PRC_GET_BACKTRACE
    IS
    BEGIN
        ERROR_BACKTRACE   := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    END;

    MEMBER FUNCTION FNC_GET_BACKTRACE(
        SELF IN OUT NOCOPY LOGGING_EXECEPTION) 
    RETURN VARCHAR2
    IS
    BEGIN
        PRC_GET_BACKTRACE();
        RETURN ERROR_BACKTRACE;
    END;

--  
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
AS OBJECT(
    TRANSACTION_ID      VARCHAR2(4000),
    TRANSACTION_CODE    VARCHAR2(4000),
    APP_USER            VARCHAR2(4000),
    UNIT_NAME           VARCHAR2(4000),
    UNIT_TYPE           VARCHAR2(4000),
    STEP_NAME           VARCHAR2(4000),
    START_NUMBER        NUMBER,
    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME(
        SELF IN OUT NOCOPY LOGGING_RUNNING_TIME,
        PI_TRANSACTION_ID       VARCHAR2,
        PI_TRANSACTION_CODE     VARCHAR2,
        PI_APP_USER             VARCHAR2,
        PI_UNIT_NAME            VARCHAR2,
        PI_UNIT_TYPE            VARCHAR2,
        PI_STEP_NAME            VARCHAR2) RETURN SELF AS RESULT,
    MEMBER FUNCTION FNC_GET_START_NUMBER RETURN NUMBER,
    MEMBER PROCEDURE PRC_PRINT_INFO,
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
);
/

CREATE OR REPLACE TYPE BODY LOGGING_RUNNING_TIME 
IS
--
    STATIC PROCEDURE PRC_PRINT_TYPE_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('
** ******************************************************************
** DESCRIPTION
** ******************************************************************
** PROGRAMING UNIT: '|| $$PLSQL_UNIT ||'
** PROGRAMING TYPE: '|| 'OBJECT TYPE' ||'
** ******************************************************************
** SUMMARY: THIS TYPE IS USING FOR LOGGING START TIME OF RUNNING QUERY
** METHODS:
** FEATURES:
** ******************************************************************');
    END;

--
    MEMBER FUNCTION FNC_GET_START_NUMBER
    RETURN NUMBER
    IS
    BEGIN
        RETURN ROUND((CAST(CURRENT_TIMESTAMP AS DATE) - DATE '1970-01-01')*24*60*60);
    END;
    
-- INIT OBJECT
    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME 
    RETURN SELF AS RESULT
    IS
    BEGIN
        TRANSACTION_ID      := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);
        TRANSACTION_CODE    := 'UNDEFINED';
        APP_USER            := 'UNDEFINED';
        UNIT_NAME           := 'LOGGING_RUNNING_TIME';
        UNIT_TYPE           := 'LOGGING_RUNNING_TIME';
        STEP_NAME           := '000';
        START_NUMBER        := FNC_GET_START_NUMBER();
        RETURN;
    END;

    CONSTRUCTOR FUNCTION LOGGING_RUNNING_TIME(
        SELF IN OUT NOCOPY LOGGING_RUNNING_TIME,
        PI_TRANSACTION_ID       VARCHAR2,
        PI_TRANSACTION_CODE     VARCHAR2,
        PI_APP_USER             VARCHAR2,
        PI_UNIT_NAME            VARCHAR2,
        PI_UNIT_TYPE            VARCHAR2,
        PI_STEP_NAME            VARCHAR2) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        TRANSACTION_ID      := PI_TRANSACTION_ID;
        TRANSACTION_CODE    := PI_TRANSACTION_CODE;
        APP_USER            := PI_APP_USER;
        UNIT_NAME           := PI_UNIT_NAME;
        UNIT_TYPE           := PI_UNIT_TYPE;
        STEP_NAME           := PI_STEP_NAME;
        START_NUMBER        := FNC_GET_START_NUMBER();
        RETURN;
    END;
    
-- PRINT OBJECT INFORMATION
    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(''
        ||'TRANSACTION_ID       :'||TRANSACTION_ID     ||CHR(10)
        ||'TRANSACTION_CODE     :'||TRANSACTION_CODE   ||CHR(10)
        ||'APP_USER             :'||APP_USER           ||CHR(10)
        ||'UNIT_NAME            :'||UNIT_NAME          ||CHR(10)
        ||'UNIT_TYPE            :'||UNIT_TYPE          ||CHR(10)
        ||'STEP_NAME            :'||STEP_NAME          ||CHR(10)
        ||'START_NUMBER         :'||START_NUMBER       ||CHR(10));
    END;
END;
/