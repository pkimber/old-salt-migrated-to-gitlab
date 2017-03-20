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

{# The Mattermost System Console writes to this file, so don't overwrite #}
/home/web/repo/project/{{ domain }}/live/config/config.json.getting-started:
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
