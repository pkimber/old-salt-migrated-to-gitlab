{% set mysql_server = pillar.get('mysql_server', {}) -%}
{% if mysql_server %}
php5:
  pkg:
    - installed
{% endif %}
