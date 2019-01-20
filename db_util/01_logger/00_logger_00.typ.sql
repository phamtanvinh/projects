/* **********************************************************************************
** APP_LOGGER
** **********************************************************************************
**  Description: 
**  Template:
** **********************************************************************************/

create or replace type APP_LOGGER force
under APP_EXTEND(
    transaction_id          VARCHAR2(64),
    transaction_code        VARCHAR2(64),
    app_user                VARCHAR2(64),
    unit_name               VARCHAR2(64),
    unit_type               VARCHAR2(64),
    log_step_id             NUMBER,
    log_step_name           VARCHAR2(64),
    log_step_description    VARCHAR2(1024),
    error_sqlcode           VARCHAR2(64),
    error_sqlerrm           VARCHAR2(4000),
    error_backtrace         VARCHAR2(4000),
-- static
-- constructor
    constructor function APP_LOGGER return self as result,
-- initialize
    member procedure initialize(
        pi_name                 VARCHAR2    default null,
        pi_description          VARCHAR2    default null,
        pi_code                 VARCHAR2    default null,
        pi_mode                 VARCHAR2    default null,
        pi_transaction_code     VARCHAR2    default null,
        pi_app_user             VARCHAR2    default null,
        pi_unit_name            VARCHAR2    default null,
        pi_unit_type            VARCHAR2    default null,
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    ),
    member procedure set_transaction(pi_transaction_code     VARCHAR2    default null),
    member procedure set_process_unit(
        pi_unit_name            VARCHAR2    default null,
        pi_unit_type            VARCHAR2    default null
    ),
    member procedure set_log_step(
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    ),
    overriding member procedure get_attributes_info,
-- manipulate
    member procedure update_step(
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    ),
    member procedure initialize_exception,
    overriding member procedure update_all
) not final;
/

create or replace type body APP_LOGGER
as
-- static
-- constructor
    constructor function APP_LOGGER return self as result
    is
    begin
        initialize(
            pi_name             => 'APP_LOGGER'
        );
        return;
    end;
-- initialize
    member procedure initialize(
        pi_name                 VARCHAR2    default null,
        pi_description          VARCHAR2    default null,
        pi_code                 VARCHAR2    default null,
        pi_mode                 VARCHAR2    default null,
        pi_transaction_code     VARCHAR2    default null,
        pi_app_user             VARCHAR2    default null,
        pi_unit_name            VARCHAR2    default null,
        pi_unit_type            VARCHAR2    default null,
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    )
    is
    begin
        (self as APP_EXTEND).initialize(
            pi_name             => pi_name,
            pi_description      => pi_description,
            pi_code             => pi_code,
            pi_mode             => pi_mode);
        set_transaction(pi_transaction_code     => pi_transaction_code);
        set_log_step(
            pi_log_step_name            => pi_log_step_name,
            pi_log_step_description     => pi_log_step_description
        );
        set_process_unit(
            pi_unit_name        => pi_unit_name,
            pi_unit_type        => pi_unit_type
        );
    end;

    member procedure set_transaction(pi_transaction_code     VARCHAR2    default null)
    is
    begin
        transaction_id      := app_util.get_transaction_id();
        transaction_code    := pi_transaction_code;
    end;

    member procedure set_process_unit(
        pi_unit_name            VARCHAR2    default null,
        pi_unit_type            VARCHAR2    default null
    )
    is
    begin
        unit_name   := pi_unit_name;
        unit_type   := pi_unit_type;
    end;

    member procedure set_log_step(
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    )
    is
    begin
        log_step_id             := nvl(log_step_id, 0) + 1;
        log_step_name           := pi_log_step_name;
        log_step_description    := pi_log_step_description;
    end;

    overriding member procedure get_attributes_info
    is
    begin
        (self as APP_EXTEND).get_attributes_info();
        "__attributes__".put('transaction_id'           ,transaction_id);
        "__attributes__".put('transaction_code'         ,transaction_code);
        "__attributes__".put('app_user'                 ,app_user);
        "__attributes__".put('unit_name'                ,unit_name);
        "__attributes__".put('unit_type'                ,unit_type);
        "__attributes__".put('log_step_id'              ,log_step_id);
        "__attributes__".put('log_step_name'            ,log_step_name);
        "__attributes__".put('log_step_description'     ,log_step_description);
        "__attributes__".put('error_sqlcode'            ,error_sqlcode);
        "__attributes__".put('error_sqlerrm'            ,error_sqlerrm);
        "__attributes__".put('error_backtrace'          ,error_backtrace);
    end;
-- manipulate
    member procedure update_step(
        pi_log_step_name        VARCHAR2    default null,
        pi_log_step_description VARCHAR2    default null
    )
    is
    begin
        update_all();
        set_log_step(
            pi_log_step_name            => pi_log_step_name,
            pi_log_step_description     => pi_log_step_description
        );
    end;
    member procedure initialize_exception
    is
    begin
        error_sqlcode       := sqlcode;
        error_sqlerrm       := sqlerrm(sqlcode);
        error_backtrace     := dbms_utility.format_error_backtrace;
    end;
    overriding member procedure update_all
    is
    begin
        (self as APP_EXTEND).update_all();
    end;
end;
/