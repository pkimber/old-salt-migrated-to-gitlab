{% set alfresco = pillar.get('alfresco', False) %}
{% set chat = pillar.get('chat', False) %}
{% set django = pillar.get('django', None) %}
{% set dropbox = pillar.get('dropbox', False) %}
{% set gpg = pillar.get('gpg', False) %}
{% set monitor = pillar.get('monitor', None) %}
{% set solr = pillar.get('solr', None) %}
{% set letsencrypt = pillar.get('letsencrypt', None) %}
{% set devpi = pillar.get('devpi', None) %}
{% set apache = pillar.get('apache', None) %}

{# pass an empty parameter #}
{% set empty_dict = {} %}

{% set users = pillar.get('users', {}) %}

{% if alfresco or chat or devpi or django or dropbox or monitor or apache %}

/etc/cron.d/letsencrypt:
  file:
    - managed
    - source: salt://web/letsencrypt-cron
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/home/web/opt:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - user: web

/home/web/opt/init-letsencrypt:
  file:
    - managed
    - source: salt://web/init-letsencrypt
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/opt
      - user: web

{% if users|length %}
  {% for user in users %}
    {% if user != "web" %}
/home/{{ user }}/bin/init-letsencrypt:
  file.symlink:
    - target: /home/web/opt/init-letsencrypt
    - require:
      - file: /home/web/opt/init-letsencrypt
      - user: web
    {% endif %}
  {% endfor %}
{% endif %}

{% endif %} # devpi or dropbox or monitor or apache
{% if alfresco or chat or django or dropbox or monitor %}

{% set sites = pillar.get('sites', {}) %}

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

/home/web/opt/maintenance-mode:
  file:
    - managed
    - source: salt://web/maintenance-mode
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/opt
      - user: web


{% if users|length %}
  {% for user in users %}
    {% if user != "web" %}
/home/{{ user }}/bin/maintenance-mode:
  file.symlink:
    - target: /home/web/opt/maintenance-mode
    - require:
      - file: /home/web/opt/maintenance-mode
      - user: web
    {% endif %}
  {% endfor %}
{% endif %}

{% for domain, settings in sites.iteritems() %}
{% set cron = settings.get('cron', {}) -%}

/home/web/opt/{{ domain }}.sh:
  file:
    - managed
    - source: salt://web/manage.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
    - require:
      - file: /home/web/opt
      - user: web

/home/web/repo/files/{{ domain }}/sample-maintenance.html:
  file:
    - managed
    - source: salt://web/sample-maintenance.html
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
    - require:
      - file: /home/web/repo/files/{{ domain }}/public
      - user: web

/home/web/repo/files/{{ domain }}/deny-robots.txt:
  file:
    - managed
    - source: salt://web/deny-robots.txt
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
    - require:
      - file: /home/web/repo/files/{{ domain }}/public
      - user: web

{% if alfresco %}
/home/web/opt/alfresco-bart.sh:
  file:
    - managed
    - source: salt://web/alfresco-bart.sh
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/opt
      - user: web

/home/web/opt/alfresco-bart.properties:
  file:
    - managed
    - source: salt://web/alfresco-bart.properties
    - user: web
    - group: web
    - mode: 444
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
    - require:
      - file: /home/web/opt
      - user: web
{% elif gpg %}
/home/web/opt/backup.{{ domain }}.sh:
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
      domain: {{ domain }}
    - require:
      - file: /home/web/opt
      - user: web
{% endif %} # gpg

{# create cron.d file even if it is empty... #}
{# or we won't be able to remove items from it #}
/etc/cron.d/{{ domain|replace('.', '_') }}:
  file:
    - managed
    - source: salt://web/cron_for_site
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      cron: {{ cron }}
      django: {{ django }}
      dropbox: {{ empty_dict }}
      domain: {{ domain }}

{% endfor %} # domain, settings


{% if dropbox %}
{% for account in dropbox.accounts %}
/home/web/opt/backup_dropbox_{{ account }}.sh:
  file:
    - managed
    - source: salt://web/backup_dropbox.sh
    - user: web
    - group: web
    - mode: 755
    - template: jinja
    - makedirs: True
    - context:
      dropbox_account: {{ account }}
      gpg: {{ gpg }}
    - require:
      - file: /home/web/opt
      - user: web
{% endfor %}
{% endif %} # dropbox


{# create cron.d file for dropbox even if it is empty... #}
{# or we won't be able to remove items from it #}
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
      django: {{ empty_dict }}
      dropbox: {{ dropbox }}


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
