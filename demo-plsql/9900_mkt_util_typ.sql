CREATE OR REPLACE TYPE MKT_LOGGING 
AS OBJECT(
    LOGGER_RUN          LOGGING_RUNNING_TIME,
    LOGGER_EXCEPTION    LOGGING_EXCEPTION,
    CONSTRUCTOR FUNCTION MKT_LOGGING(
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT,
    MEMBER PROCEDURE PRC_PRINT_INFO
);
/

CREATE OR REPLACE TYPE BODY MKT_LOGGING
AS
    CONSTRUCTOR FUNCTION MKT_LOGGING(
        PI_APP_USER             VARCHAR2 DEFAULT NULL,
        PI_UNIT_NAME            VARCHAR2 DEFAULT NULL,
        PI_UNIT_TYPE            VARCHAR2 DEFAULT NULL,
        PI_TRANSACTION_CODE     VARCHAR2 DEFAULT NULL) 
    RETURN SELF AS RESULT
    IS
    BEGIN
        DB_UTIL.PRC_INIT_LOGGING(
            PIO_LOGGING_RUNNING_TIME => LOGGER_RUN, 
            PIO_LOGGING_EXCEPTION    => LOGGER_EXCEPTION,
            PI_APP_USER             => PI_APP_USER,
            PI_UNIT_NAME            => PI_UNIT_NAME,
            PI_UNIT_TYPE            => PI_UNIT_TYPE,
            PI_TRANSACTION_CODE     => PI_TRANSACTION_CODE);
        RETURN;
    END;

    MEMBER PROCEDURE PRC_PRINT_INFO
    IS
    BEGIN
        LOGGER_RUN.PRC_PRINT_INFO();
        LOGGER_EXCEPTION.PRC_PRINT_INFO();
    END;
END;
/

