# MCP Server

Demo for using the Oracle Autonomous Database MCP Server.

The demo prepares a database user, registers a PL/SQL tool with `DBMS_CLOUD_AI_AGENT`, and calls that tool from a Python MCP client over HTTP transport.

## Files

- `test_mcp_adb.py`: Python client that authenticates with the ADB Data Access endpoint, opens an MCP session, and calls the `MY_RUN_SQL_TOOL` tool.
- `sql/01_setup_admin.sql`: administrative script that creates and enables the `MCP_USER` user.
- `sql/02_setup_mcp_user.sql`: script executed as `MCP_USER` to create the `RUN_SQL` function and register it as an MCP tool.

## How It Works

1. Autonomous Database must have the MCP Server enabled through the `adb$feature` tag.
2. `01_setup_admin.sql` creates the `MCP_USER` user, grants roles, enables ORDS/Data Sharing, and enables resources such as Graph, Spatial, and OML.
3. `02_setup_mcp_user.sql` creates the `RUN_SQL(query, offset, limit)` PL/SQL function, which executes a paginated `SELECT` query and returns the result as JSON.
4. The same function is registered as the `MY_RUN_SQL_TOOL` tool through `DBMS_CLOUD_AI_AGENT.CREATE_TOOL`.
5. The Python client reads the user password from OCI Vault, requests a bearer token from `/adb/auth/v1/databases/{ADB_OCID}/token`, and uses that token to connect to the MCP endpoint `/adb/mcp/v1/databases/{ADB_OCID}`.
6. After initializing the MCP session, the client lists the available tools and calls `MY_RUN_SQL_TOOL` with a sample query.

## Prerequisites

- Python 3.12 or later
- Dependencies installed with `uv`
- Local OCI CLI/config file at `~/.oci/config`, using the `DEFAULT` profile
- Secret in OCI Vault containing the `MCP_USER` password
- Autonomous Database with MCP Server enabled
- OCI permission to read the Vault secret

Expected variables in `.env`:

```env
ADB_REGION=""
ADB_OCID=""
ADB_USER="MCP_USER"
ADB_SECRET_OCID=""
```

Use `.env_example` as a reference.

## Database Setup

Run `sql/01_setup_admin.sql` with an Autonomous Database administrator user.

Before running it, update the password in:

```sql
CREATE USER MCP_USER IDENTIFIED BY "insert_your_password";
```

Then connect as `MCP_USER` and run:

```text
mcp_server/sql/02_setup_mcp_user.sql
```

At the end, confirm that the tool appears in `USER_AI_AGENT_TOOLS`.

## Running

From the repository root:

```powershell
uv sync
Copy-Item .env_example .env
```

Fill the `.env` file with the real values and run:

```powershell
uv run python mcp_server/test_mcp_adb.py
```

The script should print authentication/connection timings, call `MY_RUN_SQL_TOOL`, and display the rows returned by the query:

```sql
SELECT username FROM all_users WHERE oracle_maintained = 'N'
```

## Notes

- The current implementation reads OCI credentials from `~/.oci/config` and sets the region from `ADB_REGION`.
- The access token is cached in memory and refreshed before expiration.
- The tool is designed for read-only queries. Pass only `SELECT` statements without a trailing semicolon.
- Do not commit `.env`, because it references sensitive tenancy resources.
