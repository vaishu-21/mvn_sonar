FROM openjdk:8u232-stretch
LABEL Author="prabu"
LABEL description="copy the jar file"
WORKDIR /opt
COPY $WORKSPACE/target/*.jar /opt/
ENTRYPOINT ["java", "-jar"]
CMD ["com.sonar.maven-0.0.1-SNAPSHOT.jar"]
