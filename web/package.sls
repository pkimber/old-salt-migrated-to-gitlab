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

python-virtualenv:                          # ID declaration
  pkg:                                      # state declaration
    - installed                             # function declaration

libpq-dev:
  pkg.installed

git:
  pkg.installed

{% endif %}
