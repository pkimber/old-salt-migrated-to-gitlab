{% set workflow = pillar.get('workflow', None) %}
{% if workflow %}

tomcat8:
  pkg.installed

{% endif %}
