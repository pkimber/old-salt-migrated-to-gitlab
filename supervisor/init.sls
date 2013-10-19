{% set devpi = pillar.get('devpi', {}) %}

{% set sites = pillar.get('sites', {}) %}


{% if sites|length or devpi|length %}

uwsgi:
  supervisord:
    - running
    - restart: True                         # Not sure we want to restart every time, but 'False' raises an error.
    - require:
      - pkg: supervisor

supervisor:                                 # ID declaration
  pkg:                                      # state declaration
    - installed                             # function declaration
  service:
    - running
    - watch:
      {% if devpi|length %}
      - file: /etc/supervisor/conf.d/devpi.conf
      {% endif %}
      {% if sites|length %}
      - file: /etc/supervisor/conf.d/uwsgi.conf
      {% endif %}

{% endif %}


{% if devpi|length %}

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


{% if sites|length %}

/etc/supervisor/conf.d/uwsgi.conf:          # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://supervisor/uwsgi.conf  # function arg
    - require:                              # requisite declaration
      - pkg: supervisor                     # requisite reference

{% endif %}
