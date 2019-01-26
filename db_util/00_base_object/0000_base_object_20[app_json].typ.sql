/* **********************************************************************************
** APP_JSON
** **********************************************************************************
**  Description: this is abstractive object for custom type to inheriate
** **********************************************************************************/

create or replace type APP_JSON
as OBJECT(
    "__config__"        VARCHAR2(4000),
    data                VARCHAR2(4000),
-- static
-- constructor
    constructor function APP_JSON(pi_data VARCHAR2 default null) return self as result,
-- initialize
    member procedure initialize(pi_data VARCHAR2 default null),
    member procedure print_attributes_info,
-- manipulate
    member function get(pi_key  VARCHAR2) return VARCHAR2
);
/

create or replace type body APP_JSON
as
-- static
-- constructor
    constructor function APP_JSON(pi_data VARCHAR2 default null) return self as result
    is
    begin
        initialize(pi_data      => pi_data);
        return;
    end;
-- initialize
    member procedure initialize(pi_data VARCHAR2 default null)
    is
    begin
        if pi_data is json 
        then
            data    := pi_data;
        else
            data    := '{}';
        end if;
    end;

    member procedure print_attributes_info
    is
    begin
        dbms_output.put_line(data);
    end;
-- manipulate
    member function get(pi_key  VARCHAR2) return VARCHAR2
    is
        l_value     VARCHAR2(4000);
    begin
        if json_exists(data, '$.' || pi_key false on error)
        then
            l_value := json_value(data, '$.'|| pi_key);
        end if;
        return l_value;
    end;
end;
/