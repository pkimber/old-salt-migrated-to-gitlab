{% set chat = pillar.get('chat', False) %}
{% if chat %}

{% set sites = pillar.get('sites', {}) %}
{% for domain, settings in sites.iteritems() %}

/home/web/repo/project/{{ domain }}/live/config:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/project/{{ domain }}

/home/web/repo/project/{{ domain }}/live/config/config.json:
  file:
    - managed
    - source: salt://chat/config.json
    - user: web
    - group: web
    - template: jinja
    - context:
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - file: /home/web/repo/project/{{ domain }}/live/config

{% endfor %} # domain, settings

{% endif %}
