{% set workflow = pillar.get('workflow', None) %}
{% if workflow %}

{# java and tomcat installed using 'java/init.sls' #}

/var/lib/tomcat7/webapps/activiti-app.war:
  file.managed:
    - source: salt://workflow/activiti-app.war
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/var/lib/tomcat7/webapps/activiti-rest.war:
  file.managed:
    - source: salt://workflow/activiti-rest.war
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

{% endif %}
