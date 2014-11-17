#!/bin/bash
# exit immediately if a command exits with a nonzero exit status.
set -e
# treat unset variables as an error when substituting.
set -u
# backup {{ site }}
{% set rsync = gpg['rsync'] -%}

# dump database
DUMP_FILE=/home/web/repo/backup/{{ site }}/$(date +"%Y%m%d_%H%M").sql
echo "dump database: $DUMP_FILE"
pg_dump -U postgres {{ site_name }} -f $DUMP_FILE
# Send a metric to statsd from bash
# nstielau / send_metric_to_statsd.sh
# https://gist.github.com/nstielau/966835
#
# Useful for:
#   deploy scripts (http://codeascraft.etsy.com/2010/12/08/track-every-release/)
#   init scripts
#   sending metrics via crontab one-liners
#   sprinkling in existing bash scripts.
#
# netcat options:
#   -w timeout If a connection and stdin are idle for more than timeout seconds, then the connection is silently closed.
#   -u         Use UDP instead of the default option of TCP.
echo "{{ site_name }}.rsync.backup.dump:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# backup database
echo "duplicity database backup (including any files within the backup folder)"
if [ `date +%d` == "01" ] || [ `date +%d` == "15" ]
then
    echo "full backup"
    # Delete extraneous duplicity files
    duplicity --cleanup --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
    # Delete all full and incremental backup sets older than 12 months
    duplicity --remove-older-than 12M --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
    # Runs an full backup on the 1st or 15th
    duplicity --full --encrypt-key="{{ rsync['key'] }}" /home/web/repo/backup/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
    # Delete incremental backups older than the 2nd to last full backup
    duplicity --remove-all-inc-of-but-2-full --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
else
    echo "incremental backup"
    # Runs an incremental backup on days other than the 1st or 15th
    duplicity --incr --encrypt-key="{{ rsync['key'] }}" /home/web/repo/backup/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
fi
echo "{{ site_name }}.rsync.backup:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

echo "duplicity database backup verify (including any files within the backup folder)"
PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup /home/web/repo/backup/{{ site }}
echo "{{ site_name }}.rsync.backup.verify:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# backup files
echo "duplicity files"
if [ `date +%d` == "01" ] 
then
    echo "full backup"
    # Delete extraneous duplicity files
    duplicity --cleanup --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
    # Delete all full and incremental backup sets older than 3 months
    duplicity --remove-older-than 3M --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
    # Runs an full backup on the 1st
    duplicity --full --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
    # Delete incremental backups older than the last full backup
    duplicity --remove-all-inc-of-but-1-full --force scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
else
    echo "incremental backup"
    # Runs an incremental backup on days other than the 1st
    duplicity --incr --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
fi
echo "{{ site_name }}.rsync.files:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# Not sure that verify this way is a good idea.  Lots of bandwidth etc.
# echo "duplicity files - verify"
# PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files /home/web/repo/files/{{ site }}
# echo "{{ site_name }}.rsync.files.verify:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# remove database dump
echo "remove: $DUMP_FILE"
rm $DUMP_FILE
