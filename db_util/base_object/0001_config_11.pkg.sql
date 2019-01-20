create or replace package APP_CONFIG_UTIL
as
    g_config_default    JSON_OBJECT_T   := app_meta_data_util.g_config_default;
    g_app_config        APP_CONFIG      := new APP_CONFIG();
    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE'
    );
    procedure initialize;
    procedure insert_config;
end APP_CONFIG_UTIL;
/

create or replace package body APP_CONFIG_UTIL
as 
    procedure initialize
    is
        l_table_name        VARCHAR2(64)    := g_config_default.get_string('table_name');
        l_sql               VARCHAR2(4000);
    begin
        dbms_output.put_line('Initialize ...');
        dbms_output.put_line('Drop table '||l_table_name ||' ...');
        app_util.drop_table(l_table_name, true);
        dbms_output.put_line('Create table '||l_table_name ||' ...');
        l_sql   := app_config_sql.get_config_table_sql(l_table_name);
        --dbms_output.put_line(l_sql);
        execute immediate l_sql;
        dbms_output.put_line('Done.');
    end;
    procedure insert_config
    is
        l_table_name        VARCHAR2(64)    := g_config_default.get_string('table_name');
        l_sql               VARCHAR2(4000);
    begin
        l_sql   := app_config_sql.get_config_insert_sql(l_table_name);
        g_app_config.print_attributes_info();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql
            using
                APP_CONFIG_UTIL.g_app_config.CONFIG_ID,
                APP_CONFIG_UTIL.g_app_config.CONFIG_CODE,
                APP_CONFIG_UTIL.g_app_config.CONFIG_USER,
                APP_CONFIG_UTIL.g_app_config.CONFIG_NAME,
                APP_CONFIG_UTIL.g_app_config.CONFIG_VALUE.to_string,
                APP_CONFIG_UTIL.g_app_config.CONFIG_TYPE,
                APP_CONFIG_UTIL.g_app_config.DESCRIPTION,
                APP_CONFIG_UTIL.g_app_config.STATUS,
                APP_CONFIG_UTIL.g_app_config.CREATED_DATE,
                APP_CONFIG_UTIL.g_app_config.UPDATED_DATE;
    end;
    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE'
    )
    is
        l_table_name        VARCHAR2(64)    := g_config_default.get_string('table_name');
        l_sql               VARCHAR2(4000);
        l_config_value      VARCHAR2(4000);
    begin
        g_app_config    := new APP_CONFIG();
        l_sql           := app_config_sql.get_config_sql(l_table_name);
        execute immediate l_sql 
            into 
                    APP_CONFIG_UTIL.g_app_config.CONFIG_ID,
                    APP_CONFIG_UTIL.g_app_config.CONFIG_CODE,
                    APP_CONFIG_UTIL.g_app_config.CONFIG_USER,
                    APP_CONFIG_UTIL.g_app_config.CONFIG_NAME,
                    l_config_value,
                    APP_CONFIG_UTIL.g_app_config.CONFIG_TYPE,
                    APP_CONFIG_UTIL.g_app_config.DESCRIPTION,
                    APP_CONFIG_UTIL.g_app_config.STATUS,
                    APP_CONFIG_UTIL.g_app_config.CREATED_DATE,
                    APP_CONFIG_UTIL.g_app_config.UPDATED_DATE 
            using pi_config_id, pi_config_code, pi_config_name, pi_status;
        APP_CONFIG_UTIL.g_app_config.CONFIG_VALUE := JSON_OBJECT_T(l_config_value);
    end;
end APP_CONFIG_UTIL;
/