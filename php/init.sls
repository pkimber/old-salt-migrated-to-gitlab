{% set php = pillar.get('php', None) %}
{% if php %}

{% set sites = pillar.get('sites', {}) %}

php5-fpm:
  pkg:
    - installed
  service:
    - running

php5:
  pkg:
    - installed
    - require:
      - pkg: php5-fpm

php5-gd:
  pkg:
    - installed
    - require:
      - pkg: php5

php5-mysql:
  pkg:
    - installed
    - require:
      - pkg: php5

/var/run/php5-fpm:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: False
    - require:
      - pkg: php5-fpm

{% for site, settings in sites.iteritems() -%}
{% set domain = settings.get('domain') -%}
{% set profile = settings.get('profile') -%}

{% if profile == 'php' %}
/etc/php5/fpm/pool.d/{{ site }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://php/fpm.conf
    - template: jinja
    - context:
      site: {{ site }}
    - require:
      - pkg: php5-fpm
{% endif %}
{% endfor -%}

{% endif %}
