import asyncio
import base64
import json
import os
import threading
import time
from dataclasses import dataclass
from typing import Optional
from dotenv import load_dotenv

import httpx
import oci
from mcp import ClientSession
from mcp.client.streamable_http import streamable_http_client

# Load variables from the .env file.
load_dotenv()

# === Environment-based configuration ===
REGION         = os.environ["ADB_REGION"]        # e.g.: "sa-saopaulo-1"
DB_OCID        = os.environ["ADB_OCID"]          # ADB OCID
DB_USER        = os.environ["ADB_USER"]          # e.g.: "MCP_USER"
SECRET_OCID    = os.environ["ADB_SECRET_OCID"]   # Vault secret OCID

BASE_URL  = f"https://dataaccess.adb.{REGION}.oraclecloudapps.com"
TOKEN_URL = f"{BASE_URL}/adb/auth/v1/databases/{DB_OCID}/token"
MCP_URL   = f"{BASE_URL}/adb/mcp/v1/databases/{DB_OCID}"


# ---------------------------------------------------------------------------
# OCI Vault: password retrieval
# ---------------------------------------------------------------------------

def _build_secrets_client() -> oci.secrets.SecretsClient:
    """
    Tries Instance Principal first (production on an OCI VM);
    falls back to API Key (~/.oci/config) when not running on an OCI instance.
    
    -- uncomment here for using instance principal instead of oci/config file
    
    try:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        return oci.secrets.SecretsClient(config={}, signer=signer)
    except Exception:
    """
    config = oci.config.from_file()  # reads ~/.oci/config, DEFAULT profile
    config["region"] = os.environ["ADB_REGION"]
    return oci.secrets.SecretsClient(config)


def get_db_password() -> str:
    """Reads the MCP_USER password from OCI Vault."""
    client = _build_secrets_client()
    bundle = client.get_secret_bundle(secret_id=SECRET_OCID).data # type: ignore
    encoded = bundle.secret_bundle_content.content   # base64
    return base64.b64decode(encoded).decode("utf-8")


# ---------------------------------------------------------------------------
# Bearer token cache with automatic refresh
# ---------------------------------------------------------------------------

@dataclass
class _CachedToken:
    value: str
    expires_at: float   # epoch seconds


class TokenManager:
    """
    Caches the bearer token in memory and refreshes it before expiration.
    Thread-safe: multiple threads requesting a token at the same time trigger
    only one refresh.
    """

    # Refresh when the token has less than this remaining lifetime.
    REFRESH_MARGIN_SECONDS = 5 * 60   # 5 minutes
    DEFAULT_TTL_SECONDS    = 60 * 60  # fallback when the API does not return expires_in

    def __init__(self, db_user: str):
        self._db_user = db_user
        self._cached: Optional[_CachedToken] = None
        self._lock = threading.Lock()

    def get_token(self) -> str:
        # Fast path: token is still valid, no heavy lock needed.
        cached = self._cached
        if cached and cached.expires_at - time.time() > self.REFRESH_MARGIN_SECONDS:
            return cached.value

        # Slow path: refresh required.
        with self._lock:
            # Re-check inside the lock because another thread may have refreshed.
            cached = self._cached
            if cached and cached.expires_at - time.time() > self.REFRESH_MARGIN_SECONDS:
                return cached.value

            self._cached = self._fetch_new_token()
            return self._cached.value

    def _fetch_new_token(self) -> _CachedToken:
        password = get_db_password()  # reads from Vault only when refreshing
        payload = {
            "grant_type": "password",
            "username":   self._db_user,
            "password":   password,
        }
        headers = {"Content-Type": "application/json", "Accept": "application/json"}

        resp = httpx.post(TOKEN_URL, json=payload, headers=headers, timeout=30.0)
        resp.raise_for_status()
        data = resp.json()

        token = data["access_token"]
        ttl   = int(data.get("expires_in", self.DEFAULT_TTL_SECONDS))
        expires_at = time.time() + ttl

        print(f"[token] new token obtained, valid for ~{ttl}s")
        return _CachedToken(value=token, expires_at=expires_at)


# ---------------------------------------------------------------------------
# Test case MCP
# ---------------------------------------------------------------------------
async def run_test(token_manager: TokenManager):
    t0 = time.perf_counter()

    auth_headers = {"Authorization": f"Bearer {token_manager.get_token()}"}
    t1 = time.perf_counter()
    print(f"[timing] token obtained: {t1 - t0:.2f}s")

    async with httpx.AsyncClient(
        headers=auth_headers,
        timeout=httpx.Timeout(300.0, connect=30.0),
    ) as http_client:

        async with streamable_http_client(MCP_URL, http_client=http_client) as (read, write, _):
            t2 = time.perf_counter()
            print(f"[timing] transport opened: {t2 - t1:.2f}s")

            async with ClientSession(read, write) as session:
                await session.initialize()
                t3 = time.perf_counter()
                print(f"[timing] session.initialize(): {t3 - t2:.2f}s")

                tools_result = await session.list_tools()
                t4 = time.perf_counter()
                print(f"[timing] list_tools(): {t4 - t3:.2f}s")

                query = "SELECT username FROM all_users WHERE oracle_maintained = 'N'"
                result = await session.call_tool(
                    "MY_RUN_SQL_TOOL",
                    arguments={"QUERY": query, "OFFSET": 0, "LIMIT": 10},
                )
                t5 = time.perf_counter()
                print(f"[timing] call_tool(): {t5 - t4:.2f}s")
                print(f"[timing] TOTAL: {t5 - t0:.2f}s")

                for block in result.content:
                    if block.type == "text":
                        rows = json.loads(block.text)
                        print(f"\n[result: {len(rows)} row(s)]")
                        for row in rows:
                            print(f"  {row}")


if __name__ == "__main__":
    token_manager = TokenManager(db_user=DB_USER)
    asyncio.run(run_test(token_manager))
