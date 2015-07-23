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
export PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1wNcw1ApKtyFSXWfD9sj3bckLx0sSgFrQj3xGK3dWvFfOATraGrjUJ3LofScUtFhDKkJZPdzY60w/ccQIACDsoUXUCRRqfyShWgPOAc3R9y01VQVPpxbnpyo5Cg9XaZ/RAKQxmlXHMaaQKOP1/MWjAPQXzZo2Xd91XuCScihB87lNowSMy6+kQ5sOWIhaf4yWrPKZwM+fcEQWU/F4FNz+lrcVi6fjXe5ZSHnd0uz8H84LYk+eL00p5gH+gT0wfgG/uOWg2J5g7uvUeKo0HZ9WO/VSWrovfy6OP2KCUPXXAr4ygBfOtbrxNIZBd9DLFNTm6a+tOHs4W58rYKWLgNLhw== root@P8Z77-V"
mkdir -p $ADMIN_HOME/.ssh/
chmod 700 $ADMIN_HOME/.ssh
echo $PUBLIC_KEY > $ADMIN_HOME/.ssh/authorized_keys
chmod 600 $ADMIN_HOME/.ssh/authorized_keys
chown -R admin:admin $ADMIN_HOME/.ssh
