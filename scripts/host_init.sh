#!/usr/bin/env bash
# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

# sets the log's color.
red='\e[1;31m'
gre='\e[1;32m'
end='\e[0m'

# sets the correct cmd to stop the shell script.
[[ "$0" == "$BASH_SOURCE" ]] && ret=exit || ret=return

# creates the dir which used to store external px4 repo.
mkdir -p "${REPO_ROOT}/external"
echo -e "${gre}[INFO]${end} repo root: ${REPO_ROOT}"

# defines the px4 repo location and the px4 git ref.
PX4_REPO_ROOT="${REPO_ROOT}/external/PX4-Autopilot"
PX4_REPO_REF="v1.17.0-alpha1"

# skips cloning and stops this script if the px4 repo already exists.
if [[ -d "${PX4_REPO_ROOT}/.git" ]]; then
    echo -e "${gre}[INFO]${end} existing px4 repo detected, skip clone"
    ${ret} 0
fi

# clones the px4 repo with submodules.
echo -e "${gre}[INFO]${end} cloning px4 repo to ${PX4_REPO_ROOT}"

git clone --recursive --branch "${PX4_REPO_REF}" https://github.com/PX4/PX4-Autopilot.git "${PX4_REPO_ROOT}"
echo -e "${gre}[INFO]${end} px4 repo clone completed"

# installs px4 build dependencies for SITL dev environment.
echo -e "${gre}[INFO]${end} installing px4 build dependencies"

bash "${PX4_REPO_ROOT}/Tools/setup/ubuntu.sh" --no-nuttx --no-sim-tools
echo -e "${gre}[INFO]${end} px4 build dependencies install completed"

# finishs the host init work.
echo -e "${gre}[INFO]${end} host init completed"
