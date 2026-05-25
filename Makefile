# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.


# sets the basic configs.
MAKEFLAGS+= --no-print-directory

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(dir $(MKFILE_PATH))


# help msgs.
.PHONY: help

help:
	@echo ""
	@echo "Usage: make [OPTION] "
	@echo "make host-init            installs the python libs and clones the px4 code "
	@echo "make host-config          updates the px4 configs "
	@echo "make host-build           builds the px4 code and generate the binary "
	@echo "make host-clean           cleans the px4 binary "
	@echo "make host-run             starts the px4 and mujoco "
	@echo ""
	@echo "make xxx CMAKE_OPTIONS=''     make with provided cmake_options"


# make targets for OMNI-FlySim.
.PHONY: host-init host-config host-build host-clean host-run

host-init:
	@echo "[OK]"

host-config:
	@echo "[OK]"

host-build:
	@echo "[OK]"

host-clean:
	@echo "[OK]"

host-run:
	@echo "[OK]"
