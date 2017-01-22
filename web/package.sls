{% set django = pillar.get('django', None) %}
{% set dropbox = pillar.get('dropbox', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set php = pillar.get('php', None) %}
{% set apache = pillar.get('apache', None) %}

{% set devpi = pillar.get('devpi', None) %}
{% set sites = pillar.get('sites', {}) %}

build-essential:
  pkg.installed

git:
  pkg.installed

mercurial:
  pkg.installed

{% if django or devpi or monitor or apache %}

python3:
  pkg.installed

python3-dev:
  pkg.installed

python-dev:
  pkg.installed:
    - require:
      - pkg: build-essential

python3-virtualenv:
  pkg.installed

python3-venv:
  pkg.installed

{# for letsencrypt #}
bc:
  pkg.installed

letsencrypt-git:
  git.latest:
    - name: https://github.com/letsencrypt/letsencrypt
    - target: /opt/letsencrypt
    - require:
      - pkg: git
      - pkg: bc

{% endif %} # django or devpi or monitor or apache

{% if django %}

{# for pillow #}
libjpeg62-dev:
  pkg.installed

{# for pillow #}
zlib1g-dev:
  pkg.installed

{# for pillow #}
libfreetype6-dev:
  pkg.installed

{# for pillow #}
liblcms1-dev:
  pkg.installed

{# for element tree #}
libxml2-dev:
  pkg.installed

{# for element tree #}
libxslt1-dev:
  pkg.installed

{% endif %} # django

{% if dropbox %}

{# copied from https://www.dropbox.com/install?os=lnx #}
dropboxd:
  cmd.run:
    - unless: test -d /home/web/.dropbox-dist
    - cwd: /home/web
    {% if grains['cpuarch'] == 'i686' %}
    - name: 'wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -'
    {% elif grains['cpuarch'] == 'x86_64' %}
    - name: 'wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -'
    {% else %}
    I think 'cpuarch' can only be 'x86' or 'x86_64'
    {% endif %}
    - runas: web

{% endif %} # dropbox
