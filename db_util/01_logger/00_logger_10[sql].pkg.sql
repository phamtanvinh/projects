/* **********************************************************************************
** APP_LOGGER_SQL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

create or replace package APP_LOGGER_SQL
as
-- GLOBAL CONFIG
    g_app_logger            APP_LOGGER;
    g_config                PLJSON;
-- PRIVATE CONFIG
    "__config__"            PLJSON;
-- MANIPULATE CONFIG
    procedure reset_config;
-- GET SQL
    function get_create_logger_running_sql return VARCHAR2;
    function get_create_logger_exception_sql return VARCHAR2;
    function get_insert_logger_running_sql return VARCHAR2;
    function get_insert_logger_exception_sql return VARCHAR2;
end APP_LOGGER_SQL;
/

create or replace package body APP_LOGGER_SQL
as
-- MANIPULATE CONFIG
    procedure reset_config
    is
    begin
        g_config        := new PLJSON();
        g_app_logger    := new APP_LOGGER;
        g_config.put('running_table'    ,app_meta_data_util.get_table_name(pi_table_name => 'logger_running'));
        g_config.put('exception_table'  ,app_meta_data_util.get_table_name(pi_table_name => 'logger_exception'));     
    end;

-- GET SQL
    function get_create_logger_running_sql return VARCHAR2
    is
        l_sql   VARCHAR2(4000);
    begin
        l_sql := '
            CREATE TABLE '|| g_config.get('running_table').get_string ||'(
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
            CREATE TABLE '|| g_config.get('exception_table').get_string ||'(
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
            INSERT INTO '|| g_config.get('running_table').get_string ||'(
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
            INSERT INTO '|| g_config.get('exception_table').get_string ||'(
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
    reset_config();
end APP_LOGGER_SQL;
/