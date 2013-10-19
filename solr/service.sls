{% set sites = pillar.get('sites', {}) %}


{% if sites|length %}

tomcat-service:
  service:
    - running
    - name: tomcat7
    - enable: True
    - require:
      - pkg.installed: tomcat7

{% endif %}
