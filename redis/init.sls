{% set redis = pillar.get('redis', None) %}
{% if redis %}

redis-server:
  pkg.installed

{% endif %}
