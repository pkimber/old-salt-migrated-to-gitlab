{% set django = pillar.get('django', None) %}
{% set solr = pillar.get('solr', None) %}
{% if django %}

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
{% set cron = settings.get('cron', {}) -%}

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

{# create cron.d file even if it is empty... #}
{# or we won't be able to remove items from it #}
/etc/cron.d/{{ site }}:
  file:
    - managed
    - source: salt://web/cron_for_site
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      cron: {{ cron }}
      site: {{ site }}
      solr: {{ solr }}

{% endfor %}

{% endif %}
