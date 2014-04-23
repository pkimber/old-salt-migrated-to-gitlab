{% set solr = pillar.get('solr', None) %}
{% if solr %}

{% set sites = pillar.get('sites', {}) %}

/var/lib/tomcat7/conf/server.xml:
  file.managed:
    - source: salt://solr/server.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/var/lib/tomcat7/conf/Catalina/localhost/solr.xml:
  file.managed:
    - source: salt://solr/tomcat-solr.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/jcl-over-slf4j-1.6.6.jar:
  file.managed:
    - source: salt://solr/jcl-over-slf4j-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/jul-to-slf4j-1.6.6.jar:
  file.managed:
    - source: salt://solr/jul-to-slf4j-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/log4j-1.2.16.jar:
  file.managed:
    - source: salt://solr/log4j-1.2.16.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/log4j.properties:
  file.managed:
    - source: salt://solr/log4j.properties
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/slf4j-api-1.6.6.jar:
  file.managed:
    - source: salt://solr/slf4j-api-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/usr/share/tomcat7/lib/slf4j-log4j12-1.6.6.jar:
  file.managed:
    - source: salt://solr/slf4j-log4j12-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: tomcat7

/var/data/solr/war/solr.war:
  file.managed:
    - source: salt://solr/solr-4.7.2.war
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/war

/var/data/solr/multicore/solr.xml:
  file.managed:
    - source: salt://solr/solr.xml
    - template: jinja
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore

/var/data/solr/multicore/zoo.cfg:
  file.managed:
    - source: salt://solr/zoo.cfg
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore

{% for site, settings in sites.iteritems() %}

/var/data/solr/multicore/{{ site }}/conf/protwords.txt:
  file.managed:
    - source: salt://solr/protwords.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/solrconfig.xml:
  file.managed:
    - source: salt://solr/solrconfig.xml
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - template: jinja
    - context:
      site: {{ site }}
    - require:
      - file: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/stopwords.txt:
  file.managed:
    - source: salt://solr/stopwords.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/stopwords_en.txt:
  file.managed:
    - source: salt://solr/stopwords_en.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/synonyms.txt:
  file.managed:
    - source: salt://solr/synonyms.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file: /var/data/solr/multicore/{{ site }}

{% endfor %}
{% endif %}
