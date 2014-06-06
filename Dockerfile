FROM    ubuntu:14.04

RUN rm /etc/apt/sources.list
RUN echo deb http://archive.ubuntu.com/ubuntu precise main universe multiverse > /etc/apt/sources.list

RUN apt-get update
RUN apt-get install openjdk-7-jre-headless curl -y

RUN curl http://mirror.ox.ac.uk/sites/rsync.apache.org/activemq/apache-activemq/5.9.0/apache-activemq-5.9.0-bin.tar.gz > apache-activemq-5.9.0-bin.tar.gz
RUN tar xzf apache-activemq-5.9.0-bin.tar.gz

EXPOSE 61613 61616 8161

CMD java -Xms1G -Xmx1G -Djava.util.logging.config.file=logging.properties -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote -Djava.io.tmpdir=apache-activemq-5.9.0/tmp -Dactivemq.classpath=apache-activemq-5.9.0/conf -Dactivemq.home=apache-activemq-5.9.0 -Dactivemq.base=apache-activemq-5.9.0 -Dactivemq.conf=apache-activemq-5.9.0/conf -Dactivemq.data=apache-activemq-5.9.0/data -jar apache-activemq-5.9.0/bin/activemq.jar start
