#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

export PrefixPath=/usr
export LibPath=/usr/lib/x86_64-linux-gnu
export nproc=20
export WrkDir=`pwd`

function check_build_error(){
        if [ $? -ne 0 ]; then
                echo -e "${RED}$1: Build Error ${NC}"
                exit -1
        else
                echo -e "${GREEN}$1: Build Success${NC}"
        fi
}

git config --global advice.detachedHead false
#media
echo "export LIBVA_DRIVER_NAME=iHD" | sudo tee -a /etc/environment
echo "export LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" | sudo tee -a /etc/environment
echo "export GIT_SSL_NO_VERIFY=true" | sudo tee -a /etc/environment
source /etc/environment

git lfs install --skip-smudge
git clone https://gitlab.freedesktop.org/mesa/drm.git media/libdrm
cd media/libdrm
git checkout refs/tags/libdrm-2.4.107
git apply $CIV_WORK_DIR/vertical_patches/host/libdrm/*.patch
meson build/ --prefix=$PrefixPath --libdir=$LibPath
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/intel/libva.git media/libva
cd media/libva
git checkout refs/tags/2.13.0
meson build/ --prefix=$PrefixPath --libdir=$LibPath
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/intel/libva-utils.git media/libva-utils
cd media/libva-utils
git checkout refs/tags/2.13.0
meson build/ --prefix=$PrefixPath --libdir=$LibPath
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/intel/gmmlib.git media/gmmlib
cd media/gmmlib
git checkout refs/tags/intel-gmmlib-22.0.1
git apply $CIV_WORK_DIR/vertical_patches/host/gmmlib/*.patch
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PrefixPath ../
make -j "$(nproc)"
check_build_error
sudo make install
cd $WrkDir


git clone https://github.com/intel/media-driver.git media/media-driver
cd media/media-driver
git checkout refs/tags/intel-media-22.1.1
git apply $CIV_WORK_DIR/vertical_patches/host/media/media-driver/*.patch
mkdir build_media && cd build_media
cmake ../ -DCMAKE_INSTALL_PREFIX=$PrefixPath
make -j "$(nproc)"
check_build_error
sudo make install
cd $WrkDir
# Create igfx_user_feature.txt
echo "[KEY]"                                     | sudo tee -a /etc/igfx_user_feature.txt
echo "    0x00000001"                            | sudo tee -a /etc/igfx_user_feature.txt
echo "    UFKEY_INTERNAL\LibVa"                  | sudo tee -a /etc/igfx_user_feature.txt
echo "        [VALUE]"                           | sudo tee -a /etc/igfx_user_feature.txt
echo "            Disable MMC"                   | sudo tee -a /etc/igfx_user_feature.txt
echo "            4"                             | sudo tee -a /etc/igfx_user_feature.txt
echo "            1"                             | sudo tee -a /etc/igfx_user_feature.txt
echo "        [VALUE]"                           | sudo tee -a /etc/igfx_user_feature.txt
echo "            Enable HCP Scalability Decode" | sudo tee -a /etc/igfx_user_feature.txt
echo "            4"                             | sudo tee -a /etc/igfx_user_feature.txt
echo "            0"                             | sudo tee -a /etc/igfx_user_feature.txt
echo "[KEY]"                                     | sudo tee -a /etc/igfx_user_feature.txt
echo "    0x00000002"                            | sudo tee -a /etc/igfx_user_feature.txt
echo "    UFKEY_INTERNAL\Report"                 | sudo tee -a /etc/igfx_user_feature.txt


#onevpl-gpu
git clone https://github.com/oneapi-src/oneVPL-intel-gpu.git media/oneVPL-gpu
cd media/oneVPL-gpu
git checkout refs/tags/intel-onevpl-22.1.0
git apply $CIV_WORK_DIR/vertical_patches/host/media/oneVPL-gpu/*.patch

mkdir build && cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PrefixPath
make -j "$(nproc)"
check_build_error
sudo make install
cd $WrkDir

#onevpl
git clone https://github.com/oneapi-src/oneVPL.git media/oneVPL
cd media/oneVPL
git checkout refs/tags/v2022.0.3
git apply $CIV_WORK_DIR/vertical_patches/host/media/oneVPL/*.patch
mkdir build && cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PrefixPath
make -j "$(nproc)"
check_build_error
sudo make install
cd $WrkDir


#gstreamer
git clone https://github.com/GStreamer/gstreamer.git gstreamer/gstreamer
cd gstreamer/gstreamer
git checkout b4ca58df7624b005a33e182a511904d7cceea890
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gst-plugins-base.git gstreamer/gst-plugins-base
cd gstreamer/gst-plugins-base
git checkout ce937bcb21412d7b3539a2da0509cc96260562f8
git apply $CIV_WORK_DIR/vertical_patches/host/gstreamer/gst-plugins-base/*.patch
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gst-plugins-good.git gstreamer/gst-plugins-good
cd gstreamer/gst-plugins-good
git checkout 20bbeb5e37666c53c254c7b08470ad8a00d97630
git apply $CIV_WORK_DIR/vertical_patches/host/gstreamer/gst-plugins-good/*.patch
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gst-plugins-bad.git gstreamer/gst-plugins-bad
cd gstreamer/gst-plugins-bad
git checkout ca8068c6d793d7aaa6f2e2cc6324fdedfe2f33fa
git apply $CIV_WORK_DIR/vertical_patches/host/gstreamer/gst-plugins-bad/*.patch
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled -Dmsdk=disabled -Dmfx_api=oneVPL
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gst-plugins-ugly.git gstreamer/gst-plugins-ugly
cd gstreamer/gst-plugins-ugly
git checkout 499d3cd726a4ca9cbbdd4b4fe9ccdca78ef538ba
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gstreamer-vaapi.git gstreamer/gstreamer-vaapi
cd gstreamer/gstreamer-vaapi
git checkout c3ddb29cb2860374f9efbed495af7b0eead08312
git apply $CIV_WORK_DIR/vertical_patches/host/gstreamer/gstreamer-vaapi/*.patch
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


git clone https://github.com/GStreamer/gst-rtsp-server.git gstreamer/gst-rtsp-server
cd gstreamer/gst-rtsp-server
git checkout 0b037e35e7ed3259ca05be748c382bc40e2cdd91
meson build --prefix=$PrefixPath --libdir=$LibPath -Dgtk_doc=disabled
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir


#mesa
git clone https://gitlab.freedesktop.org/mesa/mesa.git graphics/mesa
cd graphics/mesa
git checkout 0e0633ca49425dbc869521cede6a82d2d91c8042
git apply $CIV_WORK_DIR/vertical_patches/host/graphics/mesa/*.patch
meson build/ --prefix=$PrefixPath -Dgallium-drivers="swrast,iris,kmsro" -Dvulkan-drivers=intel -Ddri-drivers=i965
ninja -C build && sudo ninja -C build install
check_build_error
cd $WrkDir
# Create mesa_driver.sh
echo "is_vf=\`dmesg | grep \"SR-IOV VF\"\`"         | sudo tee -a /etc/profile.d/mesa_driver.sh
echo "if [[ \$is_vf =~ \"VF\" ]]; then"             | sudo tee -a /etc/profile.d/mesa_driver.sh
echo "    export MESA_LOADER_DRIVER_OVERRIDE=pl111" | sudo tee -a /etc/profile.d/mesa_driver.sh
echo "else"                                         | sudo tee -a /etc/profile.d/mesa_driver.sh
echo "    export MESA_LOADER_DRIVER_OVERRIDE=iris"  | sudo tee -a /etc/profile.d/mesa_driver.sh
echo "fi"                                           | sudo tee -a /etc/profile.d/mesa_driver.sh


#OpenCL
mkdir neo
cd neo
wget https://github.com/intel/compute-runtime/releases/download/22.10.22597/intel-gmmlib_22.0.2_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.10409/intel-igc-core_1.0.10409_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.10409/intel-igc-opencl_1.0.10409_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/22.10.22597/intel-opencl-icd_22.10.22597_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/22.10.22597/intel-level-zero-gpu_1.3.22597_amd64.deb
sudo dpkg -i *.deb
cd $WrkDir
