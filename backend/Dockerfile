# Step 1: build jar
FROM maven:3.8-jdk-11-slim AS builder
WORKDIR src
COPY . ./
RUN mvn package -Dmaven.compiler.executable=javac -Dmaven.test.skip=true -f .

# Step 2: use jar
FROM adoptopenjdk/openjdk11:jre-11.0.9.1_1-alpine
LABEL maintainer="Bas Maas"

COPY --from=builder /src/target/FullStackFit-FullStackFit.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]