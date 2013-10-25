{# pillar data #}
{% set devpi = pillar.get('devpi', {}) %}
{% set sites = pillar.get('sites', {}) %}

{# Only install packages if we have a site or a service (devpi) #}
{% if sites|length or devpi|length %}

build-essential:
  pkg.installed

python-dev:
  pkg.installed:
    - require:
      - pkg.installed: build-essential

python-virtualenv:
  pkg.installed

libpq-dev:
  pkg.installed

git:
  pkg.installed

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
