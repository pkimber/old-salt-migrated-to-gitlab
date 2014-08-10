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
