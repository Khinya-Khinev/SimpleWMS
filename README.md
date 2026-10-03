## Table of Contents
- [Overview](#simplewms)
- [System Diagram](#system-diagram)
- [Services](#services)
    - [API Gateway](#api-gateway)
    - [Receiving Service](#receiving-service)
    - [Authorization Service](#authorization-service-oauth2)
    - [Frontend](#frontend-service-in-progress)
- [API Overview – Swagger](#api-overview--swagger)
- [Getting Started](#getting-started)
- [Next Steps](#next-steps)


# SimpleWMS

Warehouse management system.
Supports goods receiving and employee management.

## System Design Diagram

<p align="center">
  <img src="docs/system-design-diagram.excalidraw.png" alt="System Design" width="600">
</p>

## Tech Stack

Java 25 · Spring Boot 4 · Spring Security · Spring Cloud Gateway · Hibernate/JPA · PostgreSQL · Flyway · Redis · Apache Kafka · JUnit · Mockito · Testcontainers · Docker

## Services

### API Gateway
[GitHub Repository](https://github.com/Khinya-Khinev/API-Gateway)

Single entry point for the frontend: routes requests to backend services, handles the OAuth2 Authorization Code flow as an OAuth2 Client, 
and relays access tokens downstream. Session state stored in Redis.

### Receiving Service

[GitHub Repository](https://github.com/Khinya-Khinev/Receiving-Service)

[![Receiving Service CI](https://github.com/kamen-kamen/Receiving-Service/actions/workflows/ci.yaml/badge.svg)](https://github.com/kamen-kamen/Receiving-Service/actions/workflows/ci.yaml)


#### Workflow

Service manages ASN processing, worker receiving sessions, barcode scanning, discrepancy detection.

<p align="center">
  <img src="docs/receiving-process-flowchart.excalidraw.png" alt="Workflow" width="300">
</p>

#### Architecture

Follows a Ports & Adapters architecture to keep the domain independent from infrastructure.
Some modules interact directly with JPA repositories where additional abstraction provides little benefit.

<p align="center">
  <img src="docs/receiving-service-architecture.excalidraw.png" alt="Receiving Service Architecture">
</p>

### Authorization Service (OAuth2)
[GitHub Repository](https://github.com/Khinya-Khinev/Auth-Service)

OAuth2 / OpenID Connect Authorization Server for the WMS: authenticates employees, issues access/refresh/ID tokens
and manages accounts.

### Frontend Service (in progress)
[GitHub | Ivan Khramoy](https://github.com/IvanKhramoy/receiving-serivce-ui)

Web Client. Currently not included in Docker Compose.

## API Overview – Swagger 

+ Endpoints and request/responce schema: `http://localhost:8080/swagger-ui/index.html`

## Getting Started

### Prerequisites

- **JDK 25**
- **Docker**

1. Clone repositories 
```sh
./clone_all.sh
```
2. Create .env
```sh
cp .env.example .env
```
3. Start containers
```sh
docker compose up --build
   ```

If on step 3 docker shows smth like that:

#22 [receiving-service builder 5/7] RUN ./mvnw dependency:go-offline
#22 0.647 /bin/sh: 1: ./mvnw: not found
#22 ERROR: process "/bin/sh -c ./mvnw dependency:go-offline" did not complete successfully: exit code: 127

delete repos and execute
```sh
git config --global core.autocrlf false
   ```

### Kubernetes

Using Hyper-V (run PowerShell as Administrator)

Start minikube

```shell
minikube start
```
If ingress is not added as addon

```shell
minikube addons enable ingress   # one-time
```

Build containers and load them into minikube

```shell
docker build -t receiving-service:v1 ./receiving-service
docker build -t auth-service:v1 ./auth-service
docker build -t api-gateway:v1 ./api-gateway

minikube image load receiving-service:v1
minikube image load auth-service:v1
minikube image load api-gateway:v1
```

Apply manifests

```shell
kubectl apply -f k8s/ --recursive
```

Open the cluster through NGINX (leave running, then use http://localhost)

```shell
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80
```

To rebuilding an image (example)

```shell
docker build -t api-gateway:v1 ./api-gateway
minikube image load --overwrite api-gateway:v1
kubectl rollout restart deployment api-gateway
```


## Next Steps
- **Simple implementations of Notification and Inventory services**: For asynchronous messaging practice (Kafka) and Saga transactions.
- **Observability**: Try out Micrometer, Prometheus, Grafana, and OpenTelemetry.
- **Outbox pattern**: Implement the Transactional Outbox pattern with Debezium for reliable Kafka event publishing.
- **Prod environment**: CI/CD and hosting on real server

