#!/bin/bash
############################################################
#
# NFS2FSTAB
#
# A script to populate fstab with nfs shares and
# make them accessible for the current user.
#
# WARNING! This script handles Linux system files, and can
#          cause irreparable damage to your operating 
#          system and hardware. Use caution and have backups.
#
# Author: Kim Ekblad
# Uploaded to Github Oct 22 2026
# License - CC BY-SA 4.0
# http://creativecommons.org/licenses/by/4.0
#
# Credits:
# tripleee https://stackoverflow.com/a/57657942
# Dan https://askubuntu.com/a/970898,
# aneeshep and Lekensteyn https://askubuntu.com/a/30157/8698
############################################################

############################################################
# Proper formatting of NFS-shares to process:
# MOUNTS="NAME:IP:FOLDER"
# NAME is the name of your NFS-share and folder name under /mnt
# IP is the ip address of the share
# FOLDER is the location of the share on the server
#
# Separate multiple NFS-shares with space
#
# Example:
# MOUNTS="NAME:IP:FOLDER NAME2:IP2:FOLDER2"
#
# MAKE YOUR CHANGES HERE:
MOUNTS="dummy:10.10.10.10:/mnt/dummy tank:192.168.0.2:/mnt/tank"
############################################################




############################################################
# Check that user has sudo rights or is root:
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

# Separate user and sudoer to get correct uid and gid later.
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# To run commands as non-root: sudo -u $real_user

# Make a backup of fstab just in case...
cp /etc/fstab ./fstab.orig

# Get uid and gid of real_user
uid=$(sudo -u $real_user id -u)
gid=$(sudo -u $real_user id -g)


# Iterate through shares and make changes to system.
# If not exist, add wanted mount to fstab and
# create a dir to mount the share in.

for MNT in $MOUNTS
do 
IFS=: read -r NAME IP FOLDER <<< "$MNT"
grep -q "$NAME-init" /etc/fstab ||
printf "\n#$NAME-init\n$IP:$FOLDER /mnt/$NAME nfs defaults,_netdev,noauto,uid=$uid,gid=$gid,x-systemd.automount 0 0" >> /etc/fstab
#mkdir /mnt/$NAME -p
done


# Aand finished.
if [ -z $MOUNTS ]; then
    echo 'Variable $MOUNTS is empty. No changes were made.'
else
    echo 'Run 'sudo mount -a' or reboot to apply changes.'
fi

