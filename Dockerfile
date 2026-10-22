FROM node:24-alpine AS frontend-build

WORKDIR /app/frontend

COPY frontend/package*.json ./

RUN npm ci

COPY frontend/ ./

RUN npm run build



FROM eclipse-temurin:21-jdk AS backend-build

WORKDIR /app

COPY gradle/ gradle/
COPY gradlew build.gradle.kts settings.gradle.kts ./

COPY src/ src/

COPY --from=frontend-build /app/frontend/dist/ /app/src/main/resources/static/

RUN chmod +x gradlew && ./gradlew bootJar --no-daemon



FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=backend-build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]