{# Only set-up uwsgi if we are using Django (including Graphite) #}
{% set django = pillar.get('django', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set sites = pillar.get('sites', {}) %}

{% if django or monitor %}

{% if django %}
{% set postgres_settings = pillar.get('postgres_settings') -%}
{% endif %}

/home/web/repo/uwsgi:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file: /home/web/repo

/home/web/repo/uwsgi/log:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file: /home/web/repo/uwsgi

/home/web/repo/uwsgi/vassals:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file: /home/web/repo/uwsgi

{% for site, settings in sites.iteritems() %}
/home/web/repo/uwsgi/vassals/{{ site }}.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      site: {{ site }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals

{% if settings.get('celery', None) %}
/home/web/repo/uwsgi/vassals/{{ site }}_celery_beat.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal_celery_beat.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      site: {{ site }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals

/home/web/repo/uwsgi/vassals/{{ site }}_celery_worker.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal_celery_worker.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      site: {{ site }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals
{% endif %}
{% endfor %}

/home/web/repo/uwsgi/venv_uwsgi:
  virtualenv.manage:
    - system_site_packages: False
    {% if django %}
    - python: /usr/bin/python3
    {% if monitor %}
    django uses python 3, graphite uses python 2.  I cannot get them working together.
    {% endif %}
    {% endif %}
    - user: web
    - require:                              # requisite declaration
      - pkg: python-virtualenv              # requisite reference

/home/web/opt/runinenv.sh:                  # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://uwsgi/runinenv.sh      # function arg
    - user: web
    - group: web
    - require:                              # requisite declaration
      - pkg: python-virtualenv              # requisite reference
    - require:
      - file: /home/web/opt
      - user: web

uwsgi_build:
  git:
    - name: git://github.com:unbit/uwsgi.git
    - target: /opt/uwsgi
    - rev: 2.0.6
    - unless: test -d /opt/uwsgi
  cmd:
    - wait
    - name: python3 uwsgiconfig.py --build core && python3 uwsgiconfig.py --plugin plugins/stats_pusher_statsd core
    - cwd: /opt/uwsgi
    - stateful: false
    - watch:
      - git: uwsgi_build
    - unless: test -d /opt/uwsgi

{% endif %}
