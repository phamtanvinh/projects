/* ******************************************************************
** PKG_LOGGER_UTIL
** ******************************************************************/

CREATE OR REPLACE PACKAGE PKG_LOGGER_UTIL
AS
    G_LOGGER_CONFIG         PKG_UTIL.DICTIONARY;
    G_LOGGER_EXTEND         TYP_LOGGER_EXTEND;
    PROCEDURE PRC_UPDATE_CONFIG;
    PROCEDURE PRC_INSERT_LOGGER_RUNNING(PI_LOGGER TYP_LOGGER_EXTEND DEFAULT NULL);
    PROCEDURE PRC_INSERT_LOGGER_EXCEPTION(PI_LOGGER TYP_LOGGER_EXTEND DEFAULT NULL);
    PROCEDURE PRC_TRACK_RUNNING(
        PI_STEP_NAME           VARCHAR2 DEFAULT NULL,
        PI_STEP_DESCRIPTION    VARCHAR2 DEFAULT NULL);
    PROCEDURE PRC_TRACK_EXCEPTION(PI_MESSAGE VARCHAR2 DEFAULT NULL);

END PKG_LOGGER_UTIL;
/

CREATE OR REPLACE PACKAGE BODY PKG_LOGGER_UTIL
AS
    PROCEDURE PRC_UPDATE_CONFIG
    IS 
    BEGIN
        G_LOGGER_CONFIG := PKG_LOGGER_SQL.G_LOGGER_CONFIG;
    END;


    PROCEDURE PRC_INSERT_LOGGER_RUNNING(PI_LOGGER TYP_LOGGER_EXTEND DEFAULT NULL)
    IS
        L_LOGGER    TYP_LOGGER_EXTEND;
    BEGIN 
        L_LOGGER := NVL(PI_LOGGER, G_LOGGER_EXTEND);
        INSERT INTO TAB_LOGGER_RUNNING(TRANSACTION_ID, TRANSACTION_CODE, APP_USER, UNIT_NAME, UNIT_TYPE, DESCRIPTION, START_TS, START_UNIX_TS, START_DATE, START_DNUM, UPDATED_TS, UPDATED_UNIX_TS, UPDATED_DATE, UPDATED_DNUM, DURATION, STEP_ID, STEP_NAME, STEP_DESCRIPTION)
        VALUES(
            L_LOGGER.TRANSACTION_ID,
            L_LOGGER.TRANSACTION_CODE,
            L_LOGGER.APP_USER,
            L_LOGGER.UNIT_NAME,
            L_LOGGER.UNIT_TYPE,
            L_LOGGER.DESCRIPTION,
            L_LOGGER.START_TS,
            L_LOGGER.START_UNIX_TS,
            L_LOGGER.START_DATE,
            L_LOGGER.START_DNUM,
            L_LOGGER.UPDATED_TS,
            L_LOGGER.UPDATED_UNIX_TS,
            L_LOGGER.UPDATED_DATE,
            L_LOGGER.UPDATED_DNUM,
            L_LOGGER.DURATION,
            L_LOGGER.STEP_ID,
            L_LOGGER.STEP_NAME,
            L_LOGGER.STEP_DESCRIPTION
        );
    END;

    PROCEDURE PRC_INSERT_LOGGER_EXCEPTION(PI_LOGGER TYP_LOGGER_EXTEND DEFAULT NULL)
    IS
        L_LOGGER    TYP_LOGGER_EXTEND;
    BEGIN 
        L_LOGGER := NVL(PI_LOGGER, G_LOGGER_EXTEND);
        INSERT INTO TAB_LOGGER_EXCEPTION(APP_USER, DESCRIPTION, TRANSACTION_CODE, TRANSACTION_ID, UNIT_NAME, UNIT_TYPE, START_DATE, START_DNUM, START_TS, START_UNIX_TS, UPDATED_DATE, UPDATED_DNUM, UPDATED_TS, UPDATED_UNIX_TS, DURATION, STEP_DESCRIPTION, STEP_ID, STEP_NAME, ERROR_BACKTRACE, LOG_SQLCODE, LOG_SQLERRM, MESSAGE)
        VALUES(
            L_LOGGER.APP_USER,
            L_LOGGER.DESCRIPTION,
            L_LOGGER.TRANSACTION_CODE,
            L_LOGGER.TRANSACTION_ID,
            L_LOGGER.UNIT_NAME,
            L_LOGGER.UNIT_TYPE,
            L_LOGGER.START_DATE,
            L_LOGGER.START_DNUM,
            L_LOGGER.START_TS,
            L_LOGGER.START_UNIX_TS,
            L_LOGGER.UPDATED_DATE,
            L_LOGGER.UPDATED_DNUM,
            L_LOGGER.UPDATED_TS,
            L_LOGGER.UPDATED_UNIX_TS,
            L_LOGGER.DURATION,
            L_LOGGER.STEP_DESCRIPTION,
            L_LOGGER.STEP_ID,
            L_LOGGER.STEP_NAME,
            L_LOGGER.ERROR_BACKTRACE,
            L_LOGGER.LOG_SQLCODE,
            L_LOGGER.LOG_SQLERRM,
            L_LOGGER.MESSAGE
        );
    END;

    PROCEDURE PRC_TRACK_RUNNING(
        PI_STEP_NAME           VARCHAR2 DEFAULT NULL,
        PI_STEP_DESCRIPTION    VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        G_LOGGER_EXTEND.PRC_UPDATE_LOGGER_EXTEND(
            PI_STEP_NAME            => PI_STEP_NAME,
            PI_STEP_DESCRIPTION     => PI_STEP_DESCRIPTION
        );
        PRC_INSERT_LOGGER_RUNNING(G_LOGGER_EXTEND);
    END;

    PROCEDURE PRC_TRACK_EXCEPTION(PI_MESSAGE VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        G_LOGGER_EXTEND.PRC_INIT_EXCEPTION(PI_MESSAGE => PI_MESSAGE);
        PRC_INSERT_LOGGER_EXCEPTION(G_LOGGER_EXTEND);
    END;

BEGIN
    PRC_UPDATE_CONFIG();
END PKG_LOGGER_UTIL;
/