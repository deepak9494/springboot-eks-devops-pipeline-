# Build stage: Use Maven + Java to compile and package the app
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set working directory inside container
WORKDIR /app

# Copy only pom.xml first to cache dependencies layer
COPY pom.xml .

# Download all dependencies to cache (speed up builds)
RUN mvn dependency:go-offline

# Copy source code and build the JAR, skipping tests for faster builds
COPY src ./src
RUN mvn clean package -DskipTests


# Runtime stage: Use a lightweight Java runtime image
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080 
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
