#!/usr/bin/env bash
set -euo pipefail
copyq eval '
var s = str(clipboard());
s = s.split("\r").join(" ").split("\n").join(" ");
if (s.length > 30) s = s.slice(0,30) + "…";
print(s);
'

