 
#!/bin/sh
# install odb 11g on Centos 6

CONFIG_NETWORK_FILE=/etc/sysconfig/network
CONFIG_HOSTS_FILE='/etc/hosts'
CONFIG_SELINUX_FILE='/etc/selinux/config'
CONFIG_IPTABLE_FILE='/etc/sysconfig/iptables'
IP_ADDR=`ip -f inet a show eth1| sed -e 's/[ \/]/\n/g'| grep '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}' -m 1`
HOSTNAME='ords'
SELINUX_STATUS='permissive'

ORACLE_PASSWORD='123456'
ORACLE_UNQNAME='orcl'
ORACLE_SID='orcl'
ORACLE_BASE='/u01/app/oracle'
ORACLE_HOME="$ORACLE_BASE/product/11.2.0/dbhome"
ORACLE_PORTS=('1158' '1521')

ORACLE_DB_FILE_1=/data/linux.x64_11gR2_database_1of2.zip
ORACLE_DB_FILE_2=/data/linux.x64_11gR2_database_2of2.zip

echo "Remove oracle"
userdel -r oracle &>/dev/null

echo "Download wget, zip, unzip"
yum -q list installed wget &>/dev/null && echo "wget was installed" || yum install -y wget 
yum -q list installed zip &>/dev/null && echo "zip was installed" || yum install -y zip 
yum -q list installed unzip &>/dev/null && echo "unzip was installed" || yum install -y unzip 

echo "Get repo..."
wget https://public-yum.oracle.com/public-yum-ol6.repo -O /etc/yum.repos.d/public-yum-ol6.repo &>/dev/null

echo "Get RPM-GPG-KEY..."
wget https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle &>/dev/null

echo "Download Preinstallation"
yum -q list installed oracle-rdbms-server-11gR2-preinstall &>/dev/null && yum remove -y oracle-rdbms-server-11gR2-preinstall &>/dev/null
yum install -y oracle-rdbms-server-11gR2-preinstall &>/dev/null

echo "Setting hostname..."

sed -c -i "s/^\(HOSTNAME=*\).*/\1$HOSTNAME/" $CONFIG_NETWORK_FILE

grep "$IP_ADDR" /etc/hosts &>/dev/null && sed -c -i "s/^\(\b$IP_ADDR\b\).*/\1  $HOSTNAME  $HOSTNAME/" $CONFIG_HOSTS_FILE || echo "$IP_ADDR  $HOSTNAME  $HOSTNAME" >> $CONFIG_HOSTS_FILE

/etc/init.d/network restart &>/dev/null

echo "Oracle user setting..."
echo "oracle:$ORACLE_PASSWORD" | chpasswd

echo "* - nproc 16384" >> /etc/security/limits.d/90-nproc.conf

echo "Setting SELinux..."
sed -c -i "s/^\(SELINUX=\).*/\1$SELINUX_STATUS/" $CONFIG_SELINUX_FILE

echo "Create directory"
mkdir -p $ORACLE_HOME
chown -R oracle:oinstall /u01
chmod -R 775 /u01

rm -rf /stage
mkdir -p /stage

echo "Unzip files if exist..."
[ -f $ORACLE_DB_FILE_1 ] && unzip -o $ORACLE_DB_FILE_1 -d /stage 
[ -f $ORACLE_DB_FILE_2 ] && unzip -o $ORACLE_DB_FILE_2 -d /stage 

echo "Open port for oracle db"

cp $CONFIG_IPTABLE_FILE $CONFIG_IPTABLE_FILE.$(date +%s)

for PORT in ${ORACLE_PORTS[@]}
do
    TMP_ADD_PORT="-A INPUT -m state --state NEW -m tcp -p tcp --dport $PORT -j ACCEPT"
    grep -- "-A INPUT.*-dport $PORT.*-j ACCEPT" $CONFIG_IPTABLE_FILE &>/dev/null || sed -c -i "0,/$TMP/s/$TMP/$TMP\n$TMP_ADD_PORT/" $CONFIG_IPTABLE_FILE

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
su oracle -c "echo \"$ORACLE_DB_SETTING\" >> ~/.bash_profile"

reboot