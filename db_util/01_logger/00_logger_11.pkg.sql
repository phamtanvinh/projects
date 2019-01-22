/* **********************************************************************************
** APP_LOGGER_UTIL
** **********************************************************************************/

create or replace package APP_LOGGER_UTIL
as
-- GLOBAL CONFIG
    g_app_config            APP_CONFIG;
    g_config                JSON_OBJECT_T;
    g_running_table         VARCHAR2(64);
    g_exception_table       VARCHAR2(64);
-- MANIPULATE CONFIG
    procedure refresh_config;
-- MANIPULATE TABLES
    procedure initialize;
end APP_LOGGER_UTIL;
/

create or replace package body APP_LOGGER_UTIL
as
-- MANIPULATE CONFIG
    procedure refresh_config
    is
    begin
        -- custome
        g_running_table             := 'ODS_LOGGER_RUNNING';
        g_exception_table           := 'ODS_LOGGER_EXCEPTION';

        app_logger_sql.g_config             := g_config;
        app_logger_sql.g_running_table      := g_running_table;
        app_logger_sql.g_exception_table    := g_exception_table;
    end;
-- MANIPULATE TABLES
    procedure initialize
    is
        l_sql       VARCHAR2(4000);
    begin
        refresh_config();
        dbms_output.put_line('Initialize ...');
        app_util.drop_table(g_running_table, true);
        app_util.drop_table(g_exception_table, true);
        l_sql       := app_logger_sql.get_create_logger_running_sql();
        execute immediate l_sql;
        --dbms_output.put_line(l_sql);
        l_sql       := app_logger_sql.get_create_logger_exception_sql();
        execute immediate l_sql;
        dbms_output.put_line('Done');
    end;
begin
    g_app_config        := new APP_CONFIG();
    g_config            := app_meta_data_util.g_logger_default;
    g_running_table     := g_config.get_string('running_table');
    g_exception_table   := g_config.get_string('exception_table');
end;
