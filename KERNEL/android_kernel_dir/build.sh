#!/bin/bash
#Kernel build script - Senthil360 @XDA-developers
#Thanks to MSF-Jarvis for template

rm .version 2>/dev/null
path="$HOME/Setup_kernel-build/KERNEL/path"

### EDIT THIS ###
#example ker="android_kernel_oneplus_msm8996-MSF"
ker="android_kernel_dir" #your android kernel directory name


read -p "Check or alter dependencies? [Y/n] : " dep
if [ "$dep" = "Y" ] || [ "$dep" = "y" ]; then
   cd $HOME/Setup_kernel-build/KERNEL
   sh $HOME/Setup_kernel-build/KERNEL/kenv.sh
   cd $HOME/Setup_kernel-build/KERNEL/$ker
else
   echo ""
fi

sleep 1

# VARS #### EDIT AS NEEDED ###
export ARCH=arm64                                               
export SUBARCH=arm64
export KBUILD_BUILD_USER=Your_cool_username_XD
export KBUILD_BUILD_HOST=Black_Hole

# Kernel Details ### EDIT AS NEEDED ###
KERNEL_NAME="Nameless"
VER="v0.1"
VER="-$(date +"%Y%m%d"-"%H%M%S")-$VER"
DEVICE="Your_Device"
FINAL_VER="${KERNEL_NAME}""${DEVICE}""${VER}"


# Bash colors
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources ##EDIT DEFCONFIG##
THREAD="-j$(($(nproc --all) * 2))"
DEFCONFIG="your_device_defconfig"
KERNEL="Image.gz-dtb"

# PATHS - THESE STAY THE SAME - DO NOT CHANGE
WORKING_DIR="$(cat $path | head -n 1 | tail -n 1 | cut -d '=' -f2)"
ANYKERNEL_DIR="$(cat $path | head -n 3 | tail -n 1 | cut -d '=' -f2)"
TOOLCHAIN_DIR="$(cat $path | head -n 2 | tail -n 1 | cut -d '=' -f2)"
REPACK_DIR="${ANYKERNEL_DIR}"
ZIP_MOVE="${WORKING_DIR}/out/"
KERNEL_DIR="${WORKING_DIR}/arch/arm64/boot"


# Functions
make_kernel() {
  make clean
  make "${DEFCONFIG}" "${THREAD}"
  rm arch/arm64/boot/Image.gz-dtb 2>/dev/null
  make "${KERNEL}" "${THREAD}"
  [ -f "${KERNEL_DIR}/${KERNEL}" ] && cp -vr "${KERNEL_DIR}/${KERNEL}" "${REPACK_DIR}" || return 1
}

make_zip() {
  cd "${REPACK_DIR}"
  zip -ur kernel_temp.zip *
  mkdir -p "${ZIP_MOVE}"
  cp  kernel_temp.zip "${ZIP_MOVE}/${FINAL_VER}.zip"
  cd "${WORKING_DIR}"
}


push_and_flash() {
  adb push "${ZIP_MOVE}"/${FINAL_VER}.zip /sdcard/$KERNEL_NAME/
  adb shell twrp install "/sdcard/$KERNEL_NAME/${FINAL_VER}.zip"
}


DATE_START=$(date +"%s")

# TC tasks

#evaluate TC tool

val1=$(ls $TOOLCHAIN_DIR/bin | head -n 1 | wc -m)
val2=$(ls $TOOLCHAIN_DIR/bin | head -n 1 | rev | cut -d '-' -f1 | rev | wc -m)
val=$(($val1 - $val2))
cross=$(ls $TOOLCHAIN_DIR/bin | head -n 1 | cut -c -$val)

export CROSS_COMPILE="$TOOLCHAIN_DIR/bin/$cross"
export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/lib/

echo "TC bin is at $CROSS_COMPILE"
sleep 2
cd "${WORKING_DIR}"

echo "Start build"

# Make
  make_kernel
  [[ $? == 0 ]] || exit 256
  make_zip

echo -e "${green}"
echo "${FINAL_VER}.zip"
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$((${DATE_END} - ${DATE_START}))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "

read -p "Flash Kernel in twrp [Y/n] : " opt
      if [ "$opt" = "Y" ] || [ "$opt" = "y" ]; then
         push_and_flash
      else
         exit
      fi
echo " "
