{% set devpi = pillar.get('devpi', {}) %}
{% set php = pillar.get('php', {}) %}
{% set sites = pillar.get('sites', {}) %}
{% set users = pillar.get('users', {}) %}

{# Only set-up web user if we have a site or a service (devpi) #}
{% if sites|length or devpi|length or php|length %}

web-group:
  group.present:
    - name: web
    - gid: 7500
    - system: True

web:
  user.present:
    - fullname: Web App
    - uid: 7500
    - gid_from_name: True
    - shell: /bin/bash
    - require:
      - group: web-group

{% if users|length %}
web-ssh-key:
  ssh_auth:
    - present
    - user: web
    - require:
      - user: web
    - names:
      {% for user, settings in users.iteritems() %}
      {% set keys = settings.get('keys') %}
      {% for key in keys %}
      - {{ key }}
      {% endfor %}
      {% endfor %}
{% endif %}

/home/web/.pip:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - user: web

/home/web/repo/temp/backup-vim:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - user: web

/home/web/.bashrc:
  file:
    - managed
    - source: salt://default/.bashrc
    - user: web
    - group: web
    - require:
      - user: web

/home/web/.inputrc:
  file:
    - managed
    - source: salt://default/.inputrc
    - user: web
    - group: web
    - require:
      - user: web

/home/web/.pip/pip.conf:
  file:
    - managed
    - source: salt://default/pip.conf
    - user: web
    - group: web
    - template: jinja
    - require:
      - user: web

/home/web/.vimrc:
  file:
    - managed
    - source: salt://default/.vimrc
    - user: web
    - group: web
    - require:
      - user: web

{% endif %}
