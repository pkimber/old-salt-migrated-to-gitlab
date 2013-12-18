{% set django = pillar.get('django', {}) %}
{% if django|length %}

{% set sites = pillar.get('sites', {}) %}

/home/web/opt:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - recurse:
      - user
      - group
    - require:
      - user: web

/home/web/opt/manage_env.py:
  file:
    - managed
    - source: salt://web/manage_env.py
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file.directory: /home/web/opt
      - user: web


{% for site, settings in sites.iteritems() %}

/home/web/opt/{{ site }}.sh:
  file:
    - managed
    - source: salt://web/manage.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      site: {{ site }}
    - require:
      - file.directory: /home/web/opt
      - user: web

/etc/cron.d/{{ site }}_update_index:
  file:
    - managed
    - source: salt://web/cron_update_index
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      site: {{ site }}

{% endfor %}

{% endif %}
