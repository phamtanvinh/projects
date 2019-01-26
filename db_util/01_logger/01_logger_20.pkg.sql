/* **********************************************************************************
** APP_LOGGER_UTIL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

create or replace package APP_LOGGER_UTIL
as
-- GLOBAL CONFIG
    g_config                PLJSON;
    g_app_config            APP_CONFIG;
    g_app_logger            APP_LOGGER;
-- PRIVATE CONFIG
    "__config__"            PLJSON;
-- MANIPULATE CONFIG
    -- default config
    procedure reset_config;
    procedure get_private_config;
    procedure set_global_config(
        pi_package_name     VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null
    );
    -- [__config__] < [private] < [custom]
    procedure refresh_config;
-- MANIPULATE TABLES
    procedure initialize(pi_is_forced BOOLEAN default false);
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
    procedure reset_config
    is
    begin
        g_app_config        := new APP_CONFIG();
        g_config            := new PLJSON();
        "__config__"        := new PLJSON();
        g_config.put('running_table'    ,app_meta_data_util.get_table_name(pi_table_name => 'logger_running'));
        g_config.put('exception_table'  ,app_meta_data_util.get_table_name(pi_table_name => 'logger_exception'));     
        -- mode control by default
        g_config.put('is_overrided_config', true);
        g_config.put('is_loaded_custom_config', true);
        g_config.put('config_id',       '');
        g_config.put('config_code',     'APP_LOGGER');
        g_config.put('config_name',     'APP_LOGGER');
        g_config.put('config_status',   'ACTIVE');
    end;

    procedure get_private_config
    is
    begin
        app_config_util.get_config(        
            pi_config_id        => g_config.get('config_id').get_string,
            pi_config_code      => g_config.get('config_code').get_string,
            pi_config_name      => g_config.get('config_name').get_string,
            pi_status           => g_config.get('config_status').get_string,
            po_app_config       => g_app_config
        );
        "__config__"    := g_app_config.config_value;
    end;

    procedure set_global_config(
        pi_package_name     VARCHAR2    default null,
        pi_config_name      VARCHAR2    default null
    )
    is
        l_package_name      VARCHAR2(64)    := nvl(pi_package_name, 'APP_LOGGER_CUSTOM');
        l_config_name       VARCHAR2(64)    := nvl(pi_config_name,  'g_config');
        l_config            VARCHAR2(128)   := l_package_name || '.' || l_config_name;
        l_sql               VARCHAR2(4000);
    begin
        if g_config.get('is_loaded_custom_config').get_bool
        then
            l_sql := '
                begin
                    app_util.update_json(APP_LOGGER_UTIL.g_config, '|| l_config ||');
                end;';
            --dbms_output.put_line(l_config);
            --dbms_output.put_line(l_sql);
            execute immediate l_sql;
        end if;
    end;

    procedure refresh_config
    is
    begin
        -- load [custom]
        if g_config.get('is_overrided_config').get_bool
        then
            set_global_config();
        end if;
        -- load [private]
        -- load [__config__]
        -- setup config
        app_util.update_json(
            pio_json    => app_logger_sql.g_config, 
            pi_json     => g_config);
    end;
-- MANIPULATE TABLES
    procedure initialize(pi_is_forced BOOLEAN default false)
    is
        l_sql       VARCHAR2(4000);
    begin
        refresh_config();
        dbms_output.put_line('Initialize ...');
        if pi_is_forced
        then 
            app_util.drop_table(g_config.get('running_table').get_string, true);
            app_util.drop_table(g_config.get('exception_table').get_string, true);
        end if;

        l_sql       := app_logger_sql.get_create_logger_running_sql();
        if pi_is_forced
        then 
            execute immediate l_sql;
        else
            dbms_output.put_line(l_sql);
        end if;

        l_sql       := app_logger_sql.get_create_logger_exception_sql();
        if pi_is_forced
        then 
            execute immediate l_sql;
        else
            dbms_output.put_line(l_sql);
        end if;
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
-- SETUP BY DEFAULT
    reset_config();
end;
/