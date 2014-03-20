{% set devpi = pillar.get('devpi', None) %}
{% set django = pillar.get('django', None) %}

{% if devpi or django %}

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

/home/web/repo/files:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

/home/web/repo/project:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: False
    - require:
      - file: /home/web/repo

{% for site, settings in sites.iteritems() %}

{# 'files/site/public' folder is for public uploads #}
/home/web/repo/files/{{ site }}/public:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/files

{# 'files/site/private' folder is for private attachments #}
/home/web/repo/files/{{ site }}/private:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/files

{# 'project' folder is for the code #}
/home/web/repo/project/{{ site }}:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/project

{% endfor %}
{% endif %}
