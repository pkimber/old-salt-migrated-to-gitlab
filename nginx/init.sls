{% set devpi = pillar.get('devpi', {}) %}
{% set php = pillar.get('php', {}) %}
{% set sites = pillar.get('sites', {}) %}


{% if sites|length or devpi|length or php|length %}


{% set nginx = pillar.get('nginx', {}) %}
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
      devpi: {{ devpi }}
      nginx: {{ nginx }}
      nginx_services: {{ nginx_services }}
      php: {{ php }}
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
