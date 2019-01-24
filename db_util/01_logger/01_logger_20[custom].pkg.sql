/* **********************************************************************************
** APP_LOGGER_UTIL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

create or replace package APP_LOGGER_CUSTOM
as
    g_config        JSON_OBJECT_T;
-- SETTING CONFIG
    procedure reset_config;
end APP_LOGGER_CUSTOM;
/

create or replace package body APP_LOGGER_CUSTOM
as
    procedure reset_config
    is
    begin
        g_config        := new JSON_OBJECT_T();
        g_config.put('running_table'    ,'ODS_LOGGER_RUNNING');
        g_config.put('exception_table'  ,'ODS_LOGGER_EXCEPTION');      
    end;
begin
    reset_config();
end APP_LOGGER_CUSTOM;
/