{# get user data from the pillar #}
{% set users = pillar.get('users', {}) %}

{# Only set-up the script if we have a user #}
{% if users|length %}

{% for user, settings in users.iteritems() %}

{% set is_sudo = settings.get('sudo', None) %}
{% set keys = settings.get('keys') %}

{{ user }}-group:
  group.present:
    - gid: {{ settings.get('uid') }}
    - name: {{ user }}

{{ user }}:
  user.present:
    - fullname: {{ settings.get('fullname') }}
    - uid: {{ settings.get('uid') }}
    - gid_from_name: True
    - groups:
      - {{ user }}
      {% if is_sudo %}
      - sudo
      {% endif %}
      - users
    - password: {{ settings.get('password') }}
    - enforce_password: True
    - shell: /bin/bash
    - require:
      - group: {{ user }}-group

{{ user }}-ssh-key:
  ssh_auth:
    - present
    - user: {{ user }}
    - require:
      - user: {{ user }}
    - names:
      {% for key in keys %}
      - {{ key }}
      {% endfor %}

/home/{{ user }}/repo/temp/backup-vim:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}
    - mode: 755
    - makedirs: True

/home/{{ user }}/.bashrc:
  file:
    - managed
    - source: salt://default/.bashrc
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}

/home/{{ user }}/.inputrc:
  file:
    - managed
    - source: salt://default/.inputrc
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}

/home/{{ user }}/.vimrc:
  file:
    - managed
    - source: salt://default/.vimrc
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}

{% endfor %}
{% endif %}

{# root user #}
/root/repo/temp/backup-vim:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/root/.bashrc:
  file:
    - managed
    - source: salt://default/.bashrc
    - user: root
    - group: root

/root/.inputrc:
  file:
    - managed
    - source: salt://default/.inputrc
    - user: root
    - group: root

/root/.vimrc:
  file:
    - managed
    - source: salt://default/.vimrc
    - user: root
    - group: root
