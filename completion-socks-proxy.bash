#/usr/bin/env bash

__completions-socks-proxy()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ ${prev} == "-p" ]; then
        COMPREPLY=( $(compgen -W "$(find-socks-proxies.sh)" -- ${cur}) )
    else
        COMPREPLY=( $(compgen -W "-p -v -h" -- ${cur}) )
    fi
}

complete -F __completions-socks-proxy socks-proxy.sh
