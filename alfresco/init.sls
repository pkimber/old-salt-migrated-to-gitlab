{% set alfresco = pillar.get('alfresco', False) %}
{% set gpg = pillar.get('gpg', False) %}
{% set sites = pillar.get('sites', {}) %}

{% if alfresco %}

# for libreoffice
fontconfig:
  pkg.installed
fonts-noto:
  pkg.installed
libcairo2:
  pkg.installed
libcups2:
  pkg.installed
libfontconfig1:
  pkg.installed
libgl1-mesa-glx:
  pkg.installed
libglu-dev:
  pkg.installed
libglu1-mesa:
  pkg.installed
libice6:
  pkg.installed
libsm-dev:
  pkg.installed
libsm6:
  pkg.installed
libxext-dev:
  pkg.installed
libxinerama1:
  pkg.installed
libxrender1:
  pkg.installed
libxt6:
  pkg.installed
ttf-mscorefonts-installer:
  pkg.installed

ghostscript:
  pkg.installed
imagemagick:
  pkg.installed
libgs-dev:
  pkg.installed
libjpeg62:
  pkg.installed
libpng3:
  pkg.installed
libxinerama-dev:
  pkg.installed


/usr/lib/x86_64-linux-gnu/libGL.so.1:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/mesa/libGL.so.1

# for postgres
postgresql-client:
  pkg.installed


{% for domain, settings in sites.iteritems() %}
/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties:
  file.managed:
    - source: salt://alfresco/alfresco-global.properties
    - user: root
    - group: root
    - template: jinja
    - context:
      settings: {{ settings }}

{% if gpg %}
/home/web/opt/alfresco-bart.sh:
  file:
    - managed
    - source: salt://alfresco/alfresco-bart.sh
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
    - source: salt://alfresco/alfresco-bart.properties
    - user: web
    - group: web
    - mode: 444
    - template: jinja
    - makedirs: True
    - context:
      gpg: {{ gpg }}
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - file: /home/web/opt
      - user: web
{% endif %} # gpg
{% endfor %} # domain, settings

{% endif %}
