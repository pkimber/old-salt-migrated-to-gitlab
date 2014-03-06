{# Only set-up uwsgi if we are using Django #}
{% set django = pillar.get('django', None) %}

{% if django %}

{% set postgres_settings = pillar.get('postgres_settings') -%}
{% set python_version = django.get('python_version') -%}
{% set sites = pillar.get('sites', {}) %}

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

{% endfor %}

/home/web/repo/uwsgi/venv_uwsgi:
  virtualenv.manage:
    - no_site_packages: True
    {% if python_version == 2 %}
    - requirements: salt://uwsgi/requirements2.txt   # install uwsgi into the virtualenv
    {% elif python_version == 3 %}
    - requirements: salt://uwsgi/requirements3.txt   # install uwsgi into the virtualenv
    - python: /usr/bin/python3
    {% else %}
    python_version must be 2 or 3
    {% endif %}
    - require:                              # requisite declaration
      - pkg: python-virtualenv              # requisite reference
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - recurse:
      - user
      - group
    - require:
      - file: /home/web/repo/uwsgi

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

{% endif %}
