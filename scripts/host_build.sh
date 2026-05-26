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

# builds the px4 sitl firmware.
echo -e "${gre}[INFO]${end} building px4 sitl firmware"

make -C "${PX4_REPO_ROOT}" px4_sitl_default

# checks if the px4 sitl firmware compiled successfully.
PX4_SITL_FIRMWARE_ROOT="${PX4_REPO_ROOT}/build/px4_sitl_default"
PX4_SITL_BIN="${PX4_SITL_FIRMWARE_ROOT}/bin/px4"
PX4_SITL_ETC="${PX4_SITL_FIRMWARE_ROOT}/etc"
PX4_SITL_ROOTFS="${PX4_SITL_FIRMWARE_ROOT}/rootfs"

if [[ ! -x "${PX4_SITL_BIN}" || ! -d "${PX4_SITL_ETC}" || ! -d "${PX4_SITL_ROOTFS}" ]]; then
    echo -e "${red}[ERROR]${end} px4 sitl firmware build error: missing binary or dirs."
    ${ret} 1
fi

echo -e "${gre}[INFO]${end} px4 sitl firmware build completed"

# finishs the host build work.
echo -e "${gre}[INFO]${end} host build completed"
