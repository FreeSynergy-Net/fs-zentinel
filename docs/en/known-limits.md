# Known limits and open items

git-bug is not set up in the FreeSynergy repositories yet (it will be set up the same way for all three server repos later), so open items live here. Each entry says what we saw, how we know, and what we decided. "Verified" means we ran it ourselves in the local test (`fs-kanidm/scripts/test/podman-stack.sh`); "from upstream docs" means we only read it and have not tested it.

## 1. `ca-cert` in the KDL did not work for a private CA (Zentinel 26.11_1)

> Not checked in operation with 26.11_6 (the pinned version since 2026-11-23; only `zentinel test --strict` on the templates); the changelog of 26.11_3 names no change to the upstream TLS connection (the new TLS options concern only the gRPC path to agents). The finding below is from 26.11_1.

- **Verified:** An upstream with `tls { sni "..." ca-cert "/path/ca.pem" }` still failed with `invalid peer certificate: UnknownIssuer` when the upstream (Kanidm 1.12.0) used a certificate from a private CA; the gate answered 502. With the environment variable `SSL_CERT_FILE=<ca.pem>` on the Zentinel process the same setup worked, and the local test uses that variable.
- **Unverified:** why. The config crate in upstream's main branch has a function `build_upstream_tls_config` (`crates/proxy/src/tls.rs`) that reads `ca_cert`; whether it is wired to the real upstream connection in 26.11_1 we have not checked.
- **Decision:** Our template carries no `ca-cert`. On the real server Kanidm has a public certificate for its name, which the system roots verify. For a private CA use `SSL_CERT_FILE`. If this proves a Zentinel bug, a short upstream issue follows later; none now.

## 2. Control plane: protocol stability unknown

- **From upstream docs (not tested by us):** The upstream control plane (`zentinelproxy/zentinel-control-plane`, Apache-2.0) documents a node API under `/api/v1` ([docs/PROXY-REGISTRATION.md](https://github.com/zentinelproxy/zentinel-control-plane/blob/main/docs/PROXY-REGISTRATION.md), [priv/static/openapi.yaml](https://github.com/zentinelproxy/zentinel-control-plane/blob/main/priv/static/openapi.yaml)). Its README calls the project "Beta" ([README](https://github.com/zentinelproxy/zentinel-control-plane/blob/main/README.md)); we found no compatibility or versioning promise in the docs we read.
- **Decision:** The upstream agent `zentinel-cp-agent` is not mirrored. FreeSynergy builds its own control plane in Rust after 3b and checks the protocol again then. Until then fs-zentinel manages the KDL directly: validate with `zentinel test -c`, replace the file atomically, then hot reload. Hot reload by SIGHUP is stated in upstream's README ([Features, "Hot reload"](https://github.com/zentinelproxy/zentinel/blob/26.11_1/README.md)); we have **not** tested it yet.

## 3. No login in the gate (later)

- **From upstream docs:** The upstream auth agent only checks bearer tokens against a JWKS (marked experimental) and does no browser login ([zentinel-agent-auth README](https://github.com/zentinelproxy/zentinel-agent-auth/blob/v0.3.0/README.md)).
- **Decision:** Later a login agent for Zentinel (forward auth against Kanidm). Programs with a login sign in to Kanidm themselves by OIDC. See [ROADMAP](../ROADMAP.md).

## 4. No documented HTTP to HTTPS redirect

- **Verified:** with `service-type "builtin"` and no handler, `zentinel test` warned that the route is served as `web` and the setting is ignored; we found no documented redirect handler. The template therefore has no plain-HTTP listener. See [ROADMAP](../ROADMAP.md).

## 5. Hetzner DNS-01 (wildcard certificates): new API, new token (from Zentinel 26.11_3)

- **From the maker (changelog and source of 26.11_3, not tested by us against Hetzner):** since 26.11_3 the `hetzner` provider talks to the Hetzner Cloud API (`https://api.hetzner.cloud/v1`, zones and RRSets) with `Authorization: Bearer <token>`. In 26.11_1 and 26.11_2 it talked to the `dns.hetzner.com` API that was shut down on 2026-05-27; every DNS-01 issuance failed with those versions. The configuration stays the same, only the token changes.
- **Token:** a **Hetzner Cloud** API token with **Read & Write** permission in the **project that holds the zone** (Hetzner Console, Security, API tokens). **Old DNS Console tokens do not work**; Zentinel then reports an authentication error that says so. The token stays in a file as before (`credentials-file`, owner `zentinel`, mode `0600`, put there by the person, never in a repository).
- **Checked by us:** syntax only: `zentinel test -c` accepts the rendered DNS-01 template (`examples/zentinel-dns01-hetzner.kdl.in`) with the 26.11_3 program. **Not checked:** a real issuance against Hetzner and Let's Encrypt; the staging run (step 3 in `examples/README.md`) is the proof.
- **Decision:** no own webhook adapter for Hetzner DNS is needed: Zentinel 26.11_3 supports Hetzner itself. The file stays a template; HTTP-01 remains the way for the first start.

Language: [Deutsch](../de/known-limits.md)
