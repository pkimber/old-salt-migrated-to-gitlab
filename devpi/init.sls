{% set devpi = pillar.get('devpi', None) %}

{% if devpi %}

/home/web/repo/devpi:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file: /home/web/repo

/home/web/repo/devpi/data:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file: /home/web/repo/devpi

/home/web/repo/devpi/venv_devpi:
  virtualenv.manage:
    - system_site_packages: False
    - requirements: salt://devpi/requirements.txt
    - user: web
    - require:
      - pkg: python-virtualenv
      - file: /home/web/repo/devpi

{% endif %}
