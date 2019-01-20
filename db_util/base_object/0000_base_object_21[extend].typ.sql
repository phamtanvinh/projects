create or replace type APP_EXTEND force
under APP_BASE_OBJECT(
    "__code__"          VARCHAR2(64),
    "__mode__"          VARCHAR2(64),
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
    member procedure get_datetime_dim(
        pio_ts          in out TIMESTAMP,
        pio_dnum        in out NUMBER,
        pio_tnum        in out NUMBER,
        pio_unix_ts     in out NUMBER,
        pio_date        in out DATE),
    member procedure initialize(
        pi_name             VARCHAR2    default null,
        pi_description      VARCHAR2    default null,
        pi_code             VARCHAR2    default null,
        pi_mode             VARCHAR2    default null),
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
        initialize(
            pi_name         => 'APP_EXTEND'
        );
        return;
    end;
-- initialize
    member procedure get_datetime_dim(
        pio_ts          in out TIMESTAMP,
        pio_dnum        in out NUMBER,
        pio_tnum        in out NUMBER,
        pio_unix_ts     in out NUMBER,
        pio_date        in out DATE
    )
    is
    begin
        pio_ts          := current_timestamp;
        pio_dnum        := app_util.get_dnum(pio_ts);
        pio_tnum        := app_util.get_tnum(pio_ts);
        pio_unix_ts     := app_util.get_unix_ts(pio_ts);
        pio_date        := cast(pio_ts as DATE);

    end;
    member procedure initialize(
        pi_name             VARCHAR2    default null,
        pi_description      VARCHAR2    default null,
        pi_code             VARCHAR2    default null,
        pi_mode             VARCHAR2    default null
    )
    is
    begin
        "__attributes__"    := new JSON_OBJECT_T();
        "__name__"          := pi_name;
        "__code__"          := pi_code;
        "__mode__"          := pi_mode;
        description         := pi_description;
        get_created_datetime_dim();
        update_all();
    end;
    overriding member procedure get_attributes_info
    is
    begin
        (self as APP_BASE_OBJECT).get_attributes_info();
        "__attributes__".put('__code__'         ,"__code__");
        "__attributes__".put('__mode__'         ,"__mode__");
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
        get_duration();
        get_updated_datetime_dim();
    end;
end;
/