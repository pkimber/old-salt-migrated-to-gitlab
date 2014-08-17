# monitor client - if using a django web app - install statsd
{% set django = pillar.get('django', None) %}
{% if django %}

nodejs:
  pkg.installed

# not sure we need this package
#npm:
#  pkg.installed:
#    - require:
#      - pkg: nodejs

git://github.com/etsy/statsd.git:
  git.latest:
    - target: /opt/statsd
    - rev: v0.7.1
    - ranas: web
    - unless: test -d /opt/statsd

/opt/statsd/localConfig.js:
  file.managed:
    - source: salt://monitor/localConfig.js
    - template: jinja
    - context:
      django: {{ django }}
    - require:
      - git: git://github.com/etsy/statsd.git

{% endif %}


# monitor server
{% set monitor = pillar.get('monitor', None) %}
{% if monitor %}

/opt/graphite:
  file.directory:
    - user: web
    - group: web
    - makedirs: True
    - require:
      - user: web

/opt/graphite/conf/carbon.conf:
  file:
    - managed
    - source: salt://monitor/carbon.conf
    - user: web
    - group: web
    - require:
      - user: web

/opt/graphite/conf/storage-aggregation.conf:
  file:
    - managed
    - source: salt://monitor/storage-aggregation.conf
    - user: web
    - group: web
    - require:
      - user: web

/opt/graphite/conf/storage-schemas.conf:
  file:
    - managed
    - source: salt://monitor/storage-schemas.conf
    - user: web
    - group: web
    - require:
      - user: web

/opt/graphite/webapp/graphite/local_settings.py:
  file:
    - managed
    - source: salt://monitor/local_settings.py
    - user: web
    - group: web
    - require:
      - user: web

/opt/graphite/webapp/graphite/wsgi.py:
  file:
    - managed
    - source: salt://monitor/graphite.wsgi
    - user: web
    - group: web
    - require:
      - user: web

/opt/graphite/venv_graphite:
  virtualenv.manage:
    - system_site_packages: False
    - requirements: salt://monitor/requirements.txt
    - user: web
    - require:
      - pkg: python-virtualenv

# cairo in a virtual environment (not)
# http://blog.mapado.com/graphite-virtualenv-apache-symfony/
python-cairo:
  pkg.installed

/opt/graphite/venv_graphite/lib/python2.7/site-packages/cairo:
  file.symlink:
    - target: /usr/lib/python2.7/dist-packages/cairo

/home/web/repo/uwsgi/vassals/graphite.ini:
  file:
    - managed
    - source: salt://monitor/vassal.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      monitor: {{ monitor }}
    - require:
      - file: /home/web/repo/uwsgi/vassals

/home/web/opt/graphite.sh:
  file:
    - managed
    - source: salt://monitor/manage.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      monitor: {{ monitor }}
    - require:
      - file: /home/web/opt
      - user: web

{% endif %}
