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
echo "duplicity backup (including database)"
duplicity --encrypt-key="{{ rsync['key'] }}" /home/web/repo/backup/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup
echo "{{ site_name }}.rsync.backup:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003
# Not sure that verify this way is a good idea.  Lots of bandwidth etc.
# echo "duplicity backup verify (including database)"
# PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/backup /home/web/repo/backup/{{ site }}
# echo "{{ site_name }}.rsync.backup.verify:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# backup files
echo "duplicity files"
duplicity --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files
echo "{{ site_name }}.rsync.files:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003
# Not sure that verify this way is a good idea.  Lots of bandwidth etc.
# echo "duplicity files - verify"
# PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site_name }}/files /home/web/repo/files/{{ site }}
# echo "{{ site_name }}.rsync.files.verify:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003

# remove database dump
echo "remove: $DUMP_FILE"
rm $DUMP_FILE
