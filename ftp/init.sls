{% set sites = pillar.get('sites', {}) %}

{# Do any of the sites on this server have FTP #}
{% set has_ftp = False %}
{% for site, settings in sites.iteritems() %}
  {% set ftp = settings.get('ftp', None) -%}
  {% if ftp %}
    {% set has_ftp = True %}
  {% endif %}
{% endfor %}

{# Only set-up ftp if we have a site using ftp #}
{% if has_ftp %}
  /home/web/repo/ftp:
    file.directory:
      - user: web
      - group: web
      - mode: 755
      - recurse:
        - user
        - group
      - require:
        - file.directory: /home/web/repo
{% endif %}
  {% for site, settings in sites.iteritems() %}
    {% set ftp = settings.get('ftp', None) -%}
    {% if ftp %}
      {# for ftp uploads #}
      /home/web/repo/ftp/{{ site }}:
        file.directory:
          - user: web
          - group: web
          - mode: 755
          - recurse:
            - user
            - group
          - require:
            - file.directory: /home/web/repo/ftp
    {% endif %}
  {% endfor %}
