#!/bin/bash

# Copyright (c) 2020 Intel Corporation.
# All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

set -eE

#---------      Global variable     -------------------
reboot_required=0
QEMU_REL="qemu-8.2.1"
skip_install_qemu=false

#Directory to keep versions of qemu which can be reused instead of downloading again
QEMU_CACHE_DIR="$HOME/.cache/civ/qemu"

CIV_WORK_DIR=$(pwd)
CIV_GOP_DIR=$CIV_WORK_DIR/GOP_PKG
CIV_VERTICAl_DIR=$CIV_WORK_DIR/vertical_patches/host
VM_MANAGER_VERSION=v1.2.3
VSOCK_ID=3
VM_NAME=Android-CIV1
ADB_PORT=5555
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

#---------      Functions    -------------------
function error() {
    local line=$1
    local cmd=$2
    echo "$BASH_SOURCE Failed at line($line): $cmd"
}

function ubu_changes_require(){
    echo "Please make sure your apt is working"
    echo "If you run the installation first time, reboot is required"
    sudo apt install -y wget mtools ovmf dmidecode python3-usb python3-pyudev pulseaudio jq

    # Install libs for vm-manager
    sudo apt install -y libglib2.0-dev libncurses-dev libuuid1 uuid-dev libjson-c-dev
}

function ubu_install_qemu_gvt(){
    if [ $skip_install_qemu = true ]; then
        echo "Skip ubu_install_qemu_gvt"
        return
    fi
    sudo apt purge -y "^qemu"
    sudo apt autoremove -y
    sudo apt install -y git libfdt-dev libpixman-1-dev libssl-dev vim socat libsdl2-dev libspice-server-dev autoconf libtool xtightvncviewer tightvncserver x11vnc uuid-runtime uuid uml-utilities bridge-utils liblzma-dev libc6-dev libegl1-mesa-dev libepoxy-dev libdrm-dev libgbm-dev libaio-dev libusb-1.0-0-dev libgtk-3-dev bison libcap-dev libattr1-dev flex libvirglrenderer-dev build-essential gettext libegl-mesa0 libegl-dev libglvnd-dev libgl1-mesa-dev libgl1-mesa-dev libgles2-mesa-dev libegl1 gcc g++ pkg-config libpulse-dev libgl1-mesa-dri
    sudo apt install -y ninja-build libcap-ng-dev

    #Create QEMU_CACHE_DIR if it doesnt exists
    mkdir -p $QEMU_CACHE_DIR

    #Download QEMU_REL.tar.xz if it doesnt exist in QEMU_CACHE_DIR
    [ ! -f $QEMU_CACHE_DIR/$QEMU_REL.tar.xz ] && check_qemu_network && wget https://download.qemu.org/$QEMU_REL.tar.xz -P $QEMU_CACHE_DIR


    [ -d $CIV_WORK_DIR/$QEMU_REL ] && rm -rf $CIV_WORK_DIR/$QEMU_REL
    
    #Directly untar into the CIV_WORK_DIR
    tar -xf $QEMU_CACHE_DIR/$QEMU_REL.tar.xz -C $CIV_WORK_DIR

    cd $CIV_WORK_DIR/$QEMU_REL/

    qemu_patch_num=$(ls $CIV_WORK_DIR/patches/qemu/*.patch 2> /dev/null | wc -l)
    if [ "$qemu_patch_num" != "0" ]; then
        for i in $CIV_WORK_DIR/patches/qemu/*.patch; do
            echo "applying qemu patch $i"
            patch -p1 < $i
        done
    fi

    if [ -d $CIV_GOP_DIR ]; then
        for i in $CIV_GOP_DIR/qemu/*.patch; do patch -p1 < $i; done
    fi

    sriov_qemu_patch_num=$(ls $CIV_WORK_DIR/sriov_patches/qemu/*.patch 2> /dev/null | wc -l)
    if [ "$sriov_qemu_patch_num" != "0" ]; then
        for i in $CIV_WORK_DIR/sriov_patches/qemu/*.patch; do
            echo "applying qemu patch $i"
            patch -p1 < $i
        done
    fi

    vertical_qemu_patch_num=$(ls $CIV_VERTICAl_DIR/qemu/*.patch 2> /dev/null | wc -l)
    if [ "$vertical_qemu_patch_num" != "0" ]; then
        for i in $CIV_VERTICAl_DIR/qemu/*.patch; do
            echo "applying qemu patch $i"
            patch -p1 < $i
        done
    fi

    ./configure --prefix=/usr \
        --enable-kvm \
        --disable-xen \
        --enable-libusb \
        --enable-debug-info \
        --enable-debug \
        --enable-sdl \
        --enable-vhost-net \
        --enable-spice \
        --disable-debug-tcg \
        --enable-opengl \
        --enable-gtk \
        --enable-virtfs \
        --target-list=x86_64-softmmu \
        --audio-drv-list=pa
    make -j24
    sudo make install
    cd -
}

function ubu_build_ovmf_gvt(){
    [ -d $CIV_WORK_DIR/edk2 ] && rm -rf $CIV_WORK_DIR/edk2

    sudo apt install -y uuid-dev nasm acpidump iasl
    git clone https://github.com/tianocore/edk2.git
    cd $CIV_WORK_DIR/edk2
    git checkout -b stable202111 edk2-stable202111
    git submodule update --init

    patch -p1 < $CIV_WORK_DIR/patches/ovmf/0001-OvmfPkg-add-IgdAssignmentDxe.patch
    if [ -d $CIV_GOP_DIR ]; then
        for i in $CIV_GOP_DIR/ovmf/*.patch; do patch -p1 < $i; done
        cp $CIV_GOP_DIR/ovmf/Vbt.bin OvmfPkg/Vbt/Vbt.bin
    fi

    vertical_ovmf_patch_num=$(ls $CIV_VERTICAl_DIR/ovmf/*.patch 2> /dev/null | wc -l)
    if [ "$vertical_ovmf_patch_num" != "0" ]; then
        for i in $CIV_VERTICAl_DIR/ovmf/*.patch; do
            echo "applying ovmf patch $i"
            patch -p1 < $i
        done
    fi

    source ./edksetup.sh
    make -C BaseTools/
    build -b DEBUG -t GCC5 -a X64 -p OvmfPkg/OvmfPkgX64.dsc -D NETWORK_IP4_ENABLE -D NETWORK_ENABLE  -D SECURE_BOOT_ENABLE -D TPM_ENABLE
    cp Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd ../OVMF.fd

    if [ -d $CIV_GOP_DIR ]; then
        local gpu_device_id=$(cat /sys/bus/pci/devices/0000:00:02.0/device)
        ./BaseTools/Source/C/bin/EfiRom -f 0x8086 -i $gpu_device_id -e $CIV_GOP_DIR/IntelGopDriver.efi -o $CIV_GOP_DIR/GOP.rom
    fi

    cd -
}

function install_vm_manager_deb(){
    #Try to download from latest release/tag
    local os_ver=$(lsb_release -rs)
    local vm_repo="https://github.com/projectceladon/vm_manager/"
    local rtag=$(git ls-remote -t --refs ${vm_repo} | cut --delimiter='/' --fields=3  | tr '-' '~' | sort --version-sort | tail --lines=1)
    local rdeb=vm-manager_${rtag}.deb

    [ -f ${rdeb} ] && rm -f ${rdeb}

    local rurl=https://github.com/projectceladon/vm_manager/releases/latest/download/${rdeb}

    if wget ${rurl} ; then
        sudo dpkg -i ${rdeb} || return -1
        return 0
    else
        return -1
    fi
}

function install_vm_manager_src() {
    #Try to build from source code
    if [ -d $CIV_WORK_DIR/vm_manager ]
    then
        rm -rf $CIV_WORK_DIR/vm_manager
    fi
    sudo apt-get install --yes make gcc
    if [ ! -z $VM_MANAGER_VERSION ]; then
        git clone -b $VM_MANAGER_VERSION --single-branch https://github.com/projectceladon/vm_manager.git
    else
        git clone https://github.com/projectceladon/vm_manager.git || return -1
    fi
    sudo apt install -y cmake
    cd vm_manager/
    git apply $CIV_WORK_DIR/vertical_patches/host/vm-manager/*.patch
    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    cmake --build . --config Release
    cp src/vm-manager /usr/bin/
    cd $CIV_WORK_DIR
    rm -rf vm_manager/
}

function install_vm_manager() {
    sudo apt-get update
    sudo apt-get install --yes libglib2.0-dev libncurses-dev libuuid1 uuid-dev libjson-c-dev wget lsb-release git
    install_vm_manager_src
    if [ "$?" -ne 0 ]; then
        echo "Failed to install vm-manager!"
        echo "Please download and install mannually from: https://github.com/projectceladon/vm_manager/releases/latest"
    fi
}

function ubu_enable_host_gvt(){

    if [[ ! `cat /etc/default/grub` =~ "i915.enable_guc="(0x)?0*"7" ]] &&
       [[ ! `cat /etc/default/grub` =~ "i915.enable_gvt=1" ]]; then

        if [[ ! `cat /etc/default/grub` =~ "intel_iommu=on i915.force_probe=*" ]]; then
            sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"intel_iommu=on i915.force_probe=* /g" /etc/default/grub
        fi
        sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"i915.enable_gvt=1 /g" /etc/default/grub
        update-grub

        echo -e "\nkvmgt\nvfio-iommu-type1\nvfio-mdev\n" >> /etc/initramfs-tools/modules
        update-initramfs -u -k all

        reboot_required=1
    fi
}

function ubu_update_fw(){
    FW_REL="linux-firmware-20220310"
    GUC_REL="70.0.3"
    HUC_REL="7.9.3"
    S_DMC_REL="2_01"
    P_DMC_REL="2_12"

    [ ! -f $CIV_WORK_DIR/$FW_REL.tar.xz ] && wget "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20220310.tar.gz" -P $CIV_WORK_DIR

    [ -d $CIV_WORK_DIR/$FW_REL ] && rm -rf $CIV_WORK_DIR/$FW_REL
    tar -xf $CIV_WORK_DIR/$FW_REL.tar.gz

    cd $CIV_WORK_DIR/$FW_REL/i915/
    wget https://github.com/intel/intel-linux-firmware/raw/main/adlp_guc_$GUC_REL.bin
    wget https://github.com/intel/intel-linux-firmware/raw/main/tgl_guc_$GUC_REL.bin
    cp adlp_guc_$GUC_REL.bin tgl_guc_$GUC_REL.bin adlp_dmc_ver$P_DMC_REL.bin adls_dmc_ver$S_DMC_REL.bin tgl_huc_$HUC_REL.bin /lib/firmware/i915/

    cd $CIV_WORK_DIR
    rm -rf $CIV_WORK_DIR/$FW_REL*

    update-initramfs -u -k all

    reboot_required=1
}

function setup_remote_infer() {
    $CIV_WORK_DIR/scripts/setup_rinfer_host.sh
    reboot_required=1
}

function check_os() {
    local version=`cat /proc/version`

    if [[ ! $version =~ "Ubuntu" ]]; then
        echo "only Ubuntu is supported, exit!"
        return -1
    fi
}

function check_network(){
    #Check if you are able to access external website without actually downloading it
    wget --timeout=3 --tries=1 -q --spider https://github.com
    if [ $? -ne 0 ]; then
        echo "access https://github.com failed!"
        echo "please make sure network is working"
        return -1
    fi
}

#Check Connection specifically with qemu network only if QEMU_REL.tar.xz needs to be downloaded as it doesnt exist in QEMU_CACHE_DIR
function check_qemu_network(){
    wget --timeout=3 --tries=1 https://download.qemu.org/ -q -O /dev/null
    if [ $? -ne 0 ]; then
        echo "access https://download.qemu.org failed!"
        echo "please make sure network is working"
        return -1
    fi
}

function check_kernel_version() {
    local cur_ver=$(uname -r | sed "s/\([0-9.]*\).*/\1/")
    local req_ver="5.0.0"

    if [ "$(printf '%s\n' "$cur_ver" "$req_ver" | sort -V | head -n1)" != "$req_ver" ]; then
        echo "E: Detected Linux version: $cur_ver!"
        echo "E: Please upgrade kernel version newer than $req_ver!"
        return -1
    fi
}

function check_sriov_setup() {
    input="$CIV_WORK_DIR/sriov_setup_ubuntu.log"
    sriov_setup_success=0

    if [ -f "$input" ]; then
        while read -r line
        do
            if [[ $line == "Success" ]]; then
                sriov_setup_success=1
            fi
        done < "$input"
    fi

    if [ $sriov_setup_success == 0 ]; then
        echo "E: Please ensure SRIOV has been setup successfully first"
        exit
    fi
}

function ask_reboot(){
    if [ $reboot_required -eq 1 ];then
       echo "Please reboot system to take effect"
    fi
}

function prepare_required_scripts(){
    chmod +x $CIV_WORK_DIR/scripts/*.sh
    chmod +x $CIV_WORK_DIR/scripts/guest_pm_control
    chmod +x $CIV_WORK_DIR/scripts/findall.py
    chmod +x $CIV_WORK_DIR/scripts/thermsys
    chmod +x $CIV_WORK_DIR/scripts/batsys
}

function start_thermal_daemon() {
    sudo systemctl stop thermald.service
    sudo cp $CIV_WORK_DIR/scripts/intel-thermal-conf.xml /etc/thermald
    sudo cp $CIV_WORK_DIR/scripts/thermald.service  /lib/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl start thermald.service
}

function install_auto_start_service(){
    service_file=civ.service
    touch $service_file
    cat /dev/null > $service_file

    echo "[Unit]" > $service_file
    echo -e "Description=CiV Auto Start\n" >> $service_file

    echo "[Service]" >> $service_file
    echo -e "Type=forking\n" >> $service_file
    echo -e "TimeoutSec=infinity\n" >> $service_file
    echo -e "WorkingDirectory=$CIV_WORK_DIR\n" >> $service_file
    echo -e "ExecStart=/bin/bash -E $CIV_WORK_DIR/scripts/start_civ.sh $1\n" >> $service_file

    echo "[Install]" >> $service_file
    echo -e "WantedBy=multi-user.target\n" >> $service_file

    sudo mv $service_file /etc/systemd/system/
    sudo systemctl enable $service_file
}

function setup_power_button(){
    sudo sed -i 's/#*HandlePowerKey=\w*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
    reboot_required=1
}

# This is for lg setup
function ubu_install_lg_client(){
    if [[ $1 == "PGP" ]]; then
      LG_VER=B1
      LG_LIB=lg_b1
      sudo apt install -y git binutils-dev cmake fonts-freefont-ttf libsdl2-dev libsdl2-ttf-dev libspice-protocol-dev libfontconfig1-dev libx11-dev nettle-dev daemon
      touch /dev/shm/looking-glass0 && chmod 660 /dev/shm/looking-glass0
      touch /dev/shm/looking-glass1 && chmod 660 /dev/shm/looking-glass1
      touch /dev/shm/looking-glass2 && chmod 660 /dev/shm/looking-glass2
      touch /dev/shm/looking-glass3 && chmod 660 /dev/shm/looking-glass3
      if [ -d "$LG_LIB" ]; then
        sudo rm -rf $LG_LIB
      fi
      git clone https://github.com/gnif/LookingGlass.git $LG_LIB
      cd $CIV_WORK_DIR/$LG_LIB
      git checkout 163a2e5d0a11
      git apply $CIV_WORK_DIR/patches/lg/*.patch
      cd client
      mkdir build
      cd build
      cmake ../
      make
      if [ ! -d "/opt/lg" ]; then
        sudo mkdir /opt/lg
      fi
      if [ ! -d "/opt/lg/bin" ]; then
        sudo mkdir /opt/lg/bin
      fi
      sudo cp looking-glass-client /opt/lg/bin/LG_B1_Client
      cp looking-glass-client $CIV_WORK_DIR/scripts/LG_B1_Client
      cd $CIV_WORK_DIR
    else
        echo "$0: Unsupported mode: $1"
        return -1
    fi
}

function set_host_ui() {
    setup_power_button
    if [[ $1 == "headless" ]]; then
        setup_power_button
        [[ $(systemctl get-default) == "multi-user.target" ]] && return 0
        sudo systemctl set-default multi-user.target
        reboot_required=1
    elif [[ $1 == "GUI" ]]; then
        [[ $(systemctl get-default) == "graphical.target" ]] && return 0
        sudo systemctl set-default graphical.target
        reboot_required=1
    else
        echo "$0: Unsupported mode: $1"
        return -1
    fi
}

function setup_sof() {
    cp -R $CIV_WORK_DIR/scripts/sof_audio/ $CIV_WORK_DIR/
    if [[ $1 == "enable-sof" ]]; then
        $CIV_WORK_DIR/sof_audio/configure_sof.sh "install" $CIV_WORK_DIR
    elif [[ $1 == "disable-sof" ]]; then
        $CIV_WORK_DIR/sof_audio/configure_sof.sh "uninstall" $CIV_WORK_DIR
    fi
    $CIV_WORK_DIR/scripts/setup_audio_host.sh
}

function ubu_install_swtpm() {
    #install libtpms and swtpm
    sudo apt-get -y install libtpms-dev swtpm

    #update apparmor profile usr.bin.swtpm
    sed -i "s/#include <tunables\/global>/include <tunables\/global>/g" /etc/apparmor.d/usr.bin.swtpm
    sed -i "s/#include <abstractions\/base>/include <abstractions\/base>/g" /etc/apparmor.d/usr.bin.swtpm
    sed -i "s/#include <abstractions\/openssl>/include <abstractions\/openssl>\n  include <abstractions\/libvirt-qemu>/g" /etc/apparmor.d/usr.bin.swtpm
    sed -i "s/#include <local\/usr.bin.swtpm>/include <local\/usr.bin.swtpm>/g" /etc/apparmor.d/usr.bin.swtpm

    #update local apparmor profile usr.bin.swtpm
    local_swtpm_profile=("owner /home/**/vtpm0/.lock wk,"
                         "owner /home/**/vtpm0/swtpm-sock w,"
                         "owner /home/**/vtpm0/TMP2-00.permall rw,"
                         "owner /home/**/vtpm0/tpm2-00.permall rw,")

    for rule in "${local_swtpm_profile[@]}"; do
        if [[ ! `cat /etc/apparmor.d/local/usr.bin.swtpm` =~ "$rule" ]]; then
            echo -e "$rule" | sudo tee -a /etc/apparmor.d/local/usr.bin.swtpm
        fi
    done
    #load profile
    sudo apparmor_parser -r /etc/apparmor.d/usr.bin.swtpm

}

function ubu_install_libssl() {
    sudo add-apt-repository -y 'deb http://security.ubuntu.com/ubuntu focal-security main'
    sudo apt-get -y install libssl1.1
    sudo add-apt-repository -y --remove 'deb http://security.ubuntu.com/ubuntu focal-security main'
}

function ubu_update_bt_fw() {
    #kill qemu if android is launched, because BT might have been given as passthrough to the guest.
    #In this case hciconfig will show null
    qemu_pid="$(ps -ef | grep qemu-system | grep -v grep | awk '{print $2}')"
    if [ "$qemu_pid" != "" ]; then
        kill $qemu_pid > /dev/null
        sleep 5
    fi
    if [ "$(hciconfig)" != "" ]; then
        if [ "$(hciconfig | grep "UP")" == "" ]; then
            if [ "$(rfkill list bluetooth | grep "Soft blocked: no" )" == "" ]; then
                sudo rfkill unblock bluetooth
            fi
        fi
        if [ -d "linux-firmware" ] ; then
            rm -rf linux-firmware
        fi
        git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware
        cd linux-firmware
        # Checkout to specific commit as guest also uses this version. Latest
        # is not taken as firmware update process in the guest is manual
        git checkout b377ccf4f1ba7416b08c7f1170c3e28a460ac29e
        cd -
        sudo cp linux-firmware/intel/ibt-19-0-4* /lib/firmware/intel
        sudo cp linux-firmware/intel/ibt-18-16-1* /lib/firmware/intel
        sudo cp linux-firmware/intel/ibt-0040-0041* /lib/firmware/intel
        sudo cp linux-firmware/intel/ibt-0040-4150* /lib/firmware/intel
        ln -sf /lib/firmware/intel/ibt-19-0-4.sfi /lib/firmware/intel/ibt-19-16-0.sfi
        ln -sf /lib/firmware/intel/ibt-19-0-4.ddc /lib/firmware/intel/ibt-19-16-0.ddc
        hcitool cmd 3f 01 01 01 00 00 00 00 00 > /dev/null 2>&1 &
        sleep 5
        echo "BT FW in the host got updated"
        hciconfig hci0 up
        reboot_required=1
    else
        usb_devices="/sys/kernel/debug/usb/devices"
        count="$(grep -c 'Cls=e0(wlcon) Sub=01 Prot=01 Driver=btusb' $usb_devices || true)"
        if [ $count -eq 0 ]; then
            echo " Skip the host BT firmware update as BT controller is not present"
        else
            echo "Host Bluetooth firmware update failed. Run the setup again after cold reboot"
        fi
    fi
}

function ubu_update_wifi_fw(){
    if [ -d "linux-firmware" ] ; then
            rm -rf linux-firmware
    fi
    git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware
    sudo cp linux-firmware/iwlwifi-so-a0-hr-b0-64.ucode /lib/firmware
}


function set_sleep_inhibitor() {
    sudo apt-get -y install python3-pip
    sudo apt install -y pipx
    pipx ensurepath
    sudo pipx install sleep-inhibitor

    pythonversion="$(pip3 --version | grep -Po '^.*\(\K[^\)]*' | grep -Po '^.*\ \K[^\\n]*')"
    sudo sed -i 's/\/usr\/bin\/%p/\/usr\/local\/bin\/%p/' /root/.local/share/pipx/venvs/sleep-inhibitor/lib/python$pythonversion/site-packages/sleep_inhibitor/sleep-inhibitor.service
    #Download the plugin if not already
    sudo echo "#! /bin/sh
if adb get-state 1>/dev/null 2>&1
then
        state=\$(adb shell dumpsys power | grep -oE 'WAKE_LOCK')
        if echo \"\$state\" | grep 'WAKE_LOCK'; then
                exit 254
        else
                exit 0
        fi
else
        exit 0
fi" > /root/.local/share/pipx/venvs/sleep-inhibitor/lib/python$pythonversion/site-packages/sleep_inhibitor/plugins/is-wakelock-active
    sudo chmod a+x /root/.local/share/pipx/venvs/sleep-inhibitor/lib/python$pythonversion/site-packages/sleep_inhibitor/plugins/is-wakelock-active
    sudo cp /root/.local/share/pipx/venvs/sleep-inhibitor/lib/python$pythonversion/site-packages/sleep_inhibitor/sleep-inhibitor.conf /etc/.
    sudo echo "plugins:
    #Inhibit sleep if wakelock is held
    - path: is-wakelock-active
      name: Wakelock active
      what: sleep
      period: 0.01" > /etc/sleep-inhibitor.conf
    sudo sed -i 's/#*HandleSuspendKey=\w*/HandleSuspendKey=suspend/' /etc/systemd/logind.conf
    sudo cp /root/.local/share/pipx/venvs/sleep-inhibitor/lib/python$pythonversion/site-packages/sleep_inhibitor/sleep-inhibitor.service /etc/systemd/system/.
    reboot_required=1
}

function show_help() {
    printf "$(basename "$0") [-q] [-u] [--auto-start]\n"
    printf "Options:\n"
    printf "\t-h  show this help message\n"
    printf "\t-u  specify Host OS's UI, support \"headless\" and \"GUI\" eg. \"-u headless\" or \"-u GUI\"\n"
    printf "\t--auto-start auto start CiV guest when Host boot up.\n"
    printf "\t-i  enable remote inferencing\n"
}

function parse_arg() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|-\?|--help)
                show_help
                exit
                ;;

            -u)
                set_host_ui $2 || return -1
                shift
                ;;

            -p)
                ubu_install_lg_client $2 || return -1
                shift
                ;;

            -a)
                setup_sof $2 || return -1
                shift
                ;;

            -n)
                VM_NAME=$2
                shift
                ;;

            -t)
                start_thermal_daemon || return -1
                ;;

            -i)
                setup_remote_infer || return -1
                ;;

            --auto-start)
                install_auto_start_service "$2" || return -1
                shift
                ;;

            --bsp)
                skip_install_qemu=true
                ;;

            -?*)
                echo "Error: Invalid option $1"
                show_help
                return -1
                ;;
            *)
                echo "unknown option: $1"
                return -1
                ;;
        esac
        shift
    done
}

function setup_civ_ini() {
        $CIV_WORK_DIR/scripts/setup_civ_ini.sh -v $1 -p $2 -n $3
}

function create_vm_dir() {
        if [ -d $CIV_WORK_DIR/$VM_NAME ]
        then
                echo "Folder with name $VM_NAME already present. Delete and create new folder? Please enter yes/no"
		read input
		if [ $input = "yes" ]; then
	                rm -rf $CIV_WORK_DIR/$VM_NAME
	        else
	                exit
	        fi
        fi
        echo "Creating Dir: $CIV_WORK_DIR/$VM_NAME"
        mkdir $CIV_WORK_DIR/$VM_NAME
}

function copy_files_for_vm() {
    echo "Copying file: $CIV_WORK_DIR/$VM_NAME"
    mkdir -p $CIV_WORK_DIR/$VM_NAME/scripts/aaf

    req_files=("$CIV_WORK_DIR/OVMF.fd"
                   "$CIV_WORK_DIR/scripts/rpmb_dev")
    for file in ${req_files[@]}; do
        if [ ! -f $file ]; then
            echo "Error: $file file is missing"
            exit -1
        fi
    done

    cp $CIV_WORK_DIR/OVMF.fd $CIV_WORK_DIR/$VM_NAME/
    cp $CIV_WORK_DIR/scripts/rpmb_dev $CIV_WORK_DIR/$VM_NAME/scripts/
}

#-------------    main processes    -------------

trap 'error ${LINENO} "$BASH_COMMAND"' ERR

parse_arg "$@"

check_os
check_network
check_kernel_version
check_sriov_setup

ubu_changes_require
ubu_install_qemu_gvt
ubu_build_ovmf_gvt
ubu_enable_host_gvt
install_vm_manager

create_vm_dir
setup_civ_ini $VSOCK_ID $ADB_PORT $VM_NAME
copy_files_for_vm

prepare_required_scripts
ubu_install_swtpm
ubu_install_libssl
ubu_update_bt_fw
set_sleep_inhibitor

ask_reboot

echo "Done: \"$(realpath $0) $@\""
