#!/usr/bin/env bash

set -eu

# sshd setting
export SSHD_CONFIG=/etc/ssh/sshd_config
if [ ! -e $SSHD_CONFIG.orig ]; then
    sudo cp $SSHD_CONFIG $SSHD_CONFIG.orig
else
    sudo cp $SSHD_CONFIG.orig $SSHD_CONFIG
fi
sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
service ssh restart

set +e

# add admin user(group)
getent group admin
if [ $? != '0' ]; then
    groupadd admin
fi

id admin
if [ $? != '0' ]; then
    useradd admin -m -g admin -s /bin/bash
    echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin
    chmod 0440 /etc/sudoers.d/admin
fi

set -e

# set admin public key
export ADMIN_HOME=`sudo -H -u admin printenv HOME`
mkdir -p $ADMIN_HOME/.ssh/
chmod 700 $ADMIN_HOME/.ssh
curl -fsSL https://github.com/emuesuenu.keys > $ADMIN_HOME/.ssh/authorized_keys
chmod 600 $ADMIN_HOME/.ssh/authorized_keys
chown -R admin:admin $ADMIN_HOME/.ssh
