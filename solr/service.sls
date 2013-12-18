{% set solr = pillar.get('solr', None) %}
{% if solr %}

tomcat-service:
  service:
    - running
    - name: tomcat7
    - enable: True
    - require:
      - pkg.installed: tomcat7

{% endif %}
