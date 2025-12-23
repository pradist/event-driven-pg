# Variables
PROJECT_NAME := event-driven-pg
DB_SERVICE := eda_postgres
LISTENER_SERVICE := eda_listener
DB_USER := user
DB_DB := eventdb

.PHONY: up down status logs shell clean

# Start and run all services in the background (-d)
up:
	@echo "Starting up PostgreSQL and Go Listener services..."
	podman-compose up -d

# Stop and remove all services
down:
	@echo "Stopping and removing services..."
	podman-compose down

# Check service status
status:
	@echo "Current service status:"
	podman ps -a -f name=$(PROJECT_NAME)

# Tail logs for the Listener service
logs:
	@echo "Tailing logs for the Listener service (Ctrl+C to stop)..."
	podman logs -f $(LISTENER_SERVICE)

# Enter PostgreSQL Console to trigger events
shell:
	@echo "Entering PostgreSQL shell..."
	@echo "Use 'INSERT INTO orders (customer_name, amount) VALUES (...)' to trigger events."
	@echo "Type '\\q' to exit psql, and 'exit' to exit the container shell."
	podman exec -it $(DB_SERVICE) psql -U $(DB_USER) -d $(DB_DB)

# Clean up: Stop containers, remove images, volumes, and local data
clean: down
	@echo "Cleaning up podman-compose environment..."
	@echo "Removing images..."
	-podman rmi localhost/$(PROJECT_NAME)_listener -f
	-podman rmi localhost/$(PROJECT_NAME)_postgres -f
	@echo "Removing unused volumes..."
	-podman volume prune -f
	@echo "Removing unused networks..."
	-podman network prune -f
	@echo "Removing local pg_data directory..."
	-rm -rf pg_data
	@echo "Full cleanup complete."

# Generate PlantUML diagram (requires Podman/Docker)
diagram:
	@echo "Generating architecture.png..."
	podman run --rm -v $(PWD):/data ghcr.io/plantuml/plantuml -tpng /data/architecture.puml
