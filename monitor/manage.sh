#!/bin/bash

# Set up the environment variables by reading the uWSGI vassal file so we can
# run a modified version of the Django 'manage.py' command

# exit immediately if a command exits with a nonzero exit status.
set -e

cd /opt/graphite/webapp/graphite/
source /opt/graphite/venv_graphite/bin/activate
/opt/graphite/venv_graphite/bin/python /home/web/opt/manage_env.py /home/web/repo/uwsgi/vassals/graphite.ini $*
deactivate
