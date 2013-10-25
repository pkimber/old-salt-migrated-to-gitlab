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

  /etc/vsftpd.conf:
    file.managed:
      - source: salt://ftp/vsftpd.conf
      - user: root
      - group: root
      - mode: 644
      - require:
        - pkg.installed: vsftpd

  /etc/vsftpd.userlist:
    file:
      - managed
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
      - recurse:
        - user
        - group
      - require:
        - file.directory: /home/web/repo
{% endif %}

{% for site, settings in sites.iteritems() %}
{% if settings.get('ftp', None) %}
{# for ftp uploads #}
  /home/web/repo/ftp/{{ site }}:
    file.directory:
      - user: web
      - group: web
      - mode: 755
      - recurse:
        - user
        - group
      - require:
        - file.directory: /home/web/repo/ftp

  ftp_user_{{ site }}:
    user.present:
      - name: {{ site }}:
      - password: {{ settings.get('ftp_password') }}
      - shell: /bin/bash
      - require:
        - group: web-group

{% endif %}
{% endfor %}
