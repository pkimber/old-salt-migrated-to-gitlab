#!/bin/bash
# exit immediately if a command exits with a nonzero exit status.
set -e
# treat unset variables as an error when substituting.
set -u
# backup {{ site }}
{% set rsync = gpg['rsync'] -%}
duplicity full --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site }}/files
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
echo "{{ site }}.backup.full:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003
PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site }}/files /home/web/repo/files/{{ site }}
echo "{{ site }}.backup.verify:1|c" | nc -w 1 -u {{ django['monitor'] }} 2003
