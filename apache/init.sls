{% set apache = pillar.get('apache', None) %}
{% if apache %}

{# copied from https://github.com/saltstack-formulas/apache-formula #}

apache:
  pkg:
    - installed
    - name: apache2
  service:
    - running
    - name: apache2
    - enable: True

{% endif %}
