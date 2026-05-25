#!/usr/bin/env bash
# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

red='\e[1;31m'
gre='\e[1;32m'
end='\e[0m'

[[ "$0" == "$BASH_SOURCE" ]] && ret=exit || ret=return

print_help_usage() {
cat <<USAGE

Usage:
    source set_env.sh

Description:
    setup Omni-FlySim dev environment base conda.

OPTIONS:
    -h, --help
        display this help message.

    -u, --update
        auto update the dev envs.

USAGE
}

OPTION_SHOW_HELP="false"
OPTION_UPDATE_ENV="false"
OPTION_DEBUG="false"

SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="${SCRIPT_DIR}"

parse_commandline() {
    local key
    while test $# -gt 0
    do
        key="$1"
        case "$key" in
            -u|--update)
                OPTION_UPDATE_ENV="true"
                OPTION_DEBUG="true"
                ;;
            -h|--help)
                OPTION_SHOW_HELP="true"
                ;;

            *)
                echo -e "${red}[ERROR]${end} unknown option: $1" >&2
                OPTION_SHOW_HELP="true"
                ;;
        esac
        shift
    done
}

parse_commandline "$@"

if [ "${OPTION_SHOW_HELP}" = "true" ]; then
    print_help_usage
    ${ret} 0
fi

check_os() {
    local os_name=$(uname -s)
    local version="unknown"

    if [ "${os_name}" = "Linux" ]; then
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            os_name=${NAME}
            version=${VERSION_ID}
        elif type lsb_release >/dev/null 2>&1; then
            os_name=$(lsb_release -si 2>/dev/null)
            version=$(lsb_release -sr 2>/dev/null)
        elif [ -f /etc/lsb-release ]; then
            source /etc/lsb-release
            os_name=${DISTRIB_ID}
            version=${DISTRIB_RELEASE}
        else
            version="unknown"
        fi
    fi

    if [ "${OPTION_DEBUG}" = "true" ]; then
        echo -e "${gre}[INFO]${end} host system: ${os_name}-${version}" >&2
    fi

    echo "${os_name}"
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${red}[ERROR]${end} command not found: $1" >&2
        return 1
    fi
}

check_and_update_on_ubuntu() {
    echo -e "${gre}[INFO]${end} installing ubuntu packages"

    sudo apt update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git \
        build-essential \
        cmake \
        python3 \
        python3-pip \
        python3-venv \
        libgl1 \
        libglew2.2 \
        libglfw3 \
        libxcursor1 \
        libxinerama1 \
        libxrandr2 \
        libxi6

    echo -e "${gre}[INFO]${end} checking required commands"

    check_command git || ${ret} 1
    check_command python3 || ${ret} 1
    check_command pip3 || ${ret} 1
    check_command cmake || ${ret} 1

    echo -e "${gre}[INFO]${end} ubuntu package setup completed"
}

check_and_update_on_conda() {
    echo -e "${gre}[INFO]${end} installing conda packages"

    python -m pip install -r "${REPO_ROOT}/requirements.txt"
    echo -e "${gre}[INFO]${end} conda package setup completed"
}

run_host() {
    cmd=$*
    /bin/bash -c "${cmd}"
}

unset -f run_omni_cmd 1>/dev/null 2>&1

run_omni_cmd() {
    if [ $# -lt 2 ]
    then
        echo -e "${red}[ERROR]${end} plz input the correct cmd "
        omni_help
        return
    fi

    if [ "$1" = "host" ]
    then
        shift
        run_host $*
    else
        omni_help
    fi
}

unset -f omni_help 1>/dev/null 2>&1

omni_help() {
    echo "USAGE:"
    echo "      omni platform [cmd]"
    echo "      platform: "
    echo "             host         --work on host env"
    echo "             other        --coming soon"
    echo "Demo: "
    echo "      omni host make help"
}

unset -f omni 1>/dev/null 2>&1

omni() {
    if [ "$1" = "host" ]
    then
        run_omni_cmd $*
    else
        echo -e "${red}[ERROR]${end} plz select a support platform "
        omni_help
    fi
}

if [ "${OPTION_UPDATE_ENV}" = "true" ]; then
    case "$(check_os)" in
        Ubuntu)
            check_and_update_on_ubuntu
            check_and_update_on_conda
            ;;
        Darwin)
            ;;
    esac
fi

unset OPTION_SHOW_HELP
unset OPTION_UPDATE_ENV
unset OPTION_DEBUG

echo -e "${gre}[INFO]${end} sim enviroment setup ok."
echo -e "using 'omni help' to continue..."
