#!/bin/bash

NETWORK_DEVICE='eth1'
STORAGE_DEVICE='sdb1'
IP_ADDR="$(ip addr show $NETWORK_DEVICE | grep -Po 'inet \K[\d.]+')"
HOST_NAME='orcl12c'
HOST_FILE='/etc/hosts'
NETWORK_FILE='/etc/sysconfig/network'
SELINUX_FILE='/etc/sysconfig/selinux'
DATA_DIR='/data'

# Oracle evironment
ORACLE_PACKAGE_LIST_FILE='db12c-package-list'
ORACLE_REPO='https://public-yum.oracle.com/public-yum-ol6.repo'

echo "Download wget, zip, unzip, rlwrap"
yum -q list installed wget &>/dev/null && echo "wget was installed" || yum install -y wget 
yum -q list installed zip &>/dev/null && echo "zip was installed" || yum install -y zip 
yum -q list installed unzip &>/dev/null && echo "unzip was installed" || yum install -y unzip 
yum -q list installed rlwrap &>/dev/null && echo "rlwrap was installed" || yum install -y rlwrap 

echo "Check mount storage ..."
if [[ $(df -hT | grep '/dev/sdb1') ]]; then
  echo "Check storage $STORAGE_DEVICE ... OK"
else
  echo 'Mounting storage...'
  mount "/dev/$STORAGE_DEVICE" "$DATA_DIR" && echo 'Mount ... OK' || echo "Mount ... Fail"
fi

# Config host
grep "$IP_ADDR" "$HOST_FILE" > /dev/null
if [[ $? -eq 0 ]]; then
  sed -ci "s/^\(\b$IP_ADDR\b\)\(.*\)/\1\t$HOST_NAME\t$HOST_NAME/" "$HOST_FILE" && echo "Config hosts ... OK"
else
   echo "$IP_ADDR $HOST_NAME $HOST_NAME" >> "$HOST_FILE" && echo "Add hosts ... OK"
fi

grep "HOSTNAME" $NETWORK_FILE > /dev/null
if [[ $? -eq 0 ]]; then
  sed -ci "s/\(HOSTNAME=\).*/\1$HOST_NAME/" $NETWORK_FILE
  echo 'Config hostname for netwok ... OK'
else 
  echo "HOSTNAME=$HOST_NAME" >> $NETWORK_FILE && echo "Add hostname to $NETWORK_FILE"
  echo 'Config hostname for network ... OK'
fi

# Install package
yum install -y epel-release 2>/dev/null || echo 'epel-release was installed'

[[ -f "/etc/yum.repos.d/${ORACLE_REPO##*/}" ]] && echo "${ORACLE_REPO##*/} exists" || wget $ORACLE_REPO -O "/etc/yum.repos.d/${ORACLE_REPO##*/}"
[[ -f "/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle" ]] && echo "RPM-GPG-KEY-oracle exists" || wget https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle

echo 'Clean up yum ... '
yum clean metadata > /dev/null 

echo 'Install oracle-rdbms-server-12cR1-preinstall ...'

yum install -y oracle-rdbms-server-12cR1-preinstall

# Config selinux
grep "^SELINUX=enforcing" "$SELINUX_FILE" > /dev/null
if [[ $? -eq 0 ]]; then
  sed -ci "s/SELINUX=enforcing/SELINUX=permissive/" "$SELINUX_FILE" && 
    echo "Set to permissive" &&
    echo "Reboot now..." && reboot
else
  echo 'Check selinux ... OK'
fi
