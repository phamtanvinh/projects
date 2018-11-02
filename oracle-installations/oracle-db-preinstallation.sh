#!/bin/bash
#
# Created by: Vinhpt
# Created date: 1-Nov-18
# Install ODB 11gR2 on Centos 6


CONFIG_NETWORK_FILE=/etc/sysconfig/network
CONFIG_HOSTS_FILE='/etc/hosts'
CONFIG_SELINUX_FILE='/etc/selinux/config'
CONFIG_IPTABLE_FILE='/etc/sysconfig/iptables'
IP_ADDR=$(ip -f inet a show eth1| sed -e 's/[ \/]/\n/g'| grep '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}' -m 1)
HOSTNAME='ords'
SELINUX_STATUS='permissive'
STAGE_DIR='/stage'
SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" )
DATA_STORAGE='/dev/sdb1'
DATA_DIR='/data'

ORACLE_VER='11.2.0'
ORACLE_USER='oracle'
ORACLE_GROUP='oinstall'
ORACLE_PASSWORD='123456'
ORACLE_UNQNAME='orcl'
ORACLE_SID='orcl'
ORACLE_DB_HOME=dbhome
ORACLE_DB_DIR='/u01'
ORACLE_BASE=$ORACLE_DB_DIR/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/$ORACLE_VER/$ORACLE_DB_HOME
ORACLE_PORTS=( '1158' '1521' )
ORACLE_ORATAB=/etc/oratab

ORACLE_DB_FILE_1=/data/linux.x64_11gR2_database_1of2.zip
ORACLE_DB_FILE_2=/data/linux.x64_11gR2_database_2of2.zip
ORACLE_DB_FILES=( ORACLE_DB_FILE1 ORACLE_DB_FILE2 )
ORACLE_RESPONSEFILE=$SCRIPT_DIR/db11R2.rsp

id -u $ORACLE_USER &>/dev/null && echo "User oracle was installed." &&
while true
do
    read -p "Do you wish to install this program?[y|n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Remove oracle"
userdel -r $ORACLE_USER &>/dev/null

echo "Remove Oracle SID on $ORACLE_ORATAB"
[ -f $ORACLE_ORATAB ] && sed -c -i "s/^$ORACLE_SID.*$ORACLE_DB_HOME.*//" $ORACLE_ORATAB

echo "Download wget, zip, unzip, rlwrap"
yum -q list installed wget &>/dev/null && echo "wget was installed" || yum install -y wget 
yum -q list installed zip &>/dev/null && echo "zip was installed" || yum install -y zip 
yum -q list installed unzip &>/dev/null && echo "unzip was installed" || yum install -y unzip 
yum -q list installed rlwrap &>/dev/null && echo "rlwrap was installed" || yum install -y rlwrap 

echo "Get repo..."
wget https://public-yum.oracle.com/public-yum-ol6.repo -O /etc/yum.repos.d/public-yum-ol6.repo &>/dev/null

echo "Get RPM-GPG-KEY..."
wget https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle &>/dev/null

echo "Download oracle-rdbms-server-11gR2-preinstall..."
yum -q list installed oracle-rdbms-server-11gR2-preinstall &>/dev/null && yum remove -y oracle-rdbms-server-11gR2-preinstall &>/dev/null
yum install -y oracle-rdbms-server-11gR2-preinstall

echo "Setting hostname..."

sed -c -i "s/^\(HOSTNAME=*\).*/\1$HOSTNAME/" $CONFIG_NETWORK_FILE

grep "$IP_ADDR" /etc/hosts &>/dev/null && sed -c -i "s/^\(\b$IP_ADDR\b\).*/\1  $HOSTNAME  $HOSTNAME/" $CONFIG_HOSTS_FILE || echo "$IP_ADDR  $HOSTNAME  $HOSTNAME" >> $CONFIG_HOSTS_FILE

/etc/init.d/network restart &>/dev/null

echo "Oracle user setting..."
echo "$ORACLE_USER:$ORACLE_PASSWORD" | chpasswd

echo "* - nproc 16384" >> /etc/security/limits.d/90-nproc.conf

echo "Create directory"
rm -rf $ORACLE_DB_DIR
mkdir -p $ORACLE_HOME
chown -R $ORACLE_USER:$ORACLE_GROUP $ORACLE_DB_DIR
chmod -R 775 $ORACLE_DB_DIR

rm -rf $STAGE_DIR
mkdir -p $STAGE_DIR

echo "Unzip files if exist..."
#mount storage
df -P -T $DATA_DIR | grep $DATA_STORAGE || (echo "Mounting storage ..."  && mount $DATA_STORAGE $DATA_DIR &> /dev/null && echo "Mount Done" || echo "Mount Fail")

for ORACLE_DB_FILE in ${ORACLE_DB_FILES[@]}; do
    unzip -o $ORACLE_DB_FILE -d $STAGE_DIR &>/dev/null && echo "Extract $ORACLE_DB_FILE OK" || echo "$ORACLE_DB_FILE not found"
done

echo "Open port for oracle db"
echo "Backup $CONFIG_IPTABLE_FILE to $CONFIG_IPTABLE_FILE.$(date +%s)"
cp $CONFIG_IPTABLE_FILE $CONFIG_IPTABLE_FILE.$(date +%s)

for PORT in ${ORACLE_PORTS[@]}; do
    TMP=$(grep -e "-A INPUT.*--dport.*-j ACCEPT" -m 1 $CONFIG_IPTABLE_FILE)
    TMP_ADD_PORT="-A INPUT -m state --state NEW -m tcp -p tcp --dport $PORT -j ACCEPT"
    grep -e "-A INPUT.*-dport $PORT.*-j ACCEPT" $CONFIG_IPTABLE_FILE &>/dev/null || sed -c -i "0,/$TMP/s/$TMP/$TMP\n$TMP_ADD_PORT/" $CONFIG_IPTABLE_FILE
done

iptables-restore < $CONFIG_IPTABLE_FILE
/etc/init.d/iptables restart

echo "Setting Oracle DB"
ORACLE_DB_SETTING="
# Setting Oracle DB
export TMPDIR=/tmp;

export ORACLE_HOSTNAME=$HOSTNAME;
export ORACLE_UNQNAME=$ORACLE_UNQNAME;
export ORACLE_BASE=$ORACLE_BASE;
export ORACLE_HOME=$ORACLE_HOME;
export ORACLE_SID=$ORACLE_SID;
export PATH=/usr/sbin:$PATH;
export PATH=$ORACLE_HOME/bin:$PATH;

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;
"
su $ORACLE_USER -c "echo \"$ORACLE_DB_SETTING\" >> ~/.bash_profile"
cp -rf $ORACLE_RESPONSEFILE /tmp

echo "# After running successfully, run below command with oracle user: 
$STAGE_DIR/database/runInstaller -ignoreSysPrereqs -ignorePrereq -waitforcompletion -silent -responseFile /tmp/$(basename $ORACLE_RESPONSEFILE)
" > ~/$(basename "$0").log
echo "Using GUI to install or see log ~/$(basename "$0").log for next silent installation."

echo "Checking SELinux..."
grep 'SELINUX=permissive' /etc/sysconfig/selinux &>/dev/null
if [ $? ]; then 
    echo "Have set permissive"
else 
    sed -c -i "s/^\(SELINUX=\).*/\1$SELINUX_STATUS/" $CONFIG_SELINUX_FILE 
    reboot
fi


