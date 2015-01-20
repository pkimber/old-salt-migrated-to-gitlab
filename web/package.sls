{% set django = pillar.get('django', None) %}
{% set monitor = pillar.get('monitor', None) %}
{% set php = pillar.get('php', None) %}

{% set devpi = pillar.get('devpi', None) %}
{% set sites = pillar.get('sites', {}) %}

build-essential:
  pkg.installed

git:
  pkg.installed

mercurial:
  pkg.installed

{% if django or devpi or monitor %}

python3:
  pkg.installed

python3-dev:
  pkg.installed

python-dev:
  pkg.installed:
    - require:
      - pkg: build-essential

python-virtualenv:
  pkg.installed

{% endif %} # django or devpi or monitor

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
