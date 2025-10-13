.PHONY: help run build test clean docs install dev docker

# Default target
help:
	@echo "Commands for developing Finconnect API"
	@echo "make install         	- Install dependencies and tools"
	@echo "make dev             	- Run in development mode"
	@echo "make build           	- Build the API binary"
	@echo "make test            	- Run tests"
	@echo "make test-cover      	- Run tests with coverage"
	@echo "make test-integration	- Run integration tests"
	@echo "make docs            	- Generate Swagger documentation"
	@echo "make clean           	- Clean build artifacts"
	@echo "make lint            	- Run linters"
	@echo "make fmt             	- Format code"

# Install dependencies and tools
install:
	@echo "Installing dependencies..."
	go mod download
	go mod verify
	@echo "Installing swag..."
	go install github.com/swaggo/swag/cmd/swag@latest
	@echo "Done!"

# Run in development mode with hot reload (requires air)
dev:
	@echo "Starting development server..."
	@if command -v air > /dev/null; then \
		air; \
	else \
		echo "air not found. Install with: go install github.com/air-verse/air@latest"; \
		echo "Running without hot reload..."; \
		go run main.go; \
	fi

# Build the API binary
build:
	@echo "Building API binary..."
	go build -ldflags="-s -w" -o bin/api main.go
	@echo "Binary created at bin/api"

# Run tests
test:
	@echo "Running tests..."
	go test -short -v ./internal/...

# Run tests with coverage
test-cover:
	@echo "Running tests with coverage..."
	go test -short -coverprofile=coverage.out ./internal/...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	@echo "Note: Requires PostgreSQL and Redis to be running"
	go test -tags=integration -v ./internal/integration/...

# Generate Swagger documentation
docs:
	@echo "Generating Swagger documentation..."
	@if command -v swag > /dev/null; then \
		swag init -g main.go -o docs --parseDependency --parseInternal; \
	else \
		echo "Installing swag..."; \
		go install github.com/swaggo/swag/cmd/swag@latest; \
		swag init -g main.go -o docs --parseDependency --parseInternal; \
	fi
	@echo "Documentation generated in docs/"

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...
	@echo "Code formatted!"

# Run linters
lint:
	@echo "Running linters..."
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found. Install from: golangci-lint.run/usage/install/"; \
		go vet ./...; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -rf bin/
	rm -rf docs/swagger.json docs/swagger.yaml
	rm -f coverage.out coverage.html
	@echo "Clean complete!"
