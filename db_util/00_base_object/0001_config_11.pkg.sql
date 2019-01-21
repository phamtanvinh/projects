create or replace package APP_CONFIG_UTIL
authid current_user
as
    g_config_default    JSON_OBJECT_T   := app_meta_data_util.g_config_default;
    g_app_config        APP_CONFIG      := new APP_CONFIG();
    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE'
    );    
    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE',
        po_app_config       out APP_CONFIG
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
                g_app_config.config_id,
                g_app_config.config_code,
                g_app_config.config_user,
                g_app_config.config_name,
                g_app_config.config_value.to_string,
                g_app_config.config_type,
                g_app_config.description,
                g_app_config.status,
                g_app_config.created_date,
                g_app_config.updated_date;
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
                g_app_config.config_id,
                g_app_config.config_code,
                g_app_config.config_user,
                g_app_config.config_name,
                l_config_value,
                g_app_config.config_type,
                g_app_config.description,
                g_app_config.status,
                g_app_config.created_date,
                g_app_config.updated_date 
            using pi_config_id, pi_config_code, pi_config_name, pi_status;
        g_app_config.config_value := JSON_OBJECT_T(l_config_value);
    end;
    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE',
        po_app_config       out APP_CONFIG
    )
    is
    begin
        get_config(
            pi_config_id        => pi_config_id,
            pi_config_code      => pi_config_code,
            pi_config_name      => pi_config_name,
            pi_status           => pi_status
        );
        po_app_config   := g_app_config;
    end;
end APP_CONFIG_UTIL;
/