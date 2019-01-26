/* **********************************************************************************
** APP_LOGGER_UTIL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

create or replace package APP_LOGGER_CUSTOM
as
    g_config        PLJSON;
-- SETTING CONFIG
    procedure reset_config;
end APP_LOGGER_CUSTOM;
/

create or replace package body APP_LOGGER_CUSTOM
as
    procedure reset_config
    is
    begin
        g_config        := new PLJSON();
        g_config.put('running_table'    ,'ODS_LOGGER_RUNNING');
        g_config.put('exception_table'  ,'ODS_LOGGER_EXCEPTION');      
    end;
begin
    reset_config();
end APP_LOGGER_CUSTOM;
/