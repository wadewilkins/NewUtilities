FROM ubuntu:latest AS tomcat-image
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
  
RUN mkdir /opt/tomcat/

WORKDIR /opt/tomcat
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    openjdk-11-jdk
RUN curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.38/bin/apache-tomcat-9.0.38.tar.gz
RUN tar xfz apache*.tar.gz
RUN mv apache-tomcat-9.0.38/* /opt/tomcat/.
#RUN apt-get -y install java
RUN java -version

WORKDIR /opt/tomcat/webapps
RUN curl -O -L https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
COPY sample.war /opt/tomcat/webapps/sample.war

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]


