# 🐘 Event-Driven Architecture with PostgreSQL and Go

This project demonstrates how to build an Event-Driven Architecture (EDA) using PostgreSQL's **LISTEN/NOTIFY** mechanism instead of an external Message Broker. It uses Podman Compose for Infrastructure as Code (IaC) and Go for the Listener Service.

## 🏗️ Architecture

![Architecture](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/pradist/event-driven-pg/main/architecture.puml)

1. **Producer (SQL `INSERT`):** When new data is added to the `orders` table.
2. **PostgreSQL Trigger:** Executes the `notify_new_order()` function.
3. **NOTIFY:** The function sends a JSON payload to the `new_order` channel.
4. **Consumer (Go Listener Service):** This service listens to the `new_order` channel and processes the received payload in real-time.

## 📋 Prerequisites

- **Container Engine:** Docker or Podman.
- **Compose:** Docker Compose or Podman Compose.
- **Go (Optional):** For developing the Listener Service (the Dockerfile handles the build automatically).
- **make:** For running simple commands (Unix/Linux/macOS).

## ⚙️ Setup & Installation

Use the provided `Makefile` to manage the project:

### 1. Build and Deploy Infrastructure

This command will create the PostgreSQL Server and Listener Service (including building the Go Binary inside the container).

```bash
make up
```

This command will open a shell into the PostgreSQL Server container.

```bash
make shell
```

This command will insert some sample data into the `orders` table.

```sql
INSERT INTO orders (customer_name, amount) VALUES ('Sombat', 999.50);
INSERT INTO orders (customer_name, amount) VALUES ('Chalerm', 500.00);
```
