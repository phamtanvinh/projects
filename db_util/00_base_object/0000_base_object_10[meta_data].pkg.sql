create or replace package APP_META_DATA_UTIL
as
-- global
    g_prefix                JSON_OBJECT_T := NEW JSON_OBJECT_T();
    g_suffix                JSON_OBJECT_T := NEW JSON_OBJECT_T();
    g_config_default        JSON_OBJECT_T := NEW JSON_OBJECT_T();
    function get_object_name(
        pi_object_name      VARCHAR2,
        pi_prefix           VARCHAR2 default null,
        pi_suffix           VARCHAR2 default null
    ) return VARCHAR2;

    function get_table_name(
        pi_table_name       VARCHAR2,
        pi_prefix           VARCHAR2 default null,
        pi_suffix           VARCHAR2 default null
    ) return VARCHAR2;
end APP_META_DATA_UTIL;
/

create or replace package body APP_META_DATA_UTIL
as
    function get_object_name(
        pi_object_name      VARCHAR2,
        pi_prefix           VARCHAR2 default null,
        pi_suffix           VARCHAR2 default null
    ) return VARCHAR2
    is
        l_object_name   VARCHAR2(64);
    begin
        l_object_name   := nvl(pi_prefix, g_prefix.get_string('prefix')) || '_' || pi_object_name;
        if pi_suffix is not null
        then
            l_object_name := l_object_name || '_' || pi_suffix; 
        end if;

        return l_object_name;
    end;

    function get_table_name(
        pi_table_name       VARCHAR2,
        pi_prefix           VARCHAR2 default null,
        pi_suffix           VARCHAR2 default null
    ) return VARCHAR2
    is
        l_table_name    VARCHAR2(64);
    begin
        l_table_name    := get_object_name(
                pi_object_name  => pi_table_name,
                pi_prefix       => nvl(pi_prefix, g_prefix.get_string('prefix')),
                pi_suffix       => nvl(pi_suffix, g_suffix.get_string('table'))
            );

        return l_table_name; 
    end;
begin
    g_prefix.put('prefix'       ,'app');
    g_suffix.put('table'        ,'tab');
    g_suffix.put('type'         ,'typ');
    g_suffix.put('package'      ,'pkg');
    g_config_default.put('table_name'       , get_table_name(pi_table_name => 'config'));
end APP_META_DATA_UTIL;
/