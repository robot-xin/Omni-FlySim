#!/usr/bin/env bash
# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

red='\e[1;31m'
gre='\e[1;32m'
end='\e[0m'

[[ "$0" == "$BASH_SOURCE" ]] && ret=exit || ret=return

mkdir -p "${REPO_ROOT}/external"
echo -e "${gre}[INFO]${end} repo root: ${REPO_ROOT}"

PX4_REPO_ROOT="${REPO_ROOT}/external/PX4-Autopilot"
PX4_REPO_REF="v1.17.0-alpha1"

if [[ -d "${PX4_REPO_ROOT}/.git" ]]; then
    echo -e "${gre}[INFO]${end} existing px4 repo detected, skip clone"
    ${ret} 0
fi

echo -e "${gre}[INFO]${end} cloning px4 repo to ${PX4_REPO_ROOT}"

git clone --recursive --branch "${PX4_REPO_REF}" https://github.com/PX4/PX4-Autopilot.git "${PX4_REPO_ROOT}"
echo -e "${gre}[INFO]${end} px4 repo clone completed"
