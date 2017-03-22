{% set alfresco = pillar.get('alfresco', False) %}
{% set gpg = pillar.get('gpg', False) %}
{% set sites = pillar.get('sites', {}) %}

{% if alfresco %}

{% for domain, settings in sites.iteritems() %}
/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties:
  file.managed:
    - source: salt://alfresco/alfresco-global.properties
    - user: root
    - group: root
    - template: jinja
    - context:
      settings: {{ settings }}
    - require:
      - file: /opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties

{% if gpg %}
/home/web/opt/alfresco-bart.sh:
  file:
    - managed
    - source: salt://alfresco/alfresco-bart.sh
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/opt
      - user: web

/home/web/opt/alfresco-bart.properties:
  file:
    - managed
    - source: salt://alfresco/alfresco-bart.properties
    - user: web
    - group: web
    - mode: 444
    - template: jinja
    - makedirs: True
    - context:
      gpg: {{ gpg }}
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - file: /home/web/opt
      - user: web
{% endif %} # gpg
{% endfor %} # domain, settings

{% endif %}
