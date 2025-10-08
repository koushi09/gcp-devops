# build stage
FROM gradle:8.4-jdk17 AS builder
WORKDIR /home/gradle/project
COPY --chown=gradle:gradle . .
RUN gradle --no-daemon bootJar

# runtime stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /home/gradle/project/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]