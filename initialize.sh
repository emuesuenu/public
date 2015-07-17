#!/usr/bin/env bash

set -e

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
`getent group admin`
if [ $? != '0' ]; then
    groupadd admin
fi
`id admin`
if [ $? != '0' ]; then
    useradd admin -m -g admin -s /bin/bash
    echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin
    chmod 0440 /etc/sudoers.d/admin
fi

set -e

# set admin public key
export ADMIN_HOME=`sudo -H -u admin printenv HOME`
export PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9nkt/SfBtLp9SoUNwpcP6BfjbaSgYJsNeUXfFaY1RNjXT6a5CxoxgxIlo3TiTxuLOHkAazhUaEz/1S70AUguekNC6+7rzS81dir+YVk9Jwq9Gh1xDfSzEG4zWLGu/nqBbwk7KgDhkXsQ4EFun5cm/C7hnOQeAYVdAIxol3yMtSLNiYYXp9n0+NhgTh5UWEDEFiWQpRd8ZrHaUEPjI8EypwEe/mxSz+PMYGKZ3wccY1pN6d7CsDr+r7VrGIByu4auC292U5peRxrfBDBwDShCNNmjii/0025DWUs88OBPtFRzk5bzQR2c9n2Z+2n1hGeFhHCclpghtGGNdGMO8Y4FZ hidenori-kondo@MGXA2JA.local"
mkdir -p $ADMIN_HOME/.ssh/
chmod 700 $ADMIN_HOME/.ssh
echo $PUBLIC_KEY > $ADMIN_HOME/.ssh/authorized_keys
chmod 600 $ADMIN_HOME/.ssh/authorized_keys
chown -R admin:admin $ADMIN_HOME/.ssh
