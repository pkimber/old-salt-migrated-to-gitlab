{% set django = pillar.get('django', None) %}
{% set dropbox = pillar.get('dropbox', None) %}
{% set gpg = pillar.get('gpg', False) %}
{% set monitor = pillar.get('monitor', None) %}
{% set solr = pillar.get('solr', None) %}
{% set testing = pillar.get('testing', False) -%}

{% if django or dropbox or monitor %}

{% set sites = pillar.get('sites', {}) %}

/home/web/opt:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - user: web

/home/web/opt/manage_env.py:
  file:
    - managed
    - source: salt://web/manage_env.py
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/opt
      - user: web


{% for site, settings in sites.iteritems() %}
{% set cron = settings.get('cron', {}) -%}
{% set test = settings.get('test', {}) -%}

{% set site_name = site %}
{% if testing and test %}
{% set site_name = site_name + '_test' %}
{% endif %}

{% if not testing or testing and test -%}
/home/web/opt/{{ site_name }}.sh:
  file:
    - managed
    - source: salt://web/manage.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      site: {{ site }}
    - require:
      - file: /home/web/opt
      - user: web

{% if gpg %}
/home/web/opt/backup_{{ site }}.sh:
  file:
    - managed
    - source: salt://web/backup.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      gpg: {{ gpg }}
      django: {{ django }}
      dropbox: {{ dropbox }}
      site: {{ site }}
      site_name: {{ site_name }}
    - require:
      - file: /home/web/opt
      - user: web
{% endif %} # gpg

{# create cron.d file even if it is empty... #}
{# or we won't be able to remove items from it #}
/etc/cron.d/{{ site }}:
  file:
    - managed
    - source: salt://web/cron_for_site
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      cron: {{ cron }}
      gpg: {{ gpg }}
      site: {{ site }}

{% endif %} # not testing or testing and test
{% endfor %} # site, settings


{% if dropbox %}
{% set empty_dict = {} %}

{% for account in dropbox.accounts %}
/home/web/opt/dropbox-init-{{ account }}.sh:
  file:
    - managed
    - source: salt://web/dropbox-init.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - context:
      account: {{ account }}
    - require:
      - file: /home/web/opt
      - user: web
{% endfor %}

/home/web/opt/backup_dropbox.sh:
  file:
    - managed
    - source: salt://web/backup.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      django: {{ empty_dict }}
      dropbox: {{ dropbox }}
      gpg: {{ gpg }}
      site: dropbox
      site_name: dropbox
    - require:
      - file: /home/web/opt
      - user: web

/etc/cron.d/dropbox:
  file:
    - managed
    - source: salt://web/cron_for_site
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      cron: {{ empty_dict }}
      gpg: {{ gpg }}
      site: dropbox
{% endif %} # dropbox


{% if gpg %}

{# TODO Don't create these files if they have already been imported #}

/home/web/repo/temp/pub.gpg:
  file:
    - managed
    - user: web
    - group: web
    - mode: 755
    - contents_pillar: gpg:rsync:public

/home/web/repo/temp/sec.gpg:
  file:
    - managed
    - user: web
    - group: web
    - mode: 755
    - contents_pillar: gpg:rsync:secret

{% endif %} # gpg

{% endif %} # django or monitor
