{% set solr = pillar.get('solr', {}) %}
{% if solr|length %}

{% set sites = pillar.get('sites', {}) %}

/var/lib/tomcat7/conf/server.xml:
  file.managed:
    - source: salt://solr/server.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/conf/Catalina/localhost/solr.xml:
  file.managed:
    - source: salt://solr/tomcat-solr.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/jcl-over-slf4j-1.6.6.jar:
  file.managed:
    - source: salt://solr/jcl-over-slf4j-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/jul-to-slf4j-1.6.6.jar:
  file.managed:
    - source: salt://solr/jul-to-slf4j-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/log4j-1.2.16.jar:
  file.managed:
    - source: salt://solr/log4j-1.2.16.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/log4j.properties:
  file.managed:
    - source: salt://solr/log4j.properties
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/slf4j-api-1.6.6.jar:
  file.managed:
    - source: salt://solr/slf4j-api-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/lib/tomcat7/shared/slf4j-log4j12-1.6.6.jar:
  file.managed:
    - source: salt://solr/slf4j-log4j12-1.6.6.jar
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: tomcat7

/var/data/solr/war/solr.war:
  file.managed:
    - source: salt://solr/solr-4.3.0.war
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/war

/var/data/solr/multicore/solr.xml:
  file.managed:
    - source: salt://solr/solr.xml
    - template: jinja
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore

/var/data/solr/multicore/zoo.cfg:
  file.managed:
    - source: salt://solr/zoo.cfg
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore

{% for site, settings in sites.iteritems() %}

/var/data/solr/multicore/{{ site }}/conf/protwords.txt:
  file.managed:
    - source: salt://solr/protwords.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore/{{ site }}

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
      - file.directory: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/stopwords.txt:
  file.managed:
    - source: salt://solr/stopwords.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/stopwords_en.txt:
  file.managed:
    - source: salt://solr/stopwords_en.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore/{{ site }}

/var/data/solr/multicore/{{ site }}/conf/synonyms.txt:
  file.managed:
    - source: salt://solr/synonyms.txt
    - user: tomcat7
    - group: tomcat7
    - mode: 644
    - require:
      - file.directory: /var/data/solr/multicore/{{ site }}

{% endfor %}
{% endif %}
