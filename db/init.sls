{% set mysql_client = pillar.get('mysql_client', None) %}
{% if mysql_client %}

libmysqlclient-dev:
  pkg.installed

{% endif %} # mysql_client


{% set mysql_server = pillar.get('mysql_server', {}) -%}
{% if mysql_server %}

{% set root_password_hash = mysql_server.get('root_password_hash', {}) -%}

mysql-server:
  pkg:
    - installed
    - pkgs:
      - mysql-server
      - python-mysqldb

mysql-service:
  service:
    - running
    - name: mysql
    - enable: True
    - watch:
      - pkg: mysql-server
{#
 # This sets the password for the root user initially time but fails on each
 # subsequent state.highstate
  mysql_user.present:
    - name: root
    - password_hash: '{{ root_password_hash }}'
    - require: 
      - service: mysql
      - pkg: python-mysqldb
#}
/etc/mysql/my.cnf:
  file.managed:
    - source: salt://db/my.cnf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: mysql-server

{% endif %}

{% set postgres_server = pillar.get('postgres_server', {}) -%}
{% set postgres_settings = pillar.get('postgres_settings', {}) %}
{% set workflow = pillar.get('workflow', False) %}

{% if postgres_server or postgres_settings %}
libpq-dev:
  pkg.installed

postgresql-client-9.5:
  pkg.installed
{% endif %}

{% if postgres_server %}

postgresql:
  pkg:
    - installed
  service:
    - running
    - watch:
      - file: /etc/postgresql/9.5/main/postgresql.conf
      - file: /etc/postgresql/9.5/main/pg_hba.conf

/etc/postgresql/9.5/main/pg_hba.conf:
  file:
    - managed
    - source: salt://db/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - template: jinja
    - context:
      postgres_server: {{ postgres_server }}
      workflow: {{ workflow }}
    - require:
      - pkg: postgresql

/etc/postgresql/9.5/main/postgresql.conf:
  file:
    - managed
    - source: salt://db/postgresql.conf
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
