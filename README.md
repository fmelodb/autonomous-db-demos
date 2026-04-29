# Autonomous DB Demos

Collection of demos for exploring Oracle Autonomous Database features.

Each subfolder is an independent demo and contains its own `README.md` with purpose, prerequisites, and usage instructions.

## Demos

- `mcp_server`: example that consumes the native Autonomous Database MCP Server, using token authentication and a SQL tool registered in the database.

## Structure

```text
.
|-- mcp_server/
|-- pyproject.toml
`-- uv.lock
```

## General Requirements

- Python 3.12 or later
- `uv` for Python environment management
- Access to an OCI tenancy and an Oracle Autonomous Database

Read each demo README before running it.
