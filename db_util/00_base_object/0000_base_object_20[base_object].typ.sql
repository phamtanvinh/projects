/* **********************************************************************************
** APP_BASE_OBJECT
** **********************************************************************************
**  Description: this is abstractive object for custom type to inheriate
** **********************************************************************************/

create or replace type APP_BASE_OBJECT force
as object(
    "__name__"          VARCHAR2(64),
    "__config_code__"   VARCHAR2(64),
    "__attributes__"    PLJSON,
    "__ts__"            TIMESTAMP,
    description         VARCHAR2(1024),
    created_date        DATE,
    updated_date        DATE,
-- static
-- constructor
    constructor function APP_BASE_OBJECT return self as result,
-- initialize
    member procedure initialize(        
        pi_name             VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_description      VARCHAR2 default null
    ),
    member procedure get_attributes_info,
    member procedure print_attributes_info,
    member procedure print_attributes_info(pi_is_sorted BOOLEAN),
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
        self.initialize();
        update_all();
        return;
    end;
-- initialize
    member procedure get_attributes_info
    is
    begin
        "__attributes__" := new PLJSON();
        "__attributes__".put('__name__'         ,"__name__");
        "__attributes__".put('__config_code__'  ,"__config_code__");
        "__attributes__".put('__ts__'           ,"__ts__");
        "__attributes__".put('description'      ,description);
        "__attributes__".put('created_date'     ,created_date);
        "__attributes__".put('updated_date'     ,updated_date);
    end;

    member procedure initialize(
        pi_name             VARCHAR2 default null,
        pi_config_code      VARCHAR2 default null,
        pi_description      VARCHAR2 default null
    )
    is
    begin
        "__name__"          := nvl(pi_name          ,'APP_BASE_OBJECT');
        "__config_code__"   := nvl(pi_config_code   ,'APP_BASE_OBJECT');
        "__ts__"            := current_timestamp;
        description         := pi_description;
        created_date        := sysdate;
    end;

    member procedure print_attributes_info
    is
    begin
        get_attributes_info();
        app_util.print_string_format("__attributes__");
    end;

    member procedure print_attributes_info(pi_is_sorted BOOLEAN)
    is
        l_dictionary    app_util.DICTIONARY;
    begin
        get_attributes_info();
        l_dictionary := app_util.get_dictionary("__attributes__");
        app_util.print_string_format(l_dictionary);
    end;

-- manipulate

    member procedure update_all
    is
    begin
        updated_date        := sysdate;
    end;
end;
/