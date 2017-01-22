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
  virtualenv.managed:
    - index_url: https://pypi.python.org/simple/
    - requirements: salt://devpi/requirements.txt
    - user: web
    - venv_bin: /usr/bin/pyvenv-3.5
    - require:
      - pkg: python3-venv
      - pkg: python3-virtualenv
      - file: /home/web/repo/devpi

{% endif %}
