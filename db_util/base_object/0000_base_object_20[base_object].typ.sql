create or replace type APP_BASE_OBJECT force
as object(
    "__name__"          VARCHAR2(64),
    "__ts__"            TIMESTAMP,
    "__attributes__"    JSON_OBJECT_T,
    description         VARCHAR2(1024),
    created_date        DATE,
    updated_date        DATE,
-- static
-- constructor
    constructor function APP_BASE_OBJECT return self as result,
-- initialize
    member procedure initialize(        
        pi_name             VARCHAR2 default null,
        pi_description      VARCHAR2 default null
    ),
    member procedure get_attributes_info,
    member procedure print_attributes_info,
-- manipulate
    member procedure update_all
) not final;
/

create or replace type body APP_BASE_OBJECT
as
-- static
-- constructor
    constructor function APP_BASE_OBJECT return self as result
    is
    begin
        self.initialize(pi_name => 'APP_BASE_OBJECT');
        return;
    end;
-- initialize
    member procedure get_attributes_info
    is
    begin
        "__attributes__".put('__name__'     ,"__name__");
        "__attributes__".put('__ts__'       ,"__ts__");
        "__attributes__".put('description'  ,description);
        "__attributes__".put('created_date' ,created_date);
        "__attributes__".put('updated_date' ,updated_date);
    end;

    member procedure initialize(
        pi_name             VARCHAR2 default null,
        pi_description      VARCHAR2 default null
    )
    is
    begin
        "__name__"          := pi_name;
        "__attributes__"    := new JSON_OBJECT_T();
        description         := pi_description;
        created_date        := sysdate;
        update_all();
    end;

    member procedure print_attributes_info
    is
        l_string        VARCHAR2(4000);
    begin
        get_attributes_info();
        l_string    := APP_UTIL.get_string_format(pi_jo => "__attributes__");
        dbms_output.put_line(l_string);
    end;

-- manipulate

    member procedure update_all
    is
    begin
        "__ts__"            := current_timestamp;
        updated_date        := sysdate;
    end;
end;
/