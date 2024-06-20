#!/usr/bin/env bash

function __hosts() {
    awk '
        $1 == "Host" {
            host = $2;
            next;
        }
        $1 == "DynamicForward" || $1 == "LocalForward" {
            print host;
        }
    ' "$1" | sort | uniq
}

for h in $(__hosts ~/.ssh/config); do
    echo $h
done
