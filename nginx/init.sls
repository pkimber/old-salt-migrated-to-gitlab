{% set nginx = pillar.get('nginx', None) %}
{% if nginx %}

{% set sites = pillar.get('sites', {}) %}
{% set nginx_services = pillar.get('nginx_services', {}) %}
{% set testing = pillar.get('testing', None) -%}

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
    - require:                                  # requisite declaration
      - pkg: nginx                              # requisite reference

/etc/nginx/include:
  file.directory:
    - mode: 755
    - require:
      - pkg: nginx

{% for site, settings in sites.iteritems() %}
{% set test = settings.get('test', {}) -%}

{% if not testing or testing and test -%}

/etc/nginx/include/{{ site }}.conf:
  file:
    - managed
    - source: salt://nginx/nginx-site-include.conf
    - template: jinja
    - context:
      site: {{ site }}
      settings: {{ settings }}
    - require:
      - file: /etc/nginx/include

# Folder for certificates
# http://library.linode.com/web-servers/nginx/configuration/ssl
/srv/ssl/{{ site }}/:
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

{% endif %}
