FROM openshift/base-centos7
MAINTAINER Prabhakaran Jayaraman Masani (pjayaramanma@dxc.com)

ENV BUILDER_VERSION 1.1

RUN yum -y update; \ 
    yum install wget -y; \ 
    yum install tar -y; \ 
    yum install unzip -y; \ 
    yum install ca-certificates -y;\ 
    yum install sudo -y;\ 
    yum clean all -y 

ENV TOMCAT_MAJOR_VERSION 8 
ENV TOMCAT_MINOR_VERSION 8.0.32 
ENV CATALINA_HOME /tomcat 


# Install openjdk 1.8 
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src
    
    
# Install Maven 3.3.9    
ENV MAVEN_VERSION 3.3.9
RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2    

# INSTALL TOMCAT 
WORKDIR /

RUN wget -q -e use_proxy=yes https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz && \
    tar -zxf apache-tomcat-*.tar.gz &&\
    rm -f apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat 

ENV PATH=/opt/maven/bin/:$PATH

RUN groupadd -r safe 
RUN useradd  -r -g safe safe 
RUN mkdir -p /tomcat/webapps /TempDirRoot
RUN chown -R 1001:1001 /tomcat /TempDirRoot 
RUN chmod -R 777 /tomcat /TempDirRoot 

RUN cd /tomcat/webapps/; rm -rf ROOT docs examples host-manager manager 

COPY ./.s2i/bin/ /usr/libexec/s2i

USER 1001

EXPOSE 8080

CMD $STI_SCRIPTS_PATH/usage
