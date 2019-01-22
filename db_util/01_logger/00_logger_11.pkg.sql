/* **********************************************************************************
** APP_LOGGER_UTIL
** **********************************************************************************/

create or replace package APP_LOGGER_UTIL
as
-- GLOBAL CONFIG
    g_config                JSON_OBJECT_T;
    g_app_config            APP_CONFIG;
    g_app_logger            APP_LOGGER;
-- PRIVATE CONFIG
    "__config__"            JSON_OBJECT_T;
-- MANIPULATE CONFIG
    procedure refresh_config;
-- MANIPULATE TABLES
    procedure initialize;
    procedure set_logger(pi_app_logger APP_LOGGER);
    procedure insert_logger_running(pi_app_logger APP_LOGGER);
    procedure insert_logger_running(
        pi_log_step_name        VARCHAR2,
        pi_log_step_description VARCHAR2
    );
    procedure insert_logger_running(
        pi_is_repeated      BOOLEAN default false
    );
    procedure insert_logger_exception;
end APP_LOGGER_UTIL;
/

create or replace package body APP_LOGGER_UTIL
as
-- MANIPULATE CONFIG
    procedure refresh_config
    is
    begin
        -- custom
        g_config.put('running_table'    ,'ODS_LOGGER_RUNNING');
        g_config.put('exception_table'  ,'ODS_LOGGER_EXCEPTION');
        app_logger_sql.g_config         := g_config;
    end;
-- MANIPULATE TABLES
    procedure initialize
    is
        l_sql       VARCHAR2(4000);
    begin
        refresh_config();
        dbms_output.put_line('Initialize ...');
        app_util.drop_table(g_config.get_string('running_table'), true);
        app_util.drop_table(g_config.get_string('exception_table'), true);
        l_sql       := app_logger_sql.get_create_logger_running_sql();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql;
        l_sql       := app_logger_sql.get_create_logger_exception_sql();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql;
        dbms_output.put_line('Done');
    end;
    procedure set_logger(pi_app_logger APP_LOGGER)
    is
    begin
        g_app_logger    := pi_app_logger;
    end;
    -- this is anchor for updating logger (last call)
    procedure insert_logger_running(pi_app_logger APP_LOGGER)
    is
        l_sql   VARCHAR2(4000);
    begin
        refresh_config();
        g_app_logger := nvl(pi_app_logger, g_app_logger);
        l_sql   := app_logger_sql.get_insert_logger_running_sql();
        -- dbms_output.put_line(l_sql);
        execute immediate l_sql
            using 
                g_app_logger.transaction_id,
                g_app_logger.transaction_code,
                g_app_logger.app_user,
                g_app_logger.unit_name,
                g_app_logger.unit_type,
                g_app_logger.log_step_description,
                g_app_logger.log_step_id,
                g_app_logger.log_step_name,
                g_app_logger.created_date,
                g_app_logger.created_unix_ts,
                g_app_logger.updated_date,
                g_app_logger.updated_unix_ts,
                g_app_logger.duration;
    end;

    -- this will be update step and datetime and duration
    procedure insert_logger_running(
        pi_log_step_name        VARCHAR2,
        pi_log_step_description VARCHAR2)
    is
    begin
        g_app_logger.update_step(
            pi_log_step_name        => pi_log_step_name,
            pi_log_step_description => pi_log_step_description
        );
        insert_logger_running(g_app_logger);
    end;

    -- repeat step
    procedure insert_logger_running(
        pi_is_repeated      BOOLEAN default false
    )
    is
    begin
        if not(pi_is_repeated) 
        then
            g_app_logger.log_step_name          := null;
            g_app_logger.log_step_description   := null;
        end if;
        insert_logger_running(
            pi_log_step_name        => g_app_logger.log_step_name,
            pi_log_step_description => g_app_logger.log_step_description
        );
    end;

    procedure insert_logger_exception
    is
        l_sql   VARCHAR2(4000);
    begin
        refresh_config();
        g_app_logger.initialize_exception();
        l_sql   := app_logger_sql.get_insert_logger_exception_sql();
        -- dbms_output.put_line(l_sql);
        execute immediate l_sql
            using 
                g_app_logger.transaction_id,
                g_app_logger.transaction_code,
                g_app_logger.app_user,
                g_app_logger.unit_name,
                g_app_logger.unit_type,
                g_app_logger.log_step_description,
                g_app_logger.log_step_id,
                g_app_logger.log_step_name,
                g_app_logger.created_date,
                g_app_logger.created_unix_ts,
                g_app_logger.updated_date,
                g_app_logger.updated_unix_ts,
                g_app_logger.duration,
                g_app_logger.error_sqlcode,
                g_app_logger.error_sqlerrm,
                g_app_logger.error_backtrace;
    end;

begin
    g_app_config        := new APP_CONFIG();
    g_config            := app_meta_data_util.g_logger_default;
end;
