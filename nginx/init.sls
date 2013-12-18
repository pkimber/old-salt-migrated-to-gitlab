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

{% for site, settings in sites.iteritems() %}

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
    - require:                              # requisite declaration
      - pkg: nginx                          # requisite reference

{% endfor %}

{% endif %}
