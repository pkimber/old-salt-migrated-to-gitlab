{% set devpi = pillar.get('devpi', None) %}
{% set django = pillar.get('django', None) %}

{% if django or devpi %}
uwsgi:
  supervisord:
    - running
    - restart: False
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
{% endif %}
