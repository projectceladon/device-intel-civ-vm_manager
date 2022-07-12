#!/bin/bash

# Copyright (c) 2022 Intel Corporation.
# All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

set -eE
CIV_WORK_DIR=$(pwd)
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

function setup_civ_ini() {
        filename=$(ls caas-flashfiles*)
        sed -i "/^\[global\]$/,/^\[/ s#^name.*#name=civ-sriov#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[global\]$/,/^\[/ s#^flashfiles.*#flashfiles=$CIV_WORK_DIR\/$filename#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[firmware\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR\/OVMF.fd#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[disk\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR\/android.qcow2#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[graphics\]$/,/^\[/ s#^type.*#type=SRIOV#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[graphics\]$/,/^\[/ s/^gvtg_version.*/#gvtg_version=/" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[graphics\]$/,/^\[/ s/^vgpu_uuid.*/#vgpu_uuid=/" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[net\]$/,/^\[/ s/^model.*/#model=/" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[vtpm\]$/,/^\[/ s#^data_dir.*#data_dir=$CIV_WORK_DIR\/vtpm0#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[rpmb\]$/,/^\[/ s#^bin_path.*#bin_path=$CIV_WORK_DIR\/scripts\/rpmb_dev#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[rpmb\]$/,/^\[/ s#^data_dir.*#data_dir=$CIV_WORK_DIR#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[aaf\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR/scripts/aaf#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[aaf\]$/,/^\[/ s#^support_suspend.*#support_suspend=disable#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[passthrough\]$/,/^\[/ s/^passthrough_pci/#passthrough_pci/" $USER_HOME/.intel/.civ/civ-sriov.ini
}

function copy_civ_ini() {
        mkdir -p $USER_HOME/.intel/.civ/
        cp $CIV_WORK_DIR/scripts/civ-1.ini $USER_HOME/.intel/.civ/civ-sriov.ini
        chmod 0666 $USER_HOME/.intel/.civ/civ-sriov.ini
}

copy_civ_ini
setup_civ_ini

