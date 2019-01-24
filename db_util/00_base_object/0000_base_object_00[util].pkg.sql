/* **********************************************************************************
** APP_UTIL
** **********************************************************************************
**  Description: 
** **********************************************************************************/

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
-- feature: manipulate date and time
    function get_dnum(pi_ts TIMESTAMP default current_timestamp) return NUMBER;
    function get_tnum(pi_ts TIMESTAMP default current_timestamp) return NUMBER;
    function get_unix_ts(pi_ts TIMESTAMP default current_timestamp) return NUMBER;
-- feature: manipulate dictionary
    function get_dictionary(pi_json    JSON_OBJECT_T) return DICTIONARY;
-- feature: manipulate transaction
    function get_transaction_id return VARCHAR2;
-- feature: manipulate json
    procedure update_json(
        pio_json in out JSON_OBJECT_T,
        pi_json         JSON_OBJECT_T
    );    
    procedure update_json(
        pio_json in out JSON_OBJECT_T,
        pi_json         VARCHAR2
    );
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
            execute immediate 'DROP TABLE ' || pi_table_name || ' CASCADE CONSTRAINTS PURGE';
        end if;
          
    end;
-- feature: manipulate date and time
    function get_dnum(pi_ts TIMESTAMP default current_timestamp) return NUMBER
    is
    begin
        return to_number(to_char(pi_ts, 'YYYYMMDD'));
    end;
    
    function get_tnum(pi_ts TIMESTAMP default current_timestamp) return NUMBER
    is
    begin
        return to_number(to_char(pi_ts, 'HH24MISS'));
    end;
    
    function get_unix_ts(pi_ts TIMESTAMP default current_timestamp) return NUMBER
    is
    begin
        return round((cast(pi_ts AS DATE) - DATE '1970-01-01')*24*60*60);
    end;
-- feature: manipulate dictionary
    function get_dictionary(pi_json    JSON_OBJECT_T) return DICTIONARY
    is
        l_keys          JSON_KEY_LIST := pi_json.get_keys();
        l_dictionary    DICTIONARY;
    begin
        for i in 1..l_keys.count
        loop
            l_dictionary(l_keys(i)) := pi_json.get_string(l_keys(i));
        end loop;

        return l_dictionary;
    end;
-- feature: manipulate transaction
    function get_transaction_id return VARCHAR2
    is
    begin
        return dbms_transaction.local_transaction_id(true);
    end;
-- feature: manipulate json
    procedure update_json(
        pio_json in out JSON_OBJECT_T,
        pi_json         JSON_OBJECT_T
    )
    is
        l_keys      JSON_KEY_LIST := pi_json.get_keys();
        l_key       VARCHAR2(64);
    begin
        for i in 1..l_keys.count
        loop
            l_key   := l_keys(i);
            if pio_json.has(l_key)
            then
                pio_json.put(l_key, pi_json.get_string(l_key));
            end if;
        end loop;
    end;

    procedure update_json(
        pio_json in out JSON_OBJECT_T,
        pi_json         VARCHAR2
    )
    is
        l_json  JSON_OBJECT_T := JSON_OBJECT_T(pi_json);
    begin
        update_json(
            pio_json    => pio_json,
            pi_json     => l_json
        );
    end;
end APP_UTIL;
/