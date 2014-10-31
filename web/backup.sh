#!/bin/bash
# exit immediately if a command exits with a nonzero exit status.
set -e
# treat unset variables as an error when substituting.
set -u
# backup {{ site }}
{% set rsync = gpg['rsync'] -%}
duplicity full --encrypt-key="{{ rsync['key'] }}" /home/web/repo/files/{{ site }} scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site }}/files
PASSPHRASE="{{ rsync['pass'] }}" duplicity verify scp://{{ rsync['user'] }}@{{ rsync['server'] }}/{{ site }}/files /home/web/repo/files/{{ site }}
