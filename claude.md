# LunchboxAPI - Claude Knowledge Base

## Project Overview
LunchboxAPI is a Phoenix-based REST API application for managing food items. It's designed to work with both CockroachDB (for production) and PostgreSQL (for development/testing), demonstrating a flexible database approach.

## Key Technologies
- **Framework**: Phoenix 1.8 (Elixir web framework)
- **Language**: Elixir 1.18.4
- **Database**: PostgreSQL (dev/test), CockroachDB (production)
- **ORM**: Ecto with SQL adapter
- **Authentication**: HTTP Basic Auth
- **Development Environment**: Devbox with Node.js 22.14.0
- **Deployment**: Gigalixir (cloud platform)

## Project Structure

### Core Application (`lib/lunchbox_api/`)
- `application.ex` - OTP application supervisor
- `repo.ex` - Ecto repository configuration
- `release.ex` - Release management utilities

### Business Logic (`lib/lunchbox_api/lunchbox/`)
- `lunchbox.ex` - Context module (business logic layer)
- `food.ex` - Food schema and changeset validation

### Web Layer (`lib/lunchbox_api_web/`)
- `router.ex` - Route definitions with authentication pipelines
- `endpoint.ex` - Phoenix endpoint configuration
- `controllers/` - HTTP request handlers
- `views/` - JSON response formatting
- `templates/` - HTML templates (minimal usage)

## Domain Model

### Food Entity
```elixir
schema "foods" do
  field :name, :string      # Required
  field :status, :string    # Required
  timestamps()              # inserted_at, updated_at
end
```

## API Endpoints

### Authentication
- **Method**: HTTP Basic Auth
- **Environment Variables**: 
  - `BASIC_AUTH_USERNAME` (default: "specialUserName")
  - `BASIC_AUTH_PASSWORD` (default: "superSecretPassword")

### Food Management (`/api/v1/foods`)
- `GET /api/v1/foods` - List all foods
- `POST /api/v1/foods` - Create new food
- `GET /api/v1/foods/:id` - Get specific food
- `PUT /api/v1/foods/:id` - Update food
- `DELETE /api/v1/foods/:id` - Delete food

### Utility Endpoints
- `GET /api/v1/time_now` - Returns dummy time string (for testing)

## Development Workflow

### Environment Setup
```bash
# Using devbox (preferred)
devbox shell

# Manual setup
export BASIC_AUTH_USERNAME=specialUserName
export BASIC_AUTH_PASSWORD=superSecretPassword
```

### Testing
```bash
# Start postgresql DB process before attempt to run full test suite
devbox services up -b
# Run all tests
devbox run test
# OR
BASIC_AUTH_USERNAME=specialUserName BASIC_AUTH_PASSWORD=superSecretPassword mix test

# Run specific test file
mix test test/path/to/test_file.exs
```

### Development Server
```bash
# Start postgresql DB process before attempt to start dev server
devbox services up -b
# Using devbox
devbox run dev
# OR
mix phx.server
```

### Database Operations
```bash
# Start postgresql DB process before attempt to create/migrate/seed DB
devbox services up -b
mix ecto.setup    # Create, migrate, seed
mix ecto.migrate  # Run migrations
mix ecto.reset    # Drop and recreate
```

## Configuration Patterns

### Environment-Specific Config
- `config/config.exs` - Base configuration
- `config/dev.exs` - Development (PostgreSQL)
- `config/test.exs` - Testing (PostgreSQL with sandbox)
- `config/prod.exs` - Production (CockroachDB/PostgreSQL)

### Database Configuration
Development uses PostgreSQL with standard credentials:
```elixir
config :lunchbox_api, LunchboxApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "lunchbox_api_dev",
  hostname: "localhost"
```

## Testing Patterns

### Controller Tests
- Use `LunchboxApiWeb.ConnCase` for integration tests
- Basic auth setup in test setup blocks
- JSON response assertions with `json_response/2`
- HTTP status code verification

### Test Structure Example
```elixir
setup %{conn: _conn} do
  conn = build_conn()
    |> using_basic_auth(@username, @password)
    |> put_req_header("accept", "application/json")
  {:ok, conn: conn}
end
```

## Deployment Architecture

### Local Development
- PostgreSQL database
- Phoenix server on port 4000
- Basic auth for API access

### Production (Gigalixir)
- Elixir releases (OTP)
- PostgreSQL managed database
- Environment-based configuration
- Git-based deployment

### CockroachDB Cluster (Alternative)
- 3-node cluster setup for high availability
- Insecure mode for development
- Admin UI on port 8080
- Multiple connection ports (26257, 26258, 26259)

## Code Quality & Conventions

### Phoenix Context Pattern
- Business logic in context modules (`LunchboxApi.Lunchbox`)
- Controllers delegate to contexts
- Schemas define data structure and validation
- Repositories handle data persistence

### Error Handling
- Fallback controller for consistent error responses
- Changeset validation for data integrity
- Pattern matching for control flow

### Security
- Basic HTTP authentication on all API endpoints
- Environment variable configuration
- No sensitive data in version control

## Development Tools

### Devbox Configuration
- Isolated development environment
- Automatic dependency management
- Pre-configured scripts for common tasks
- Environment variable setup

### Asset Pipeline
- ESBuild for JavaScript bundling
- Tailwind CSS for styling
- Live reload in development
- Asset optimization for production

## Key Learning Points

1. **Flexible Database Support**: Code works with both PostgreSQL and CockroachDB
2. **Environment-Driven Configuration**: Heavy use of environment variables
3. **Phoenix Context Pattern**: Clear separation of concerns
4. **Test-Driven Development**: Comprehensive test coverage
5. **Cloud-Ready**: Designed for easy deployment to Gigalixir
6. **Development Experience**: Devbox provides consistent environment

## Common Commands Reference

```bash
# Development
devbox services up -b   # Startup postgresql DB process via process-compose in background
devbox services down    # Shutdown any running processes started by 'devbox service up -b'
devbox run dev          # Start development server
devbox run test         # Run test suite
mix deps.get           # Install dependencies
mix ecto.migrate       # Run database migrations

# Testing
mix test --cover       # Run tests with coverage
mix test path/to/test  # Run specific test

# Database
mix ecto.create        # Create database
mix ecto.drop          # Drop database
mix ecto.reset         # Reset database

# Production
MIX_ENV=prod mix release  # Build production release
gigalixir ps:migrate      # Run migrations on Gigalixir
```

This knowledge base captures the essential patterns and practices for working effectively with the LunchboxAPI codebase.
