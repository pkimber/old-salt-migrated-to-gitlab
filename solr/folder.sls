{% set solr = pillar.get('solr', None) %}
{% if solr %}

{% set sites = pillar.get('sites', {}) %}

/var/data:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: tomcat7

/var/data/solr:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - require:
      - file: /var/data

/var/data/solr/war:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - require:
      - file: /var/data/solr

/var/data/solr/multicore:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - require:
      - file: /var/data/solr

{% for site, settings in sites.iteritems() %}

/var/data/solr/multicore/{{ site }}:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - require:
      - file: /var/data/solr/multicore

/var/data/solr/multicore/{{ site }}/conf:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - require:
      - file: /var/data/solr/multicore/{{ site }}

{% endfor %}
{% endif %}
