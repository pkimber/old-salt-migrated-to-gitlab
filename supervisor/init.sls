{% set devpi = pillar.get('devpi', None) %}
{% set django = pillar.get('django', None) %}
{% set sites = pillar.get('sites', {}) %}

{% if django or devpi %}
uwsgi:
  supervisord:
    - running
    - restart: True
    - require:
      - pkg: supervisor

supervisor:
  pkg:
    - installed
  service:
    - running
    - watch:
      {% if devpi %}
      - file: /etc/supervisor/conf.d/devpi.conf
      {% endif %}
      {% if django %}
      - file: /etc/supervisor/conf.d/uwsgi.conf
      {% endif %}
{% endif %}


{% if devpi %}
/etc/supervisor/conf.d/devpi.conf:
  file:
    - managed
    - source: salt://supervisor/devpi.conf
    - template: jinja
    - context:
      devpi: {{ devpi }}
    - require:
      - pkg: supervisor
{% endif %}


{% if django %}

/etc/supervisor/conf.d/uwsgi.conf:          # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://supervisor/uwsgi.conf  # function arg
    - require:                              # requisite declaration
      - pkg: supervisor                     # requisite reference

{% set postgres_settings = pillar.get('postgres_settings') -%}

{% for site, settings in sites.iteritems() %}

{% if settings.get('celery', None) %}
/etc/supervisor/conf.d/{{ site }}_celery_worker.conf:
  file:
    - managed
    - source: salt://supervisor/celery_worker.conf
    - template: jinja
    - context:
      site: {{ site }}
    - require:
      - pkg: supervisor

/home/web/repo/script/{{ site }}_celery_worker.sh:
  file:
    - managed
    - source: salt://supervisor/celery_worker.sh
    - user: web
    - group: web
    - template: jinja
    - context:
      site: {{ site }}
      postgres_settings: {{ postgres_settings }}
      settings: {{ settings }}
    - require:
      - pkg: supervisor
{% endif %}

{% if settings.get('ftp', None) %}
/etc/supervisor/conf.d/{{ site }}_watch_ftp_folder.conf:
  file:
    - managed
    - source: salt://supervisor/watch_ftp_folder.conf
    - template: jinja
    - context:
      site: {{ site }}
    - require:
      - pkg: supervisor
{% endif %}
{% endfor %}
{% endif %}
