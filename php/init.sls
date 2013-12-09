{% set php = pillar.get('php', {}) %}
{% if php|length %}
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

/var/run/php5-fpm:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: False
    - require:
      - pkg: php5-fpm

{% for site, settings in php.iteritems() -%}
{% set domain = settings.get('domain') -%}

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
{% endfor -%}

{% endif %}
