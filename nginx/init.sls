{% set nginx = pillar.get('nginx', None) %}
{% if nginx %}

{% set devpi = pillar.get('devpi', False) -%}
{% set monitor = pillar.get('monitor', False) -%}
{% set nginx_services = pillar.get('nginx_services', {}) %}
{% set sites = pillar.get('sites', {}) %}

nginx:
  pkg.installed: []
  service:
    - running
    - watch:
       - pkg: nginx
       - file: /etc/nginx/nginx.conf

# disable default site
/etc/nginx/sites-enabled/default:
  file.absent
/etc/nginx/sites-available/default:
  file.absent

nginx.conf:
  file:                                         # state declaration
    - managed                                   # function
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/nginx.conf
    - template: jinja
    - context:
      devpi: {{ devpi }}
      monitor: {{ monitor }}
      nginx: {{ nginx }}
      nginx_services: {{ nginx_services }}
      sites: {{ sites }}
    - require:                                  # requisite declaration
      - pkg: nginx                              # requisite reference

/etc/nginx/include:
  file.directory:
    - mode: 755
    - require:
      - pkg: nginx

{% for domain, settings in sites.iteritems() %}

/etc/nginx/include/{{ domain }}.conf:
  file:
    - managed
    - source: salt://nginx/include-site.conf
    - template: jinja
    - context:
      domain: {{ domain }}
      settings: {{ settings }}
    - require:
      - file: /etc/nginx/include

{# strong Diffie-Hellman certificate #}
/etc/ssl/certs/dhparam.pem:
  cmd.run:
    - name: openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    - unless: test -f /etc/ssl/certs/dhparam.pem

# Folder for certificates
# http://library.linode.com/web-servers/nginx/configuration/ssl
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
      - pkg: nginx

{% endfor %} # domain, settings

# default site
/etc/nginx/include/default.conf:
  file:
    - managed
    - source: salt://nginx/include-default.conf
    - template: jinja
    - require:
      - file: /etc/nginx/include

/srv/ssl/default:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/srv/ssl/default/default.crt:
  file:
    - managed
    - user: www-data
    - group: www-data
    - mode: 400
    - makedirs: False
    - contents_pillar: nginx:ssl:crt
    - require:
      - file: /srv/ssl/default

/srv/ssl/default/default.key:
  file:
    - managed
    - user: www-data
    - group: www-data
    - mode: 400
    - contents_pillar: nginx:ssl:key
    - makedirs: False
    - require:
      - file: /srv/ssl/default/default.crt

/srv/www/default:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/srv/www/default/index.html:
  file:
    - managed
    - source: salt://nginx/index.html
    - user: www-data
    - group: www-data
    - mode: 400
    - makedirs: False
    - require:
      - file: /srv/www/default

# devpi
{% if devpi -%}
/etc/nginx/include/devpi.conf:
  file:
    - managed
    - source: salt://nginx/include-devpi.conf
    - template: jinja
    - context:
      devpi: {{ devpi }}
    - require:
      - file: /etc/nginx/include
{% endif %} # devpi

{% if monitor -%}
/etc/nginx/include/monitor.conf:
  file:
    - managed
    - source: salt://nginx/include-monitor.conf
    - template: jinja
    - context:
      monitor: {{ monitor }}
    - require:
      - file: /etc/nginx/include
{% endif %} # monitor

{% endif %}
