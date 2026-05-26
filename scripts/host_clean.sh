#!/usr/bin/env bash
# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

# sets the log's color.
red='\e[1;31m'
gre='\e[1;32m'
end='\e[0m'

# sets the correct cmd to stop the shell script.
[[ "$0" == "$BASH_SOURCE" ]] && ret=exit || ret=return

# checks if the px4 repo exists.
PX4_REPO_ROOT="${REPO_ROOT}/external/PX4-Autopilot"

if [[ ! -d "${PX4_REPO_ROOT}/.git" ]]; then
    echo -e "${red}[ERROR]${end} px4 repo not found: ${PX4_REPO_ROOT}"
    echo -e "${gre}[INFO]${end} plz run \`omni host make host-init\`"
    ${ret} 1
fi

# cleans the px4 sitl firmware.
echo -e "${gre}[INFO]${end} cleaning px4 sitl firmware"

make -C "${PX4_REPO_ROOT}" clean
echo -e "${gre}[INFO]${end} px4 sitl firmware clean completed"

# finishs the host clean work.
echo -e "${gre}[INFO]${end} host clean completed"
