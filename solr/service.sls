{% set solr = pillar.get('solr', None) %}
{% if solr %}

tomcat-service:
  service:
    - running
    - name: tomcat7
    - enable: True
    - require:
      - pkg: tomcat7

{% endif %}
