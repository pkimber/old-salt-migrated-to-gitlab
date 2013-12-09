{% set mysql_server = pillar.get('mysql_server', {}) -%}
{% if mysql_server %}

mysqld:
  pkg:
    - installed
    - name: mysql-server
  service:
    - running
    - name: mysql
    - enable: True
    - watch:
      - pkg: mysqld

{% endif %}


{% set postgres_server = pillar.get('postgres_server', {}) -%}
{% if postgres_server %}

{% set postgres_settings = pillar.get('postgres_settings', {}) %}

postgresql:
  pkg:
    - installed
  service:
    - running
    - watch:
      - file: /etc/postgresql/9.1/main/postgresql.conf
      - file: /etc/postgresql/9.1/main/pg_hba.conf

/etc/postgresql/9.1/main/pg_hba.conf:
  file:
    - managed                               # function
    - source: salt://db/pg_hba.conf         # function arg
    - user: postgres
    - group: postgres
    - mode: 644
    - template: jinja
    - context:
      postgres_server: {{ postgres_server }}
    - require:
      - pkg: postgresql

/etc/postgresql/9.1/main/postgresql.conf:
  file:
    - managed                               # function
    - source: salt://db/postgresql.conf     # function arg
    - user: postgres
    - group: postgres
    - mode: 644
    - template: jinja
    - context:
      postgres_settings: {{ postgres_settings }}
    - require:
      - pkg: postgresql

{% set block_storage_folder = postgres_server.get('block_storage_folder', None) %}
{% if block_storage_folder %}
# data on Rackspace cloud block storage
{{ block_storage_folder }}:
  file.directory:
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: True
{% endif %}

{% endif %}
