{% set workflow = pillar.get('workflow', None) %}
{% if workflow %}

{# java and tomcat installed using 'java/init.sls' #}


/usr/share/tomcat7/lib/postgresql-9.4.1212.jre7.jar:
  file.managed:
    - source: salt://workflow/postgresql-9.4.1212.jre7.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7


{% set sites = pillar.get('sites', {}) %}
{% for domain, settings in sites.iteritems() %}

{% set work = settings.get('workflowxyz', {}) -%}

/var/lib/tomcat7/webapps/activiti-app-{{ domain|replace('.', '-') }}.war:
  file.managed:
    - source: salt://workflow/activiti-app.war
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/var/lib/tomcat7/webapps/activiti-rest-{{ domain|replace('.', '-') }}.war:
  file.managed:
    - source: salt://workflow/activiti-rest.war
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/var/lib/tomcat7/webapps/activiti-app-{{ domain|replace('.', '-') }}/WEB-INF/classes/META-INF/activiti-app/activiti-app.properties:
  file.managed:
    - source: salt://workflow/activiti-app.properties
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - template: jinja
    - context:
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - pkg: tomcat7

/var/lib/tomcat7/webapps/activiti-rest-{{ domain|replace('.', '-') }}/WEB-INF/classes/db.properties:
  file.managed:
    - source: salt://workflow/db.properties
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - template: jinja
    - context:
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - pkg: tomcat7

{% endfor %}

{% endif %}
