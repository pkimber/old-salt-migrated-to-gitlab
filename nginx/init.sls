{% set nginx = pillar.get('nginx', None) %}
{% if nginx %}

{% set sites = pillar.get('sites', {}) %}
{% set nginx_services = pillar.get('nginx_services', {}) %}

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

/etc/nginx/include/:
  file.directory:
    - mode: 755
    - require:
      - pkg: nginx

{% for site, settings in sites.iteritems() %}

# Folder for certificates
# http://library.linode.com/web-servers/nginx/configuration/ssl

/etc/nginx/include/{{ site }}.conf:
    - managed
    - source: salt://nginx/nginx-site-include.conf
    - template: jinja
    - context:
      site: {{ site }}
      settings: {{ settings }}
    - require:
      - file: /etc/nginx/include

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

{% endfor %}

{% endif %}
