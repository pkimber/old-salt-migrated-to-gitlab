{% set solr = pillar.get('solr', {}) %}
{% if solr|length %}

libxslt1-dev:
  pkg.installed

tomcat7:
  pkg.installed

{% endif %}
