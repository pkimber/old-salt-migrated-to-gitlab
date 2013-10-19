{% set sites = pillar.get('sites', {}) %}


{% if sites|length %}

libxslt1-dev:
  pkg.installed

tomcat7:
  pkg.installed

{% endif %}
