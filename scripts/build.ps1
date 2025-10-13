# Finconnect API PowerShell scripts
# Run with: .\scripts\build.ps1 [command]

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host "Commands for developing Finconnect API" -ForegroundColor Cyan
    Write-Host ".\scripts\build.ps1 install             - Install dependencies and tools"
    Write-Host ".\scripts\build.ps1 dev                 - Run in development mode"
    Write-Host ".\scripts\build.ps1 build               - Build the API binary"
    Write-Host ".\scripts\build.ps1 test                - Run tests"
    Write-Host ".\scripts\build.ps1 test-cover          - Run tests with coverage"
    Write-Host ".\scripts\build.ps1 test-integration    - Run integration tests"
    Write-Host ".\scripts\build.ps1 docs                - Generate Swagger documentation"
    Write-Host ".\scripts\build.ps1 clean               - Clean build artifacts"
    Write-Host ".\scripts\build.ps1 lint                - Run linters"
    Write-Host ".\scripts\build.ps1 fmt                 - Format code"
}

function Install-Dependencies {
    Write-Host "Installing dependencies..." -ForegroundColor Green
    go mod download
    go mod verify
    Write-Host "Installing swag..." -ForegroundColor Green
    go install github.com/swaggo/swag/cmd/swag@latest
    Write-Host "Done!" -ForegroundColor Green
}

function Start-DevServer {
    Write-Host "Starting development server..." -ForegroundColor Green
    if (Get-Command air -ErrorAction SilentlyContinue) {
        air
    } else {
        Write-Host "air not found. Install with: go install github.com/air-verse/air@latest" -ForegroundColor Yellow
        Write-Host "Running without hot reload..." -ForegroundColor Yellow
        go run main.go
    }
}

function Build-Binary {
    Write-Host "Building API binary..." -ForegroundColor Green
    go build -ldflags="-s -w" -o bin/api main.go
    Write-Host "Binary created at bin/api" -ForegroundColor Green
}

function Run-Tests {
    Write-Host "Running tests..." -ForegroundColor Green
    go test -v ./...
}

function Run-TestsWithCoverage {
    Write-Host "Running tests with coverage..." -ForegroundColor Green
    go test -short -coverprofile=coverage.out ./internal/...
    go tool cover -html=coverage.out -o coverage.html
    Write-Host "Coverage report: coverage.html" -ForegroundColor Green
}

function Run-IntegrationTests {
    Write-Host "Running integration tests..." -ForegroundColor Green
    Write-Host "Note: Requires PostgreSQL and Redis to be running" -ForegroundColor Yellow
    go test -tags=integration -v ./internal/integration/...
}

function Generate-Docs {
    Write-Host "Generating Swagger documentation..." -ForegroundColor Green
    if (-not (Get-Command swag -ErrorAction SilentlyContinue)) {
        Write-Host "Installing swag..." -ForegroundColor Green
        go install github.com/swaggo/swag/cmd/swag@latest
    }
    swag init -g main.go -o docs --parseDependency --parseInternal
    Write-Host "Documentation generated in docs/" -ForegroundColor Green
}

function Format-Code {
    Write-Host "Formatting code..." -ForegroundColor Green
    go fmt ./...
    Write-Host "Code formatted!" -ForegroundColor Green
}

function Lint-Code {
    Write-Host "Running linters..." -ForegroundColor Green
    if (Get-Command golangci-lint -ErrorAction SilentlyContinue) {
        golangci-lint run
    } else {
        Write-Host "golangci-lint not found. Install from: golangci-lint.run/usage/install/" -ForegroundColor Yellow
        go vet ./...
    }
}

function Clean-Artifacts {
    Write-Host "Cleaning..." -ForegroundColor Green
    if (Test-Path "bin") {
        Remove-Item -Recurse -Force "bin"
    }
    if (Test-Path "docs/swagger.json") {
        Remove-Item "docs/swagger.json"
    }
    if (Test-Path "docs/swagger.yaml") {
        Remove-Item "docs/swagger.yaml"
    }
    if (Test-Path "coverage.out") {
        Remove-Item "coverage.out"
    }
    if (Test-Path "coverage.html") {
        Remove-Item "coverage.html"
    }
    Write-Host "Clean complete!" -ForegroundColor Green
}

# Execute command
switch ($Command.ToLower()) {
    "help" { Show-Help }
    "install" { Install-Dependencies }
    "dev" { Start-DevServer }
    "build" { Build-Binary }
    "test" { Run-Tests }
    "test-cover" { Run-TestsWithCoverage }
    "test-integration" { Run-IntegrationTests }
    "docs" { Generate-Docs }
    "fmt" { Format-Code }
    "lint" { Lint-Code }
    "clean" { Clean-Artifacts }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
