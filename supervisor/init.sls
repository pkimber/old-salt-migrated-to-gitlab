{% set devpi = pillar.get('devpi', None) %}
{% set django = pillar.get('django', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set sites = pillar.get('sites', {}) %}

{% if django or devpi or monitor %}
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
      {% if django or monitor %}
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

{% if monitor %}
/etc/supervisor/conf.d/carbon.conf:
  file:
    - managed
    - source: salt://supervisor/carbon.conf
    - template: jinja
    - require:
      - pkg: supervisor
{% endif %}

{% if django or monitor %}

/etc/supervisor/conf.d/uwsgi.conf:          # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://supervisor/uwsgi.conf  # function arg
    - require:                              # requisite declaration
      - pkg: supervisor                     # requisite reference

{% if django %}

/etc/supervisor/conf.d/statsd.conf:
  file:
    - managed
    - source: salt://supervisor/statsd.conf
    - require:
      - pkg: supervisor

{% set postgres_settings = pillar.get('postgres_settings') -%}
{% endif %}

{% for site, settings in sites.iteritems() %}
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
