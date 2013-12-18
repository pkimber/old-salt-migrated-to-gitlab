{% set django = pillar.get('django', None) %}
{% set php = pillar.get('php', None) %}

{% set devpi = pillar.get('devpi', None) %}
{% set sites = pillar.get('sites', {}) %}

build-essential:
  pkg.installed

git:
  pkg.installed

{% if django or devpi %}

python-dev:
  pkg.installed:
    - require:
      - pkg.installed: build-essential

python-virtualenv:
  pkg.installed

{% endif %}

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

{% endif %}
