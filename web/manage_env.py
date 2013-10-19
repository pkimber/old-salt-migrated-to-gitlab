#!/usr/bin/env python

"""
Copied from:
https://github.com/jacobian/django-dotenv
"""
import os
import sys


class MyError(Exception):

    def __init__(self, value):
        Exception.__init__(self)
        self.value = value

    def __str__(self):
        return repr('%s, %s' % (self.__class__.__name__, self.value))


def read_dotenv(dotenv):
    """
    Read a .env file into os.environ.
    """
    for k, v in parse_dotenv(dotenv):
        os.environ.setdefault(k, v)
    for path in parse_dotenv_for_path(dotenv):
        sys.path.insert(0, path)


def parse_dotenv(dotenv):
    """
    A sample uWSGI vassal ini file looks like this:

    [uwsgi]
    chdir = /home/web/repo/project/my/web/live/
    env = DB_PASS=ourDatabasePassword
    env = DJANGO_SETTINGS_MODULE=settings.production
    env = DOMAIN=westcountrycycles.co.uk
    env = MEDIA_ROOT=/home/web/repo/files/my/web/
    logto = /home/web/repo/uwsgi/log/my_web.log
    master = true
    module = project.wsgi
    pythonpath = /home/web/repo/project/my/web/live/
    """
    for line in open(dotenv):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if not line.startswith('env'):
            continue
        # remove 'env' from the start of the line
        ignore, line = line.split('env', 1)
        # remove the first '=' from the start of the line
        ignore, line = line.split('=', 1)
        line = line.strip()
        k, v = line.split('=', 1)
        v = v.strip("'").strip('"')
        yield k, v


def parse_dotenv_for_path(dotenv):
    """
    A sample uWSGI vassal ini file looks like this:

    [uwsgi]
    chdir = /home/web/repo/project/my/web/live/
    env = DB_PASS=ourDatabasePassword
    env = DJANGO_SETTINGS_MODULE=settings.production
    env = DOMAIN=westcountrycycles.co.uk
    env = MEDIA_ROOT=/home/web/repo/files/my/web/
    logto = /home/web/repo/uwsgi/log/my_web.log
    master = true
    module = project.wsgi
    pythonpath = /home/web/repo/project/my/web/live/
    """
    for line in open(dotenv):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if not line.startswith('pythonpath'):
            continue
        k, v = line.split('=', 1)
        v = v.strip("'").strip('"')
        yield v.strip()


def update_env_from_vassal(file_name):
    if not os.path.exists(file_name):
        raise MyError("uWSGI vassal file does not exist: {}".format(file_name))
    read_dotenv(file_name)


if __name__ == "__main__":

    update_env_from_vassal(sys.argv.pop(1))

    from django.core.management import execute_from_command_line

    # remove the current path (script folder) from 'PYTHONPATH'
    sys.path.remove(os.path.dirname(os.path.realpath(__file__)))

    execute_from_command_line(sys.argv)
