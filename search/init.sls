{% set search = pillar.get('search', None) %}
{% if search %}
# https://gist.github.com/renoirb/6722890
#
# How to install automatically Oracle Java 7 under Salt Stack
#
# Thanks Oracle for complicating things :(
#
# 1. Create a java/ folder in your salt master
# 2. Paste this file in init.sls
# 3. salt '*' state.sls java
#
# Source:
#  * https://github.com/log0ymxm/salt-jvm/blob/master/init.sls
#  * http://architects.dzone.com/articles/puppet-installing-oracle-java
#
oracle-ppa:
  pkgrepo.managed:
    - humanname: WebUpd8 Oracle Java PPA repository
    - ppa: webupd8team/java

oracle-license-select:
  cmd.run:
    - unless: which java
    - name: '/bin/echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
    - require_in:
      - pkg: oracle-java7-installer
      - cmd: oracle-license-seen-lie

oracle-license-seen-lie:
  cmd.run:
    - name: '/bin/echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 seen true  | /usr/bin/debconf-set-selections'
    - require_in:
      - pkg: oracle-java7-installer

oracle-java7-installer:
  pkg:
    - installed
    - require:
      - pkgrepo: oracle-ppa

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
  file.managed:
    - name: /usr/share/elasticsearch/plugins/analysis-phonetic/plugin-descriptor.properties
    - cmd.run:
      - name: bin/plugin analysis-phonetic
      - cwd: /usr/share/elasticsearch
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
