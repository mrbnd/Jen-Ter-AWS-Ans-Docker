FROM tomcat:8-jdk8
RUN apt-get update && apt install -y maven git && git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
WORKDIR "/usr/local/tomcat/boxfuse-sample-java-war-hello"
RUN  mvn package && cp /usr/local/tomcat/boxfuse-sample-java-war-hello/target/hello-1.0.war /usr/local/tomcat/webapps
