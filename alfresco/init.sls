{% set alfresco = pillar.get('alfresco', False) %}
{% if alfresco %}

/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties:
  file.managed:
    - source: salt://alfresco/alfresco-global.properties
    - user: root
    - group: root

{% endif %}
