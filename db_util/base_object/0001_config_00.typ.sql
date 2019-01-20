create or replace type APP_CONFIG force
under APP_BASE_OBJECT(
    config_id       NUMBER,
    config_code     VARCHAR2(64),
    config_user     VARCHAR2(64),
    config_name     VARCHAR2(64),
    config_value    JSON_OBJECT_T,
    config_type     VARCHAR2(64),
    status          VARCHAR2(16),
-- static
-- constructor
    constructor function APP_CONFIG return self as result,
-- initialize
    member procedure set_config(
        pi_config_id        VARCHAR2        default null,
        pi_config_code      VARCHAR2        default null,
        pi_config_user      VARCHAR2        default null,
        pi_config_name      VARCHAR2        default null,
        pi_config_value     JSON_OBJECT_T   default new JSON_OBJECT_T(),
        pi_config_type      VARCHAR2        default null,
        pi_status           VARCHAR2        default null


    ),
    member procedure print_config_value,
    overriding member procedure get_attributes_info,
    member procedure initialize(        
        pi_name             VARCHAR2        default null,
        pi_description      VARCHAR2        default null,
        pi_config_id        VARCHAR2        default null,
        pi_config_code      VARCHAR2        default null,
        pi_config_user      VARCHAR2        default null,
        pi_config_name      VARCHAR2        default null,
        pi_config_value     JSON_OBJECT_T   default new JSON_OBJECT_T(),
        pi_config_type      VARCHAR2        default null,
        pi_status           VARCHAR2        default null
    )
-- manipulate
);
/

create or replace type body APP_CONFIG
as
-- static
-- constructor
    constructor function APP_CONFIG return self as result
    is
    begin
        self.initialize(
            pi_name         => 'APP_CONFIG',
            pi_status       => 'ACTIVE');
        return;
    end;

-- initialize
    member procedure set_config(
        pi_config_id        VARCHAR2        default null,
        pi_config_code      VARCHAR2        default null,
        pi_config_user      VARCHAR2        default null,
        pi_config_name      VARCHAR2        default null,
        pi_config_value     JSON_OBJECT_T   default new JSON_OBJECT_T(),
        pi_config_type      VARCHAR2        default null,
        pi_status           VARCHAR2        default null
    )
    is
    begin
        config_id       := pi_config_id;
        config_code     := pi_config_code;
        config_user     := pi_config_user;
        config_name     := pi_config_name;
        config_value    := pi_config_value;
        config_type     := pi_config_type;
        status          := pi_status;
    end;
    member procedure initialize(        
        pi_name             VARCHAR2        default null,
        pi_description      VARCHAR2        default null,
        pi_config_id        VARCHAR2        default null,
        pi_config_code      VARCHAR2        default null,
        pi_config_user      VARCHAR2        default null,
        pi_config_name      VARCHAR2        default null,
        pi_config_value     JSON_OBJECT_T   default new JSON_OBJECT_T(),
        pi_config_type      VARCHAR2        default null,
        pi_status           VARCHAR2        default null
    )
    is
    begin
        (self as APP_BASE_OBJECT).initialize(
            pi_name         => nvl(pi_name, "__name__"), 
            pi_description  => pi_description
        );
        self.set_config(
            pi_config_id        => pi_config_id,
            pi_config_code      => pi_config_code,
            pi_config_user      => pi_config_user,
            pi_config_name      => pi_config_name,
            pi_config_value     => pi_config_value,
            pi_config_type      => pi_config_type,
            pi_status           => nvl(pi_status, status)
        );
    end;

    member procedure print_config_value
    is
    begin
        app_util.print_string_format(config_value);
    end;

    overriding member procedure get_attributes_info
    is
    begin
        (self as APP_BASE_OBJECT).get_attributes_info();
        "__attributes__".put('config_id'    ,config_id);
        "__attributes__".put('config_code'  ,config_code);
        "__attributes__".put('config_user'  ,config_code);
        "__attributes__".put('config_name'  ,config_name);
        "__attributes__".put('config_value' ,config_value.to_string);
        "__attributes__".put('status'       ,status);
    end;
-- manipulate
end;
/

