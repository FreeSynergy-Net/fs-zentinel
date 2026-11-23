# Changelog

Changes of the FreeSynergy mirror of Zentinel (not of Zentinel itself; see upstream's CHANGELOG for that). The mirror tag is `v` plus the upstream version.

## v26.11_6 (pinned 2026-11-23)

- Pin raised from upstream `26.11_3` to `26.11_6` in one step (commit `a4e4e803dea5fe6c7a0cd9d5cd4f09d421cbecad`, annotated tag object `89ddb91f5b0088af90d4fe1331c11e51fc55ca19`, released 2026-11-23). Signer identity: `release.yml@refs/tags/26.11_6` (certificate of the linux-amd64 bundle checked; Sigstore chain and Rekor entry not checked by us locally; `cosign verify-blob --bundle` checks them in the mirror run (CI), not on a developer machine).
- Security, upstream 26.11_4 (in this pin): request bodies with a non-visible-ASCII byte in `Content-Type` are inspected (they bypassed body agents under a `waf` block); forwarding headers from untrusted peers are removed; release signatures are checked against the exact signer identity; `bundle install` and `install.sh` refuse an archive whose checksum does not match. Severity and advisory id: not stated in upstream's changelog (not proven).
- Configuration: upstream 26.11_5 makes `zentinel test --strict` reject `logging { level, format }` (ignored settings). Removed from the three templates in `examples/`, replaced by a comment. `--strict` on the rendered templates with 26.11_6: rc 0 (container, no network).
- Also in this pin, upstream 26.11_5, see its changelog: RUSTSEC-2026-0592 (`url`, upstream #817), more forwarding headers from untrusted peers removed (#803), POST retries only with `retry-non-idempotent`, a TLS listener with a missing certificate file stops the start. The shipped upstream unit has `StartLimitIntervalSec=0` (unlimited restarts) and `RestartSteps`/`RestartMaxDelaySec` (systemd older than 254 reports "Unknown key name"); not tested under systemd.
- Debian packages: `zentinel_26.11.6-1_{amd64,arm64}.deb`, to be built only by CI from the reviewed commit. Hetzner DNS-01: template only, see known-limits.

## v26.11_3 (not released yet)

- Pin raised from upstream `26.11_2` to `26.11_3` (commit `2bf39089035e7e77e8d3c1767f98453b09fe4a2a`, annotated tag object `38e7c2b4ef6c72fb7639f2d26999d542ad8ead8f`, released 2026-11-14). Signer identity, workflow SHA and ref in `mirror.toml` read from the maker's 26.11_3 certificate.
- Upstream: Hetzner DNS-01 on the new Cloud API: syntax-checked only, UNTESTED against a live account until the staging run. It needs a new Hetzner Cloud API token with Read & Write in the project of the zone (old DNS Console tokens do not work). See docs/en/known-limits.md, item 5.
- Upstream: agent gRPC TLS options are applied (a configuration error on non-`https://` agent addresses; our default configuration has no agents), `RequestComplete` is sent to agents, WAF content types matched case-insensitively, release binaries no longer report `-dirty`, Gateway API controller on kube 5 (the maker's tarball that we mirror unchanged also contains `zentinel-gateway`, built with kube 5, and `zentinel-echo-agent`; our .deb ships only `zentinel`).
- Examples: the DNS-01 Hetzner template and its guide no longer say "does not work".
- Debian packages: `zentinel_26.11.3-1_{amd64,arm64}.deb`.

## v26.11_2

- Pin on upstream `26.11_2` (commit `ea8ccf037cf62fd5c39b0bc9d7748869a25ea53b`).
