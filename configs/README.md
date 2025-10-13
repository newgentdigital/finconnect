This directory contains configuration files, database migrations, and initialization scripts.

### Configuration

The API supports multiple configuration sources:

1. Environment variables (highest priority)
2. YAML configuration files
3. Default values (lowest priority)

### Environment variables

Copy `.env.example` to `.env` and configure:

```bash
cp ../.env.example .env
```

### Database initialization

The `init.sql` file contains:

- Table creation scripts
- Index definitions
- Trigger functions
- Initial data (if needed)

All database initialization runs automatically on first start. Future database migrations should run automatically where possible.
