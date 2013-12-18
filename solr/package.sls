{% set solr = pillar.get('solr', None) %}
{% if solr %}

libxslt1-dev:
  pkg.installed

tomcat7:
  pkg.installed

{% endif %}
