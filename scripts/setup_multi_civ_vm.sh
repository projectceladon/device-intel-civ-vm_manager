#!/bin/bash

# Copyright (c) 2023 Intel Corporation.
# All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

set -eE

#---------      Global variable     -------------------
CIV_DIR=$(pwd)
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
VM_NAME=Android-CIV
NUMBER_OF_VM=1
ADB_PORT=5555
INITIAL_VM_NUM=1
SETUP_HOST_DONE=false

function copy_files_for_vm_flashing() {
    mkdir -p $CIV_DIR/$3/scripts/aaf

    req_files=("$CIV_DIR/OVMF.fd"
                   "$CIV_DIR/scripts/rpmb_dev")
    for file in ${req_files[@]}; do
        if [ ! -f $file ]; then
            echo "Error: $file file is missing"
            exit -1
        fi
    done

    cp $CIV_DIR/OVMF.fd $CIV_DIR/$3/
    cp $CIV_DIR/scripts/rpmb_dev $CIV_DIR/$3/scripts/
}

function create_vm_dirs() {
    mkdir $CIV_DIR/$3
    $CIV_DIR/scripts/setup_civ_ini.sh -v $1 -p $2 -n $3
}


function create_vms() {
    create_vm_dirs $1 $2 $3
    copy_files_for_vm_flashing $1 $2 $3
}

function setup_files() {
    echo "Creating setup for VMs"
    if [ -d $USER_HOME/.intel/.civ ]
    then
        SETUP_HOST_DONE=true
    fi

    new_dir=$CIV_DIR/$VM_NAME
    if [ -n "$(ls -d ${new_dir}? 2> /dev/null )" ]; then
	dir_arr=$(ls -d ${new_dir}?)
	directories=( $dir_arr )
	last_vm=${directories[-1]}
	final_vm_name="${last_vm##*/}"
	last_character=${final_vm_name: -1}
	last_character=$((last_character+1))
	INITIAL_VM_NUM=$last_character
    fi

    for (( i=$INITIAL_VM_NUM; i<$NUMBER_OF_VM+$INITIAL_VM_NUM; i++ ))
    do
	if [ $SETUP_HOST_DONE = false ]; then
            echo "Error: Please ensure setup_host.sh has been run successfully first"
	    exit -1
	else
	    create_vms $((i+2)) $((ADB_PORT+((i-1)*2))) ${VM_NAME}${i}
	fi
    done
}

function copy_files_for_vm() {
    if [ -f "$CIV_DIR/$VM_NAME$INITIAL_VM_NUM/android.qcow2" ]; then
        cp $CIV_DIR/$VM_NAME$INITIAL_VM_NUM/android.qcow2 $CIV_DIR/$VM_NAME$1
    else
        echo "android.qcow2 missing. Please run setup_host.sh, start_flash_usb.sh and try again"
        exit
    fi

    if [ -d "$CIV_DIR/$VM_NAME$INITIAL_VM_NUM/vtpm0" ]; then
        cp -r $CIV_DIR/$VM_NAME$INITIAL_VM_NUM/vtpm0 $CIV_DIR/$VM_NAME$1
    else
        echo "vtpm0 missing. Please run setup_host.sh, start_flash_usb.sh and try again"
        exit
    fi
}

function flash_vms() {
    echo "Flashing VMs"
    if [ -f caas-flashfiles-*.zip ]; then
        ./scripts/start_flash_usb.sh caas-flashfiles-*.zip --display-off -n $VM_NAME$INITIAL_VM_NUM
    else
        echo "flashfiles missing. Please download and unzip the package correctly."
        exit -1
    fi

    for (( i=$INITIAL_VM_NUM+1; i<$NUMBER_OF_VM+$INITIAL_VM_NUM; i++ ))
    do
        copy_files_for_vm $i
        echo "Flashed ${VM_NAME}${i}"
    done
}

function show_help() {
    printf "Creates CIV guests under folder Android-CIVx, where x is the guest number.\n"
    printf "Usage: \n"
    printf "$(basename "$0") [-c] \n"
    printf "Options:\n"
    printf "\t-h  show this help message\n"
    printf "\t-c  specify number of Android guests to be newly created. Default is 1.\n"
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
	    -c)
		NUMBER_OF_VM=$2
		shift
		;;

	    -h|-\?|--help)
                show_help
                exit
                ;;

	esac
        shift
    done
}

parse_args "$@"
setup_files
flash_vms
echo "Done: \"$(realpath $0) $@\""
