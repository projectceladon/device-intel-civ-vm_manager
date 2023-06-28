#!/bin/bash

# Copyright (c) 2022 Intel Corporation.
# All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

set -eE
CIV_WORK_DIR=$(pwd)
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
VSOCK_ID=3
VM_NAME=Android-CIV
ADB_PORT=5555
FASTBOOT_PORT=5554

function setup_civ_ini() {
        filename=$(ls caas-flashfiles*)
        sed -i "/^\[global\]$/,/^\[/ s#^name.*#name=$VM_NAME#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[global\]$/,/^\[/ s#^flashfiles.*#flashfiles=$CIV_WORK_DIR\/$filename#" $USER_HOME/.intel/.civ/civ-sriov.ini
	sed -i "/^\[global\]$/,/^\[/ s#^vsock_cid.*#vsock_cid=$VSOCK_ID#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[firmware\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR\/$VM_NAME\/OVMF.fd#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[disk\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR\/$VM_NAME\/android.qcow2#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[graphics\]$/,/^\[/ s#^type.*#type=SRIOV#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[graphics\]$/,/^\[/ s/^gvtg_version.*/#gvtg_version=/" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[graphics\]$/,/^\[/ s/^vgpu_uuid.*/#vgpu_uuid=/" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[net\]$/,/^\[/ s/^model.*/#model=/" $USER_HOME/.intel/.civ/civ-sriov.ini
	sed -i "/^\[net\]$/,/^\[/ s/^adb_port.*/adb_port=$ADB_PORT/" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[net\]$/,/^\[/ s/^fastboot_port.*/fastboot_port=$((ADB_PORT+1))/" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[vtpm\]$/,/^\[/ s#^data_dir.*#data_dir=$CIV_WORK_DIR\/$VM_NAME\/vtpm0#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[rpmb\]$/,/^\[/ s#^bin_path.*#bin_path=$CIV_WORK_DIR\/$VM_NAME\/scripts\/rpmb_dev#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[rpmb\]$/,/^\[/ s#^data_dir.*#data_dir=$CIV_WORK_DIR\/$VM_NAME#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[aaf\]$/,/^\[/ s#^path.*#path=$CIV_WORK_DIR/$VM_NAME/scripts/aaf#" $USER_HOME/.intel/.civ/civ-sriov.ini
        sed -i "/^\[aaf\]$/,/^\[/ s#^support_suspend.*#support_suspend=disable#" $USER_HOME/.intel/.civ/civ-sriov.ini

        sed -i "/^\[passthrough\]$/,/^\[/ s/^passthrough_pci/#passthrough_pci/" $USER_HOME/.intel/.civ/civ-sriov.ini

	mv $USER_HOME/.intel/.civ/civ-sriov.ini $USER_HOME/.intel/.civ/$VM_NAME.ini
}

function copy_civ_ini() {
        mkdir -p $USER_HOME/.intel/.civ/
        cp $CIV_WORK_DIR/scripts/civ-1.ini $USER_HOME/.intel/.civ/civ-sriov.ini
        chmod 0666 $USER_HOME/.intel/.civ/civ-sriov.ini
}

function read_args() {
        while [[ $# -gt 0 ]]; do
                case $1 in
                        -v)
                                VSOCK_ID=$2
                                shift
                                ;;

                        -p)
                                ADB_PORT=$2
                                shift
                                ;;

                        -n)
                                VM_NAME=$2
                                shift
                                ;;
                esac
                shift
        done
}

read_args "$@"

copy_civ_ini
setup_civ_ini

