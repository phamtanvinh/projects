#!/bin/sh

STAGE_DIR='/stage'
ORACLE_HOME='/home/oracle'
APEX_FILE_SOURCE='/data/apex_5.1.4.zip'
APEX_STAGE_DIR="$STAGE_DIR/apex"
APEX_PASSWD_DEFAULT='123456'

# Clean up and install
APEX_REMOVE_FILE='apxremov.sql'

# Setting user configuration

APEX_TABLESPACE='APEX'
APEX_ADMIN_NAME='ADMIN'
APEX_ADMIN_EMAIL_ADDRESS='condia49@gmail.com'
APEX_ADMIN_PASSWD='McPVVvAddJg;k6[d'

APEX_LISTENER_PASSWD=$APEX_PASSWD_DEFAULT
APEX_PUBLIC_USER_PASSWD=$APEX_PASSWD_DEFAULT
APEX_REST_PUBLIC_USER_PASSWD=$APEX_PASSWD_DEFAULT
ORDS_PUBLIC_USER_PASSWD=$APEX_PASSWD_DEFAULT

APEX_DATA_FILE='/u01/oracle/apex01.dbf'
APEX_REST_PASSWD=$APEX_PASSWD_DEFAULT

echo "unzip file into /stage"
[ -f $APEX_FILE_SOURCE ] && echo "unzipping..." unzip -o $APEX_FILE_SOURCE -d /stage || echo "File not found"; exit 1

cd $APEX_STAGE_DIR

# Clean up previous installation
sqlplus / as sysdba <<ENDOFSQL
@$APEX_REMOVE_FILE

ENDOFSQL


# New installation
sqlplus / as sysdba <<ENDOFSQL
CREATE TABLESPACE $APEX_TABLESPACE DATAFILE $APEX_DATA_FILE SIZE 100M AUTOEXTEND ON NEXT 1M;
CONN / AS SYSDBA;
@apexins.sql APEX APEX TEMP /i/

CONN / AS SYSDBA;
@apxchpwd.sql

BEGIN
    APEX_UTIL.set_security_group_id( 10 );
    
    APEX_UTIL.create_user(
        p_user_name       => $APEX_ADMIN_NAME,
        p_email_address   => $APEX_ADMIN_EMAIL_ADDRESS,
        p_web_password    => $APEX_ADMIN_PASSWD,
        p_developer_privs => $APEX_ADMIN_NAME );
        
    APEX_UTIL.set_security_group_id( null );
    COMMIT;
END;
/

CONN / AS SYSDBA;
@apex_rest_config.sql;
@apex_rest_config.sql $APEX_REST_PASSWD $APEX_REST_PASSWD
CONN / AS SYSDBA;
@apex_epg_config.sql $ORACLE_HOME
ALTER USER ANONYMOUS ACCOUNT UNLOCK;
EXEC DBMS_XDB.sethttpport(8080);

ENDOFSQL


sqlplus / as sysdba <<ENDOFSQL
CONN / AS SYSDBA
ALTER USER SYS ACCOUNT UNLOCK;

ALTER USER APEX_LISTENER IDENTIFIED BY $APEX_LISTENER_PASSWD ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY $APEX_PUBLIC_USER_PASSWD ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY $APEX_REST_PUBLIC_USER_PASSWD ACCOUNT UNLOCK;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY $ORDS_PUBLIC_USER_PASSWD ACCOUNT UNLOCK;

ENDOFSQL

