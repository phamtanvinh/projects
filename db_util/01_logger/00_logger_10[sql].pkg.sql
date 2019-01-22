create or replace package APP_LOGGER_SQL
as
-- GLOBAL CONFIG
    g_app_logger            APP_LOGGER;
    g_config                JSON_OBJECT_T;
-- PRIVATE CONFIG
    "__config__"            JSON_OBJECT_T;
-- UPDATE CONFIG
-- GET SQL
    function get_create_logger_running_sql return VARCHAR2;
    function get_create_logger_exception_sql return VARCHAR2;
    function get_insert_logger_running_sql return VARCHAR2;
    function get_insert_logger_exception_sql return VARCHAR2;
end APP_LOGGER_SQL;
/

create or replace package body APP_LOGGER_SQL
as
-- UPDATE CONFIG
-- GET SQL
    function get_create_logger_running_sql return VARCHAR2
    is
        l_sql   VARCHAR2(4000);
    begin
        l_sql := '
            CREATE TABLE '|| g_config.get_string('running_table') ||'(
                TRANSACTION_ID        VARCHAR2(64),
                TRANSACTION_CODE      VARCHAR2(64),
                APP_USER              VARCHAR2(64),
                UNIT_NAME             VARCHAR2(64),
                UNIT_TYPE             VARCHAR2(64),
                LOG_STEP_DESCRIPTION  VARCHAR2(1024),
                LOG_STEP_ID           NUMBER,
                LOG_STEP_NAME         VARCHAR2(64),
                CREATED_DATE          DATE,
                CREATED_UNIX_TS       NUMBER,
                UPDATED_DATE          DATE,
                UPDATED_UNIX_TS       NUMBER,
                DURATION              NUMBER
            )';
        return l_sql;
    end;

    function get_create_logger_exception_sql return VARCHAR2
    is
        l_sql   VARCHAR2(4000);
    begin
        l_sql := '
            CREATE TABLE '|| g_config.get_string('exception_table') ||'(
                TRANSACTION_ID        VARCHAR2(64),
                TRANSACTION_CODE      VARCHAR2(64),
                APP_USER              VARCHAR2(64),
                UNIT_NAME             VARCHAR2(64),
                UNIT_TYPE             VARCHAR2(64),
                LOG_STEP_DESCRIPTION  VARCHAR2(1024),
                LOG_STEP_ID           NUMBER,
                LOG_STEP_NAME         VARCHAR2(64),
                CREATED_DATE          DATE,
                CREATED_UNIX_TS       NUMBER,
                UPDATED_DATE          DATE,
                UPDATED_UNIX_TS       NUMBER,
                DURATION              NUMBER,
                ERROR_SQLCODE         VARCHAR2(64),
                ERROR_SQLERRM         VARCHAR2(1024),
                ERROR_BACKTRACE       VARCHAR2(1024)
            )';
        return l_sql;
    end;
    function get_insert_logger_running_sql return VARCHAR2
    is
        l_sql   VARCHAR2(4000);
    begin
        l_sql :='
            INSERT INTO '|| g_config.get_string('running_table') ||'(
                    TRANSACTION_ID,
                    TRANSACTION_CODE,
                    APP_USER,
                    UNIT_NAME,
                    UNIT_TYPE,
                    LOG_STEP_DESCRIPTION,
                    LOG_STEP_ID,
                    LOG_STEP_NAME,
                    CREATED_DATE,
                    CREATED_UNIX_TS,
                    UPDATED_DATE,
                    UPDATED_UNIX_TS,
                    DURATION)
            VALUES(
                    :TRANSACTION_ID,
                    :TRANSACTION_CODE,
                    :APP_USER,
                    :UNIT_NAME,
                    :UNIT_TYPE,
                    :LOG_STEP_DESCRIPTION,
                    :LOG_STEP_ID,
                    :LOG_STEP_NAME,
                    :CREATED_DATE,
                    :CREATED_UNIX_TS,
                    :UPDATED_DATE,
                    :UPDATED_UNIX_TS,
                    :DURATION)
        ';
        return l_sql;
    end;
    function get_insert_logger_exception_sql return VARCHAR2
    is
        l_sql   VARCHAR2(4000);
    begin
        l_sql := '
            INSERT INTO '|| g_config.get_string('exception_table') ||'(
                    TRANSACTION_ID,
                    TRANSACTION_CODE,
                    APP_USER,
                    UNIT_NAME,
                    UNIT_TYPE,
                    LOG_STEP_DESCRIPTION,
                    LOG_STEP_ID,
                    LOG_STEP_NAME,
                    CREATED_DATE,
                    CREATED_UNIX_TS,
                    UPDATED_DATE,
                    UPDATED_UNIX_TS,
                    DURATION,
                    ERROR_SQLCODE,
                    ERROR_SQLERRM,
                    ERROR_BACKTRACE)
            VALUES(
                    :TRANSACTION_ID,
                    :TRANSACTION_CODE,
                    :APP_USER,
                    :UNIT_NAME,
                    :UNIT_TYPE,
                    :LOG_STEP_DESCRIPTION,
                    :LOG_STEP_ID,
                    :LOG_STEP_NAME,
                    :CREATED_DATE,
                    :CREATED_UNIX_TS,
                    :UPDATED_DATE,
                    :UPDATED_UNIX_TS,
                    :DURATION,
                    :ERROR_SQLCODE,
                    :ERROR_SQLERRM,
                    :ERROR_BACKTRACE)
        ';
        return l_sql;
    end;
begin
-- SETUP BY DEFAULT
    g_config                := app_meta_data_util.g_logger_default;
end APP_LOGGER_SQL;
/