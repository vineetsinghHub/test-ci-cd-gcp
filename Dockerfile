# ---------- Stage 1: Build the JAR ----------
#FROM gradle:8.14.3-jdk21 AS builder
#WORKDIR /app
#COPY . .
#RUN ./gradlew clean build -x test

# ---------- Stage 2: Run the Application ----------
FROM eclipse-temurin:21-jdk
WORKDIR /app

# Copy the built jar from previous stage
COPY build/libs/*.jar app.jar

# Expose the port your app runs on
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
