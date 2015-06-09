FROM ubuntu:14.04

RUN rm /etc/apt/sources.list
RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe multiverse > /etc/apt/sources.list

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update
RUN apt-get install oracle-java8-installer curl patch -y
RUN update-java-alternatives -s java-8-oracle
RUN apt-get install oracle-java8-set-default

RUN curl http://archive.apache.org/dist/activemq/apache-activemq/5.9.0/apache-activemq-5.9.0-bin.tar.gz | tar -xz

EXPOSE 61612 61613 61616 8161

RUN mv apache-activemq-5.9.0/conf/activemq.xml apache-activemq-5.9.0/conf/activemq.xml.orig
RUN awk '/.*stomp.*/{print "            <transportConnector name=\"stompssl\" uri=\"stomp+nio+ssl://0.0.0.0:61612?transport.enabledCipherSuites=SSL_RSA_WITH_RC4_128_SHA,SSL_DH_anon_WITH_3DES_EDE_CBC_SHA\" />"}1' apache-activemq-5.9.0/conf/activemq.xml.orig >> apache-activemq-5.9.0/conf/activemq.xml
# Patch tag to solve compatibility problem with Java 8 https://issues.apache.org/jira/browse/AMQ-5356
RUN wget https://issues.apache.org/jira/secure/attachment/12707727/AMQ-5356.patch
RUN patch apache-activemq-5.9.0/webapps/admin/WEB-INF/tags/form/forEachMapEntry.tag < AMQ-5356.patch
RUN patch apache-activemq-5.9.0/webapps/admin/message.jsp < AMQ-5356.patch

CMD java -Xms1G -Xmx1G -Djava.util.logging.config.file=logging.properties -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote -Djava.io.tmpdir=apache-activemq-5.9.0/tmp -Dactivemq.classpath=apache-activemq-5.9.0/conf -Dactivemq.home=apache-activemq-5.9.0 -Dactivemq.base=apache-activemq-5.9.0 -Dactivemq.conf=apache-activemq-5.9.0/conf -Dactivemq.data=apache-activemq-5.9.0/data -jar apache-activemq-5.9.0/bin/activemq.jar start
