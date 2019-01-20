/* **********************************************************************************
*   TYPE_TEMPLATE
** *********************************************************************************/

create or replace type TYPE_TEMPLATE force
as object(
    __name__        VARCHAR2(64),
-- static
-- constructor
-- initialize
-- manipulate
);
/

create or replace type body TYPE_TEMPLATE
as
-- static
-- constructor
-- initialize
-- manipulate
end;
/

/* **********************************************************************************
*   TYPE_TEMPLATE
** *********************************************************************************/

create or replace type TYPE_TEMPLATE force
under APP_BASE_OBJECT(
-- static
-- constructor
-- initialize
    member procedure initialize,
    overriding member procedure get_attributes_info,
-- manipulate
    overriding member procedure update_all
);
/

create or replace type body TYPE_TEMPLATE
as
-- static
-- constructor
-- initialize
-- manipulate
end;
/

