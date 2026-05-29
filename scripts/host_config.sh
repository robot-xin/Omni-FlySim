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

# updates the airframe config.
echo -e "${gre}[INFO]${end} updating the airframe config"

cp "${REPO_ROOT}/scripts/22001_mujoco_quadrotor_950" "${PX4_REPO_ROOT}/ROMFS/px4fmu_common/init.d-posix/airframes"

# checks and updates the px4 sitl configs.
echo -e "${gre}[INFO]${end} checking the px4 sitl config"

PX4_MAKEFILE="${PX4_REPO_ROOT}/ROMFS/px4fmu_common/init.d-posix/airframes/CMakeLists.txt"
SCRIPT_MAKEFILE="${REPO_ROOT}/scripts/CMakeLists.txt"
TARGET_CONFIG="+    22001_mujoco_quadrotor_950"

if ! git diff --no-index "$PX4_MAKEFILE" "$SCRIPT_MAKEFILE" | grep -Fq "$TARGET_LINE"; then
    echo -e "${gre}[INFO]${end} px4 sitl config has updated"
    ${ret} 1
fi

cp "$PX4_MAKEFILE" "${REPO_ROOT}/scripts/CMakeLists.txt.bak"
cp "$SCRIPT_MAKEFILE" "$PX4_MAKEFILE"

echo -e "${gre}[INFO]${end} px4 sitl config update completed"

# finishs the host cofig work.
echo -e "${gre}[INFO]${end} host config completed"
