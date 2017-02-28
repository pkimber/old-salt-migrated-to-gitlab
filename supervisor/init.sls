{% set devpi = pillar.get('devpi', None) %}
{% set django = pillar.get('django', None) %}
{% set dropbox = pillar.get('dropbox', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set sites = pillar.get('sites', {}) %}

{% if django or devpi or dropbox or monitor %}

{% if django or monitor %}
uwsgi:
  supervisord:
    - running
    - restart: True
    - require:
      - pkg: supervisor
{% endif %}

supervisor:
  pkg:
    - installed
  service:
    - running
    - watch:
      {% if chat %}
      - file: /etc/supervisor/conf.d/chat.conf
      {% endif %}
      {% if devpi %}
      - file: /etc/supervisor/conf.d/devpi.conf
      {% endif %}
      {% if django or monitor %}
      - file: /etc/supervisor/conf.d/uwsgi.conf
      {% endif %}
      {% if dropbox %}
      {% for account in dropbox.accounts %}
      - file: /etc/supervisor/conf.d/dropbox_{{ account }}.conf
      {% endfor %}
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

{% if dropbox %}
{% for account in dropbox.accounts %}
/etc/supervisor/conf.d/dropbox_{{ account }}.conf:
  file:
    - managed
    - source: salt://supervisor/dropbox.conf
    - template: jinja
    - context:
      account: {{ account }}
    - require:
      - pkg: supervisor
{% endfor %}
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

{% set profile = settings.get('profile') -%}
{% if profile == 'mattermost' %}
/etc/supervisor/conf.d/chat.conf:
  file:
    - managed
    - source: salt://supervisor/chat.conf
    - template: jinja
    - context:
      site: {{ site }}
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
{% endif %} # ftp
{% endfor %} # site, settings

{% endif %}
