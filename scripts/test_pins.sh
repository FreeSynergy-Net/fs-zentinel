#!/usr/bin/env bash
# Mutation test for the pin cross-check in repo_tool.py: the real mirror.toml must pass, each forged field must fail.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
fail=0
run() { # $1 = python statement mutating dict m; $2 = expect "ok" or "red"
  out="$(python3 -I - "$here/repo_tool.py" "$here/../mirror.toml" "$1" <<'PY'
import importlib.util, sys, tomllib
spec = importlib.util.spec_from_file_location("rt", sys.argv[1]); rt = importlib.util.module_from_spec(spec); spec.loader.exec_module(rt)
m = tomllib.load(open(sys.argv[2], "rb"))
exec(sys.argv[3])
print("red" if rt.pin_errors(m) else "ok")
PY
)"
  if [ "$out" = "$2" ]; then echo "PASS: $1 -> $out"; else echo "FAIL: $1 -> $out (want $2)"; fail=1; fi
}
run "pass" ok
run "m['source']['tag']='26.11_2'" red
run "m['source']['commit']='0'*40" red
run "m['verification']['certificate_github_workflow_sha']='0'*40" red
run "m['verification']['certificate_github_workflow_ref']='refs/tags/26.11_2'" red
run "m['verification']['certificate_identity']=m['verification']['certificate_identity'].replace('26.11_3','26.11_2')" red
run "m['artifact'][0]['name']='zentinel-26.11_2-linux-amd64.tar.gz'" red
run "m['artifact'][2]['name']='zentinel_26.11.2-1_amd64.deb'" red
run "m['build']['deb_revision']=2" red
exit "$fail"
