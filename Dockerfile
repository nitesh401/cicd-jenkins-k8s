# Runtime-only image. The JAR is built by Maven in the pipeline (stage "Build & Unit Test")
# and Kaniko reuses the workspace, so the build happens exactly once.
# Local use:  mvn -B clean package && docker build -t my-service:local .
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY target/my-service.jar app.jar
USER app
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
