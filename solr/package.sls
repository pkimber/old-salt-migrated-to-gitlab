{% set solr = pillar.get('solr', None) %}
{% if solr %}

libxslt1-dev:
  pkg.installed

{#
Note: PJK, 25/11/2016, 'tomcat7' is installed using 'java/init.sls'
tomcat7:
  pkg.installed
#}

{% endif %}
