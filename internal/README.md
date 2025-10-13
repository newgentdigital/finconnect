This directory contains private application code that should not be imported by external packages.

### Package guidelines

- Code in `internal/` should not be imported by packages outside the module.
- Use clear package names that reflect their purpose.
- Keep business logic in services, data access in database packages.
- Models should be simple structs with JSON/database tags.
- Handlers should be thin and delegate to services.

### Dependencies

Internal packages can import:

- Standard library packages
- Third-party packages (Gin, Viper, etc.)
- Other internal packages within the same module

External packages cannot import internal packages.
