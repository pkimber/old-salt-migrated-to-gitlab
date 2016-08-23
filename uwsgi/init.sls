{# Only set-up uwsgi if we are using Django (including Graphite) #}
{% set django = pillar.get('django', None) %}
{% set monitor = pillar.get('monitor', False) %}
{% set opbeat = pillar.get('opbeat', {}) %}
{% set sites = pillar.get('sites', {}) %}

{% if django or monitor %}

{% if django %}
{% set postgres_settings = pillar.get('postgres_settings') -%}
{% endif %} # django

uwsgi-core:
  pkg.installed

uwsgi-plugin-python3:
  pkg.installed

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

{% for domain, settings in sites.iteritems() %}

/home/web/repo/uwsgi/vassals/{{ domain }}.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      domain: {{ domain }}
      opbeat: {{ opbeat }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals

{% if settings.get('celery', None) %}
/home/web/repo/uwsgi/vassals/{{ domain }}.celery.beat.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal_celery_beat.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      domain: {{ domain }}
      opbeat: {{ opbeat }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals

/home/web/repo/uwsgi/vassals/{{ domain }}.celery.worker.ini:
  file:
    - managed
    - source: salt://uwsgi/vassal_celery_worker.ini
    - user: web
    - group: web
    - template: jinja
    - context:
      domain: {{ domain }}
      opbeat: {{ opbeat }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/uwsgi/vassals
{% endif %} # celery
{% endfor %} # domain, settings

#/home/web/repo/uwsgi/venv_uwsgi:
#  virtualenv.manage:
#    - system_site_packages: False
#    {# if django #}
#    - python: /usr/bin/python3
#    {# if monitor #}
#    django uses python 3, graphite uses python 2.  I cannot get them working together.
#    {# endif #}
#    {# endif #}
#    - user: web
#    - require:                              # requisite declaration
#      - pkg: python-virtualenv              # requisite reference
#
#/home/web/opt/runinenv.sh:                  # ID declaration
#  file:                                     # state declaration
#    - managed                               # function
#    - source: salt://uwsgi/runinenv.sh      # function arg
#    - user: web
#    - group: web
#    - require:                              # requisite declaration
#      - pkg: python-virtualenv              # requisite reference
#    - require:
#      - file: /home/web/opt
#      - user: web

#git://github.com/unbit/uwsgi.git:
#  git.latest:
#    - target: /opt/uwsgi
#    - rev: 2.0.6
#    - ranas: web
#    - unless: test -d /opt/uwsgi

#salt://uwsgi/uwsgi-build.sh:
#  cmd.wait_script:
#    - cwd: /opt/uwsgi
#    - watch:
#      - git: git://github.com/unbit/uwsgi.git

#/home/web/repo/uwsgi/venv_uwsgi/bin/uwsgi:
#  file.symlink:
#    - target: /opt/uwsgi/uwsgi
#    - require:
#      - virtualenv: /home/web/repo/uwsgi/venv_uwsgi
#
#/home/web/repo/uwsgi/venv_uwsgi/bin/python_plugin.so:
#  file.symlink:
#    - target: /opt/uwsgi/python_plugin.so
#    - require:
#      - virtualenv: /home/web/repo/uwsgi/venv_uwsgi

{% endif %} # django or monitor
