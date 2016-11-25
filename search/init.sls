{% set search = pillar.get('search', None) %}
{% if search %}

# From
# https://github.com/saltstack-formulas/elasticsearch-logstash-kibana-formula/blob/master/kibana/init.sls

elastic_repos_key:
  file.managed:
    - name: /root/elastic_repo.key
    - name: /root/repo/temp/elastic_repo.key
    - source: salt://search/GPG-KEY-elasticsearch.txt
  cmd.run:
    - name: cat /root/repo/temp/elastic_repo.key | apt-key add -
    - require:
      - file: elastic_repos_key

elasticsearch_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/elasticsearch.list
    - require:
      - cmd: elastic_repos_key
    - contents: deb http://packages.elastic.co/elasticsearch/2.x/debian stable main
elasticsearch_soft:
  pkg.installed:
    - name: elasticsearch
    - require:
      - file: elasticsearch_repo
      - pkg: oracle-java7-installer


/etc/default/elasticsearch:
  file.managed:
    - source: salt://search/elasticsearch
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch_soft

/etc/security/limits.conf:
  file.managed:
    - source: salt://search/limits.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch_soft

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://search/elasticsearch.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch_soft

elastic_phonetic_plugin:
    cmd.run:
      - name: bin/plugin install analysis-phonetic
      - cwd: /usr/share/elasticsearch
      - unless: test -d /usr/share/elasticsearch/plugins/analysis-phonetic
      - require:
        - pkg: elasticsearch_soft
        - file: /etc/default/elasticsearch

elastic_service:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: elasticsearch_soft
      - file: /etc/default/elasticsearch
    - watch:
      - file: /etc/default/elasticsearch
{% endif %}
