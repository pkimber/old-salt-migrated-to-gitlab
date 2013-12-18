{% set devpi = pillar.get('devpi', {}) %}
{% set sites = pillar.get('sites', {}) %}

{# Only set-up web folders if we have a site or a service (devpi) #}
{% if sites|length or devpi|length %}

{# Create repo folder (required for other bits) #}
/home/web/repo:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - user: web

{% endif %}

{% if sites|length %}

/home/web/repo/files:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - recurse:
      - user
      - group
      - mode
    - require:
      - file.directory: /home/web/repo

/home/web/repo/project:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - recurse:
      - user
      - group
      - mode
    - require:
      - file.directory: /home/web/repo

{% for site, settings in sites.iteritems() %}

{# 'files/site/public' folder is for public uploads #}
/home/web/repo/files/{{ site }}/public:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - file.directory: /home/web/repo/files

{# 'files/site/private' folder is for private attachments #}
/home/web/repo/files/{{ site }}/private:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - file.directory: /home/web/repo/files

{# 'project' folder is for the code #}
/home/web/repo/project/{{ site }}:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - file.directory: /home/web/repo/project

{% endfor %}
{% endif %}
