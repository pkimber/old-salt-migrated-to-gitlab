ssh:
  service:
    - running
    - watch:
      - file: /etc/ssh/sshd_config

/etc/ssh/sshd_config:
  file:
    - managed
    - source: salt://ssh/sshd_config
    - user: root
    - group: root
    - mode: 644
