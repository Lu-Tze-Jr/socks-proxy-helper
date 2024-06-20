#!/usr/bin/env bash

bold=$(tput bold)
normal=$(tput sgr0)

_usage_str="
${bold}Usage:${normal} ${bold}$(basename $0)${normal} ${bold}[OPTIONS]${normal}

${bold}Options:${normal}
  ${bold}-p${normal} <proxy-host>     A defined proxy host (~/.ssh/config)
  ${bold}-v${normal}                  Verbose
  ${bold}-h${normal}                  Help
"

_description_str="
${bold}$(basename $0)${normal}

Kills old sessions/processes for SOCKS proxies, and starts a new one.

${bold}Hint:${normal} Using the same local port for your ssh proxy definitions,
you can utilize a static proxy config in your browser, and quickly switch proxy
hosts with this script instead.

${bold}Input:${normal} proxy-host (should be from you ssh config)

${bold}Result:${normal} A SOCKS proxy session for the requested proxy-host, if valid

"

__usage() {
    echo "${_usage_str}" 1>&2;
    exit 1;
}

__description() {
    echo "${_description_str}" 1>&2;
}

# Testing a cool join technique
# https://dev.to/meleu/how-to-join-array-elements-in-a-bash-script-303a
__join() {
    local _separator=${1-}
    local _first=${2-}

    if shift 2; then
        printf '%s' "${_first}" "${@/#/$_separator}"
    fi
}

while getopts ":hp:v" opt; do
    case "${opt}" in
        h)
            __usage
            ;;
        p)
            proxy_host=${OPTARG}
            ;;
        v)
            verbose=true
            ;;
        *)
            __description
            __usage
            ;;
    esac
done

# Not really needed here, but good to remember for non-getopts input... :-)
# shift "$((OPTIND-1))"

if [ -z "${proxy_host}" ] ; then
    __description
    __usage
fi

readarray -t possible_proxies < <( find-socks-proxies.sh )

if [[ " ${possible_proxies[*]} " =~ [[:space:]]${proxy_host}[[:space:]] ]]; then
    if [[ ${verbose} = true ]]; then
        echo "Proxy $proxy_host seems valid"
        echo "Killing any running sessions..."
    fi
    for p in "${possible_proxies[@]}"; do
        if [[ ${verbose} = true ]]; then
            echo -e "\tpkill -f 'ssh ${p}'"
        fi
        $(pkill -f "ssh ${p}")
    done
    if [[ ${verbose} = true ]]; then
        echo "...done"
        echo -n "Starting new proxy session with ${proxy_host}..."
    fi
    ssh ${proxy_host}
    if [[ ${verbose} = true ]]; then
        echo "done"
    fi
    exit 0
fi

if [[ ! " ${possible_proxies[*]} " =~ [[:space:]]${proxy_host}[[:space:]] ]]; then
    printf '\nProxy %s%s%s seems to be undefined?\n' "${bold}" "${proxy_host}" "${normal}"
#     Why doesn't this work directly.... ?
#     printf '\nThese are your defined proxies: %s\n' "${possible_proxies[*]// /, }"
    possible_proxies_str="${possible_proxies[*]}"
    printf '\nThese are your defined proxies: %s%s%s\n' "${bold}" "${possible_proxies_str// /${normal}, ${bold}}" "${normal}"
#     printf '\nThese are your defined proxies: %s%s%s\n' "${bold}" "$(__join ', ' ${possible_proxies[*]})" "${normal}"
    __usage
    exit 2
fi

