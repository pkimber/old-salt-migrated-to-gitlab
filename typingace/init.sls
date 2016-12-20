{% set apache_php = pillar.get('apache_php', None) %}
{% if apache_php %}

{% set typingace = pillar.get('typingace', None) %}
{% set sites = pillar.get('sites', {}) %}

unzip:
  pkg:
    - installed

php5:
  pkg:
    - installed

php5-gd:
  pkg:
    - installed
    - require:
      - pkg: php5

libapache2-mod-php5:
  pkg:
    - installed
    - require:
      - pkg: php5
  service:
    - running
    - name: apache2
    - enable: True

php5-mysql:
  pkg:
    - installed
    - require:
      - pkg: php5

{% for domain, settings in sites.iteritems() -%}
{% set profile = settings.get('profile') -%}

{% if profile == 'apache_php' %}

/etc/apache2/conf-available/fqdn.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://typingace/fqdn.conf
    - require:
      - pkg: apache2

/etc/php5/mods-available/{{ domain }}.ini:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://typingace/typingace.ini
    - template: jinja
    - context:
      domain: {{ domain }}
    - require:
      - pkg: php5

Enable rewrite module:
  apache_module.enable:
    - name: rewrite

Enable php5 module:
  apache_module.enable:
    - name: php5

Enable ssl module:
  apache_module.enable:
    - name: ssl

/srv/ssl/{{ domain }}/:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 400
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - pkg: apache2

/etc/apache2/sites-available/{{ domain }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://typingace/virtualhost.conf
    - template: jinja
    - context:
      domain: {{ domain }}
    - require:
      - pkg: apache2

/etc/php5/apache2/conf.d/90-{{ domain }}.ini:
  file.symlink:
    - target: ../../mods-available/{{ domain }}.ini

/etc/apache2/conf-enabled/fqdn.conf:
  file.symlink:
    - target: ../conf-available/fqdn.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.absent:
    - name: /etc/apache2/sites-enabled/000-default.conf

/etc/apache2/sites-enabled/000-{{ domain }}.conf:
  file.symlink:
    - target: ../sites-available/{{ domain }}.conf

{% endif %}

{% if typingace %}
/home/web/repo/project/{{ domain }}/live:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - makedirs: True
    - require:
      - file: /home/web/repo/project/{{ domain }}

/home/web/repo/project/{{ domain }}/live/TypingAce-Intranet:
  archive.extracted:
    - name: /home/web/repo/project/{{ domain }}/live
    - source: salt://typingace/intranet_demo_nosg.zip
    - archive_format: zip
    - if_missing: /home/web/repo/project/{{ domain }}/live/TypingAce-Intranet/typingace
    - require:
      - file: /home/web/repo/project/{{ domain }}/live
  file.directory:
    - user: web
    - group: www-data
    - recurse:
      - user
      - group

/home/web/repo/project/{{ domain }}/live/TypingAce-Intranet/typingace/config:
  file.directory:
    - mode: 775

/home/web/repo/project/{{ domain }}/live/TypingAce-Intranet/typingace/twlibs/cache:
  file.directory:
    - mode: 775

ilspa-typingace-branding:
  archive.extracted:
    - name: /home/web/repo/project/{{ domain }}/live
    - source: salt://typingace/ilspa-branding.tar.gz
    - tar_options: vz
    - archive_format: tar
    - if_missing: /home/web/repo/project/{{ domain }}/live/.ilspa-branded

zend-pdf-patch:
  archive.extracted:
    - name: /home/web/repo/project/{{ domain }}/live
    - source: salt://typingace/zend-pdf-patch.tar.gz
    - tar_options: vz
    - archive_format: tar
    - if_missing: /home/web/repo/project/{{ domain }}/live/.zend-pdf-patch
{% endif %}
{% endfor -%}

{% endif %}
