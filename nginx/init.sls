{% set nginx = pillar.get('nginx', None) %}
{% if nginx %}

{% set devpi = pillar.get('devpi', None) -%}
{% set monitor = pillar.get('monitor', None) -%}
{% set nginx_services = pillar.get('nginx_services', {}) %}
{% set sites = pillar.get('sites', {}) %}
{% set testing = pillar.get('testing', False) -%}

nginx:
  pkg.installed: []
  service:
    - running
    - watch:
       - pkg: nginx
       - file: /etc/nginx/nginx.conf

nginx.conf:
  file:                                         # state declaration
    - managed                                   # function
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/nginx.conf
    - template: jinja
    - context:
      nginx: {{ nginx }}
      nginx_services: {{ nginx_services }}
      sites: {{ sites }}
      testing: {{ testing }}
    - require:                                  # requisite declaration
      - pkg: nginx                              # requisite reference

/etc/nginx/include:
  file.directory:
    - mode: 755
    - require:
      - pkg: nginx

{% for site, settings in sites.iteritems() %}
{% set test = settings.get('test', {}) %}

{% if testing and test -%}
{% set domain = test.get('domain') %}
{% set domain_www = domain %}
{% else -%}
{% set domain = settings.get('domain') %}
{% set domain_www = 'www.' + domain %}
{% endif %}

{% if not testing or testing and test -%}

/etc/nginx/include/{{ site }}.conf:
  file:
    - managed
    - source: salt://nginx/include-site.conf
    - template: jinja
    - context:
      domain: {{ domain }}
      domain_www: {{ domain_www }}
      site: {{ site }}
      settings: {{ settings }}
      testing: {{ testing }}
    - require:
      - file: /etc/nginx/include

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

{% endif %} # not testing or testing and test
{% endfor %} # site, settings

{% if devpi -%}
/etc/nginx/include/devpi.conf:
  file:
    - managed
    - source: salt://nginx/include-devpi.conf
    - template: jinja
    - context:
      domain: {{ devpi }}
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
      domain: {{ monitor }}
    - require:
      - file: /etc/nginx/include
{% endif %} # monitor

{% endif %}
