create or replace package APP_CONFIG_UTIL
authid current_user
as
-- GLOBAL CONFIG
    g_app_config            APP_CONFIG;
    g_config                JSON_OBJECT_T;
    g_table_name            VARCHAR2(64);
-- GLOBAL ATTRIBUTES
    g_config_id             NUMBER;
    g_config_code           VARCHAR2(64);
    g_config_name           VARCHAR2(64);
    g_config_user           VARCHAR2(64);
    g_config_value          VARCHAR2(4000);
    g_config_type           VARCHAR2(64);
    g_description           VARCHAR2(1024);
    g_status                VARCHAR2(16);
    g_created_date          DATE;
    g_updated_date          DATE;
-- MANIPULATE CONFIG
    procedure refresh_config;
-- MANIPULATE ATTRIBUTES
    procedure set_config(pi_app_config  APP_CONFIG default null);
    procedure update_app_config;
-- MANIPULATE TABLE
    procedure initialize;
    procedure insert_config;
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
end APP_CONFIG_UTIL;
/

create or replace package body APP_CONFIG_UTIL
as 
-- MANIPULATE CONFIG
    procedure refresh_config
    is
    begin
        app_config_sql.g_config     := g_config;
    end;
-- MANIPULATE ATTRIBUTES
    procedure set_config(pi_app_config  APP_CONFIG default null)
    is
    begin
        g_app_config            := nvl(pi_app_config, g_app_config);
        g_config_id			    := g_app_config.config_id;
        g_config_code		 	:= g_app_config.config_code;
        g_config_name			:= g_app_config.config_name;
        g_config_user			:= g_app_config.config_user;
        g_config_value			:= g_app_config.config_value.to_string;
        g_config_type			:= g_app_config.config_type;
        g_description			:= g_app_config.description;
        g_status			    := g_app_config.status;
        g_created_date			:= g_app_config.created_date;
        g_updated_date			:= g_app_config.updated_date;
    end;

    procedure update_app_config
    is
    begin
        g_app_config                        := new APP_CONFIG();
        g_app_config.config_id              := g_config_id;
        g_app_config.config_code			:= g_config_code;
        g_app_config.config_user			:= g_config_user;
        g_app_config.config_name			:= g_config_name;
        g_app_config.config_value           := JSON_OBJECT_T(g_config_value);
        g_app_config.config_type			:= g_config_type;
        g_app_config.description			:= g_description;
        g_app_config.status			        := g_status;
        g_app_config.created_date			:= g_created_date;
        g_app_config.updated_date           := g_updated_date;
    end;

-- MANIPULATE TABLE
    procedure initialize
    is
        l_sql               VARCHAR2(4000);
    begin
        refresh_config();
        dbms_output.put_line('Initialize ...');
        dbms_output.put_line('Drop table '||g_table_name ||' ...');
        app_util.drop_table(g_table_name, true);
        dbms_output.put_line('Create table '||g_table_name ||' ...');
        l_sql   := app_config_sql.get_config_table_sql();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql;
        dbms_output.put_line('Done.');
    end;

    procedure insert_config
    is
        l_sql               VARCHAR2(4000);
    begin
        refresh_config();
        l_sql   := app_config_sql.get_config_insert_sql();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql
            using
                g_config_id,
                g_config_code,
                g_config_user,
                g_config_name,
                g_config_value,
                g_config_type,
                g_description,
                g_status,
                g_created_date,
                g_updated_date;
    end;

    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE'
    )
    is
        l_sql               VARCHAR2(4000);
    begin
        refresh_config();
        l_sql   := app_config_sql.get_config_sql();
        --dbms_output.put_line(l_sql);
        execute immediate l_sql 
            into 
                g_config_id,
                g_config_code,
                g_config_user,
                g_config_name,
                g_config_value,
                g_config_type,
                g_description,
                g_status,
                g_created_date,
                g_updated_date 
            using 
                pi_config_id, 
                pi_config_code, 
                pi_config_name, 
                pi_status;
        update_app_config();
    end;

    procedure get_config(
        pi_config_id        VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null,
        pi_status           VARCHAR2 default 'ACTIVE',
        po_app_config out   APP_CONFIG
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
begin
    g_app_config        := new APP_CONFIG();
    g_config            := app_meta_data_util.g_config_default ;
    g_table_name        := g_config.get_string('table_name');
end APP_CONFIG_UTIL;
/