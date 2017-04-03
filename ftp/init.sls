{% set sites = pillar.get('sites', {}) %}

{# Do any of the sites on this server have FTP #}
{# nasty workaround from #}
{# http://stackoverflow.com/questions/9486393/jinja2-change-the-value-of-a-variable-inside-a-loop #}
{% set vars = {'has_ftp': False} %}
{% for site, settings in sites.iteritems() %}
  {% if settings.get('ftp', None) %}
    {% if vars.update({'has_ftp': True}) %} {% endif %}
  {% endif %}
{% endfor %}
{% set has_ftp = vars.has_ftp %}

{# Only set-up ftp if we have a site using ftp #}
{% if has_ftp %}
  vsftpd:
    pkg:
      - installed
    service:
      - running
      - watch:
         - file: /etc/vsftpd.conf
         - file: /etc/vsftpd.userlist

  /etc/vsftpd.conf:
    file.managed:
      - source: salt://ftp/vsftpd.conf
      - user: root
      - group: root
      - mode: 644
      - require:
        - pkg: vsftpd

  /etc/vsftpd.userlist:
    file.managed:
      - source: salt://ftp/vsftpd.userlist
      - template: jinja
      - context:
        sites: {{ sites }}
      - require:
        - pkg: vsftpd

  /home/web/repo/ftp:
    file.directory:
      - user: web
      - group: web
      - mode: 755
      - require:
        - file: /home/web/repo
{% endif %}

{% for domain, settings in sites.iteritems() %}
{% if settings.get('ftp', None) %}
{% set env = settings.get('env', {}) -%}
{# for ftp uploads #}
  /home/web/repo/ftp/{{ domain|replace('.', '_') }}:
    file.directory:
      - user: web
      - group: web
      - mode: 755
      - require:
        - file: /home/web/repo/ftp

  ftp_group_{{ domain|replace('.', '_') }}:
    group.present:
      - name: {{ domain|replace('.', '_') }}
      - gid: {{ env['ftp_user_id'] }}
      - system: True

  ftp_user_{{ domain|replace('.', '_') }}:
    user.present:
      - name: {{ domain|replace('.', '_') }}
      - uid: {{ env['ftp_user_id'] }}
      - gid_from_name: True
      - password: {{ env['ftp_password'] }}
      - shell: /bin/bash
      - require:
        - group: ftp_group_{{ domain|replace('.', '_') }}

  {# folder for ftp upload #}
  /home/{{ domain|replace('.', '_') }}/site:
    file.directory:
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - require:
        - user: {{ domain|replace('.', '_') }}
      - mode: 755

  /home/{{ domain|replace('.', '_') }}/site/static:
    file.directory:
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - require:
        - file: /home/{{ domain|replace('.', '_') }}/site
      - mode: 755

  /home/{{ domain|replace('.', '_') }}/site/templates:
    file.directory:
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - require:
        - file: /home/{{ domain|replace('.', '_') }}/site
      - mode: 755

  /home/{{ domain|replace('.', '_') }}/site/templates/templatepages:
    file.directory:
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - require:
        - file: /home/{{ domain|replace('.', '_') }}/site/templates
      - mode: 755

  {# symlink uploads to site folder #}
  /home/web/repo/ftp/{{ domain|replace('.', '_') }}/site:
    file.symlink:
      - target: /home/{{ domain|replace('.', '_') }}/site
      - require:
        - file: /home/web/repo/ftp/{{ domain|replace('.', '_') }}
        - file: /home/{{ domain|replace('.', '_') }}/site

  /home/{{ domain|replace('.', '_') }}/opt:
    file.directory:
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - mode: 755
      - makedirs: False

  /home/{{ domain|replace('.', '_') }}/opt/venv_watch_ftp_folder:
    virtualenv.manage:
      - index_url: https://pypi.python.org/simple/
      - requirements: salt://ftp/requirements.txt
      - user: {{ domain|replace('.', '_') }}
      - venv_bin: /usr/bin/pyvenv-3.5
      - require:
        - pkg: python3-venv
        - pkg: python3-virtualenv

  {# watch files created in the site folder and set correct mode #}
  /home/{{ domain|replace('.', '_') }}/opt/watch_ftp_folder.py:
    file.managed:
      - source: salt://ftp/watch_ftp_folder.py
      - context:
        settings: {{ settings }}
      - template: jinja
      - user: {{ domain|replace('.', '_') }}
      - group: web
      - mode: 755
      - makedirs: False

{% endif %}
{% endfor %}
