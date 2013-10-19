#!/bin/bash

# Set up the environment variables by reading the uWSGI vassal file so we can
# run a modified version of the Django 'manage.py' command

# exit immediately if a command exits with a nonzero exit status.
set -e

cd /home/web/repo/project/{{ site }}/live/
source /home/web/repo/project/{{ site }}/live/venv/bin/activate
/home/web/repo/project/{{ site }}/live/venv/bin/python /home/web/opt/manage_env.py /home/web/repo/uwsgi/vassals/{{ site }}.ini $*
deactivate
