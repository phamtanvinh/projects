/* **********************************************************************************
** APP_CONFIG_SQL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

create or replace package APP_CONFIG_SQL
as
-- GLOBAL CONFIG
    g_config                JSON_OBJECT_T;
    g_table_name            VARCHAR2(64);
-- PRIVATE CONFIG
    "__config__"            JSON_OBJECT_T;
-- GLOBAL ATTRIBUTES
-- UPDATE CONFIG
    procedure update_config;
-- GET SQL
    function get_config_table_sql return VARCHAR2;
    function get_config_insert_sql return VARCHAR2;
    function get_config_sql return VARCHAR2;
end APP_CONFIG_SQL;
/

create or replace package body APP_CONFIG_SQL
as
-- UPDATE CONFIG
    procedure update_config
    is
    begin
        g_table_name            := g_config.get_string('table_name');
    end;
-- GET SQL
    function get_config_table_sql return VARCHAR2
    is
        l_sql           VARCHAR2(4000);
    begin
        update_config();
        l_sql := '
            CREATE TABLE '|| g_table_name ||'(
                "CONFIG_ID"     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY, 
                "CONFIG_CODE"   VARCHAR2(64), 
                "CONFIG_USER"   VARCHAR2(64), 
                "CONFIG_NAME"   VARCHAR2(64), 
                "CONFIG_VALUE"  VARCHAR2(4000)
                    CONSTRAINT IS_JSON_VALUE CHECK("CONFIG_VALUE" IS JSON), 
                "CONFIG_TYPE"   VARCHAR2(64), 
                "DESCRIPTION"   VARCHAR2(1024), 
                "STATUS"        VARCHAR2(16),
                "CREATED_DATE"  DATE, 
                "UPDATED_DATE"  DATE
            )';
        return l_sql;
    end;

    function get_config_insert_sql return VARCHAR2
    is
        l_sql           VARCHAR2(4000);
    begin
        update_config();
        l_sql   := '
        BEGIN
            INSERT INTO '|| g_table_name ||'(
                CONFIG_ID,
                CONFIG_CODE,
                CONFIG_USER,
                CONFIG_NAME,
                CONFIG_VALUE,
                CONFIG_TYPE,
                DESCRIPTION,
                STATUS,
                CREATED_DATE,
                UPDATED_DATE)
            VALUES(
                :CONFIG_ID,
                :CONFIG_CODE,
                :CONFIG_USER,
                :CONFIG_NAME,
                :CONFIG_VALUE,
                :CONFIG_TYPE,
                :DESCRIPTION,
                :STATUS,
                :CREATED_DATE,
                :UPDATED_DATE);
            COMMIT;
        END;';
        return l_sql;
    end;
    function get_config_sql return VARCHAR2
    is
        l_sql           VARCHAR2(4000);
    begin
        update_config();
        l_sql := '
            SELECT 
                CONFIG_ID,
                CONFIG_CODE,
                CONFIG_USER,
                CONFIG_NAME,
                CONFIG_VALUE,
                CONFIG_TYPE,
                DESCRIPTION,
                STATUS,
                CREATED_DATE,
                UPDATED_DATE
            FROM '||g_table_name||'
            WHERE 1 = 1
                AND (CONFIG_ID  = :pi_config_id OR CONFIG_CODE = :pi_config_code)
                AND CONFIG_NAME = :pi_config_name
                AND STATUS      = :pi_status
                AND ROWNUM      = 1
            ';
        return l_sql;
    end;
begin
-- SETUP BY DEFAULT
    g_config    := new JSON_OBJECT_T();
    g_config.put('table_name', app_meta_data_util.get_table_name(pi_table_name => 'config'));
end APP_CONFIG_SQL;