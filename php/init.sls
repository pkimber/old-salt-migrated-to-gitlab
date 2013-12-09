{% set php = pillar.get('php', {}) %}
{% if php %}
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
{% endif %}
