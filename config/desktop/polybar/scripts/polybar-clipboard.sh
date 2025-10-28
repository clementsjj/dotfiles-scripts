#!/usr/bin/env bash

xclip -o -selection clipboard | tr '\r\n' ' ' | awk '{s=$0} length(s)>30 {s=substr(s,1,15)"…"} {print s}'