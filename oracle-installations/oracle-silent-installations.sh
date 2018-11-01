ORACLE_INSTALLER=/stage/database/runInstaller
ORACLE_RESPOND_FILE='/home/oracle/db11R2.rsp'
[ -f $ORACLE_INSTALLER ] && su oracle -c "$ORACLE_INSTALLER -silent -responseFile $ORACLE_RESPOND_FILE" || echo "Cannot install oracle db"