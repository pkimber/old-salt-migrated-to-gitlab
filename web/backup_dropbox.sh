#!/bin/bash
# exit immediately if a command exits with a nonzero exit status.
set -e
# treat unset variables as an error when substituting.
set -u
# backup
{% set rsync = gpg['rsync'] -%}

#check if the $1 variable is unset
if [ -z ${1+x} ]
#if it is unset
then
    #create a variable called VAR1 and set it to ""
    VAR1=""
#if it is set
else
    #create a variable called VAR1 and set it to = $1
    VAR1=$1
fi

# backup dropbox
echo "===================="
echo "duplicity dropbox backup"
if [ `date +%d` == "01" ] || [ "$VAR1" == "full" ] 
then
    echo "full backup"
    echo "===================="
    # Delete extraneous duplicity files
    PASSPHRASE="{{ rsync['pass'] }}" duplicity cleanup --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }}
    # Delete all full and incremental backup sets older than 3 months
    duplicity remove-older-than 3M --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }}
    # Runs an full backup on the 1st
    duplicity full --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/dropbox/{{ dropbox_account }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }}
    # Delete incremental backups older than the last full backup
    duplicity remove-all-inc-of-but-n-full 1 --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }}
else
    echo "incremental backup"
    echo "===================="
    # Runs an incremental backup on days other than the 1st
    duplicity incr --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/dropbox/{{ dropbox_account }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }}
fi
# PJK 22/04/2016 removed ref #1442
# echo "duplicity dropbox - verify"
# PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/dropbox/{{ dropbox_account }} /home/web/repo/files/dropbox/{{ dropbox_account }}
