{% set devpi = pillar.get('devpi', {}) %}


{% if devpi|length %}

/home/web/repo/devpi:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file.directory: /home/web/repo

/home/web/repo/devpi/data:
  file.directory:
    - user: web
    - group: web
    - mode: 755
    - require:
      - file.directory: /home/web/repo/devpi

/home/web/repo/devpi/venv_devpi:
  virtualenv.manage:
    - no_site_packages: True
    - requirements: salt://devpi/requirements.txt
    - require:
      - pkg: python-virtualenv
      - file.directory: /home/web/repo/devpi

{% endif %}
