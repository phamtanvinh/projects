create or replace package APP_UTIL
as
-- global attributes
    g_rpad_size         NUMBER := 30;
-- global types
    type TUPLE is table of VARCHAR2(4000);
    type DICTIONARY is table of VARCHAR2(4000) index by VARCHAR2(64);
-- feature: manipulate string
    function get_string_format(
        pi_key          VARCHAR2, 
        pi_value        VARCHAR2, 
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2;
    
    function get_string_format(
        pi_dictionary   DICTIONARY,
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2;
    function get_string_format(
        pi_jo           JSON_OBJECT_T,
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2;
    procedure print_string_format(
        pi_key          VARCHAR2, 
        pi_value        VARCHAR2, 
        pi_rpad_size    NUMBER default g_rpad_size);

    procedure print_string_format(
        pi_dictionary   DICTIONARY,
        pi_rpad_size    NUMBER default g_rpad_size);
    
    procedure print_string_format(
        pi_jo           JSON_OBJECT_T,
        pi_rpad_size    NUMBER default g_rpad_size );
-- feature: manipulate table
    function exist_table(pi_table_name VARCHAR2) return BOOLEAN;
    procedure drop_table(pi_table_name VARCHAR2, pi_is_forced BOOLEAN default false);
end APP_UTIL;
/

create or replace package body APP_UTIL
as
-- feature: manipulate string
    function get_string_format(
        pi_key          VARCHAR2, 
        pi_value        VARCHAR2, 
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2
    is
        l_string            VARCHAR2(4000);
    begin
        return  rpad(pi_key, pi_rpad_size, chr(32))|| ':' || pi_value || chr(10);
    end;

    function get_string_format(
        pi_dictionary   DICTIONARY,
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2
    is
        l_key           VARCHAR2(64) := pi_dictionary.first;
        l_value         VARCHAR2(4000);
        l_string        VARCHAR2(4000);
    begin
        while l_key is not null
        loop
            l_value     := pi_dictionary(l_key);
            l_string    := l_string || get_string_format(l_key, l_value, pi_rpad_size);
            l_key       := pi_dictionary.next(l_key);
        end loop;
        return l_string;
    end;

    function get_string_format(
        pi_jo           JSON_OBJECT_T,
        pi_rpad_size    NUMBER default g_rpad_size) return VARCHAR2
    is
        l_keys          JSON_KEY_LIST := pi_jo.get_keys;
        l_key           VARCHAR2(64);
        l_value         VARCHAR2(4000);
        l_string        VARCHAR2(4000);
    begin
        for i in 1..l_keys.count
        loop
            l_key       := l_keys(i);
            l_value     := pi_jo.get_string(l_key);
            l_string    := l_string || get_string_format(pi_key => l_key, pi_value => l_value, pi_rpad_size => pi_rpad_size);
        end loop;
        return l_string;
    end;

    procedure print_string_format(
        pi_key          VARCHAR2, 
        pi_value        VARCHAR2, 
        pi_rpad_size    NUMBER default g_rpad_size)
    is
        l_string        VARCHAR2(4000);
    begin
        l_string        := get_string_format(pi_key, pi_value, pi_rpad_size);
        dbms_output.put_line(l_string);
    end;

    procedure print_string_format(
        pi_dictionary   DICTIONARY,
        pi_rpad_size    NUMBER default g_rpad_size)
    is
        l_string        VARCHAR2(4000);
    begin
        l_string        := get_string_format(pi_dictionary, pi_rpad_size);
        dbms_output.put_line(l_string);
    end;

    procedure print_string_format(
        pi_jo           JSON_OBJECT_T,
        pi_rpad_size    NUMBER default g_rpad_size )
    is
        l_string        VARCHAR2(4000);
    begin
        l_string        := get_string_format(pi_jo => pi_jo, pi_rpad_size => pi_rpad_size);
        dbms_output.put_line(l_string);
    end;
-- feature: manipulate table
    function exist_table(pi_table_name VARCHAR2) return BOOLEAN
    is
        l_is_true   BOOLEAN := false;
        l_counter   NUMBER;
    begin
        select count(*)
        into l_counter 
        from tab 
        where tname = upper(pi_table_name);

        if l_counter > 0
        then
            l_is_true := true;
        end if;

        return l_is_true;
    end;
    procedure drop_table(pi_table_name VARCHAR2, pi_is_forced BOOLEAN default false)
    is
    begin
        if exist_table(pi_table_name) and pi_is_forced
        then
            execute immediate 'drop table ' || pi_table_name || ' purge';
        end if;
          
    end;

end APP_UTIL;
/