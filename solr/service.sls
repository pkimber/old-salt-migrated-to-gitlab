{% set solr = pillar.get('solr', {}) %}
{% if solr|length %}

tomcat-service:
  service:
    - running
    - name: tomcat7
    - enable: True
    - require:
      - pkg.installed: tomcat7

{% endif %}
