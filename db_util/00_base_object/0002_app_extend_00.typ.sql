/* **********************************************************************************
** APP_EXTEND
** **********************************************************************************
**  Description: this is extend object of base object for some config and auto update
**      date time methods
**  Template:
** **********************************************************************************/
create or replace type APP_EXTEND force
under APP_BASE_OBJECT(
    "__app_config__"    APP_CONFIG,
-- private attributes
    "__config_value__"  VARCHAR2(4000),
    "__mode__"          VARCHAR2(64),
-- globall attributes
    created_ts          TIMESTAMP,
    created_dnum        NUMBER,
    created_tnum        NUMBER,
    created_unix_ts     NUMBER,
    updated_ts          TIMESTAMP,
    updated_dnum        NUMBER,
    updated_tnum        NUMBER,
    updated_unix_ts     NUMBER,
    duration            NUMBER,
-- static
-- constructor
    constructor function APP_EXTEND return self as result,
-- initialize
    member procedure initialize(
        pi_name             VARCHAR2    default null,
        pi_config_code      VARCHAR2    default null,
        pi_description      VARCHAR2    default null,
        pi_config_value     VARCHAR2    default null,
        pi_mode             VARCHAR2    default null
    ),
    member procedure get_config(
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null
    ),
    member procedure set_private_attributes(
        pi_config_value     VARCHAR2    default null,
        pi_mode             VARCHAR2    default null
    ),
    member procedure get_datetime_dim(
        pio_ts              in out TIMESTAMP,
        pio_dnum            in out NUMBER,
        pio_tnum            in out NUMBER,
        pio_unix_ts         in out NUMBER,
        pio_date            in out DATE
    ),
    overriding member procedure get_attributes_info,
-- manipulate
    member procedure get_created_datetime_dim,
    member procedure get_updated_datetime_dim,    
    member procedure get_duration,
    overriding member procedure update_all
) not final;
/

create or replace type body APP_EXTEND
as
-- static
-- constructor
    constructor function APP_EXTEND return self as result
    is
    begin
        initialize();
        return;
    end;
-- initialize
    member procedure initialize(
        pi_name             VARCHAR2    default null,
        pi_config_code      VARCHAR2    default null,
        pi_description      VARCHAR2    default null,
        pi_config_value     VARCHAR2    default null,
        pi_mode             VARCHAR2    default null
    )
    is
    begin
        (self as APP_BASE_OBJECT).initialize(
            pi_name         => nvl(pi_name          ,'APP_EXTEND'),
            pi_config_code  => nvl(pi_config_code   ,'APP_EXTEND'),
            pi_description  => pi_description);
        -- get config by default
        get_config();
        -- apply custom config
        set_private_attributes(
            pi_mode         => pi_mode,
            pi_config_value => pi_config_value
        );
        get_created_datetime_dim();
        get_updated_datetime_dim();
        get_duration();
    end;
    member procedure get_config(
        pi_config_code      VARCHAR2 default null,
        pi_config_name      VARCHAR2 default null
    )
    is
    begin
        app_config_util.get_config(
            pi_config_code  => nvl(pi_config_code, "__config_code__"), 
            pi_config_name  => nvl(pi_config_name, "__name__"),
            po_app_config   => "__app_config__");
    end;

    member procedure set_private_attributes(
        pi_config_value     VARCHAR2    default null,
        pi_mode             VARCHAR2    default null
    )
    is
    begin
        "__config_value__"  := nvl(pi_mode, "__app_config__".config_value.to_string);
        "__mode__"          := nvl(pi_mode, "__app_config__".config_value.get_string('__mode__'));
    end;

    member procedure get_datetime_dim(
        pio_ts              in out TIMESTAMP,
        pio_dnum            in out NUMBER,
        pio_tnum            in out NUMBER,
        pio_unix_ts         in out NUMBER,
        pio_date            in out DATE
    )
    is
    begin
        pio_ts          := current_timestamp;
        pio_dnum        := app_util.get_dnum(pio_ts);
        pio_tnum        := app_util.get_tnum(pio_ts);
        pio_unix_ts     := app_util.get_unix_ts(pio_ts);
        pio_date        := cast(pio_ts as DATE);

    end;

    overriding member procedure get_attributes_info
    is
    begin
        (self as APP_BASE_OBJECT).get_attributes_info();
        "__attributes__".put('__mode__'         ,"__mode__");
        "__attributes__".put('__config_value__' ,"__config_value__");
        "__attributes__".put('created_ts'       ,created_ts);
        "__attributes__".put('created_dnum'     ,created_dnum);
        "__attributes__".put('created_tnum'     ,created_tnum);
        "__attributes__".put('created_unix_ts'  ,created_unix_ts);        
        "__attributes__".put('updated_ts'       ,updated_ts);
        "__attributes__".put('updated_dnum'     ,updated_dnum);
        "__attributes__".put('updated_tnum'     ,updated_tnum);
        "__attributes__".put('updated_unix_ts'  ,updated_unix_ts);
        "__attributes__".put('duration'         ,duration);
    end;
-- manipulate
    member procedure get_created_datetime_dim
    is
    begin
        get_datetime_dim(
            pio_ts          => created_ts,
            pio_dnum        => created_dnum,
            pio_tnum        => created_tnum,
            pio_unix_ts     => created_unix_ts,
            pio_date        => created_date
        );
    end;

    member procedure get_updated_datetime_dim
    is
    begin
        get_datetime_dim(
            pio_ts          => updated_ts,
            pio_dnum        => updated_dnum,
            pio_tnum        => updated_tnum,
            pio_unix_ts     => updated_unix_ts,
            pio_date        => updated_date
        );
    end;

    member procedure get_duration
    is
    begin
        duration    := app_util.get_unix_ts() - updated_unix_ts;
    end;

    overriding member procedure update_all
    is
    begin
        (self as APP_BASE_OBJECT).update_all();
        get_duration();
        get_updated_datetime_dim();
    end;
end;
/