# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the built artifact from the build stage
COPY --from=build /app/target/*.war app.war

# Change ownership of the application file
RUN chown appuser:appgroup app.war

# Switch to the non-root user
USER appuser

# Expose port 8080 (default Spring Boot port, not 80)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.war"]
