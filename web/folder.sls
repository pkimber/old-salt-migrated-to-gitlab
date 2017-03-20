{% set alfresco = pillar.get('alfresco', False) %}
{% set chat = pillar.get('chat', False) %}
{% set devpi = pillar.get('devpi', None) %}
{% set dropbox = pillar.get('dropbox', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set django = pillar.get('django', None) %}
{% set apache_php = pillar.get('apache_php', None) %}

{% if alfresco or chat or devpi or django or dropbox or monitor or apache_php %}

{% set sites = pillar.get('sites', {}) %}

{# Create repo folder (required for other bits) #}
/home/web/repo:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - user: web

/home/web/repo/backup:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

/home/web/repo/files:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

{% if dropbox %}
/home/web/repo/files/dropbox:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo/files

{% for account in dropbox.accounts -%}
/home/web/repo/files/dropbox/{{ account }}:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo/files/dropbox
{% endfor -%}
{% endif %} {# dropbox #}

/home/web/repo/project:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

/home/web/repo/temp:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

{% for domain, settings in sites.iteritems() %}

/home/web/repo/backup/{{ domain }}:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/backup

{# 'files/site/public' folder is for public uploads #}
/home/web/repo/files/{{ domain }}/public:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/files

{# 'files/site/private' folder is for private attachments #}
/home/web/repo/files/{{ domain }}/private:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/files

{# 'project' folder is for the code #}
/home/web/repo/project/{{ domain }}:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/project

{% endfor %} # domain, settings
{% endif %} # devpi or django or monitor
