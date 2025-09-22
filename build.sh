#!/bin/bash
# copy right by zetaxbyte
# you can rich me on telegram t.me/@zetaxbyte

DATE=$(date '+%y%m%d')
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"
normal="\033[0m"

zipname="Kernel-A13-GoPix-7-Series-KSu-next.zip"

if ! [ -d $(pwd)/../clang-r547379 ] ; then
echo -e "\n $red clang-r547379 dir not found!!! $normal \n"
sleep 1
echo -e "$yellow wait.. Dwonloading clang-r547379... $normal \n"
sleep 1
mkdir -p $(pwd)/../clang-r547379 ; wget -P $(pwd)/../clang-r547379/ https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz ; sleep 2 ; tar -xf $(pwd)/../clang-r547379/clang-r547379.tar.gz -C $(pwd)/../clang-r547379/ && rm -rf $(pwd)/../clang-r547379.tar.gz && ls $(pwd)/../clang-r547379
sleep 1
echo
echo -e "\n $green okay Downloading done... $normal \n"
sleep 1
fi

echo -e "$cyan=========================== $normal"
echo -e "$cyan= START COMPILING KERNEL  = $normal"
echo -e "$cyan=========================== $normal"

echo -e "$blue...LOADING... $normal"

echo -e -ne "$green## (10%\r"
sleep 0.7
echo -e -ne "$green#####                     (33%)\r"
sleep 0.7
echo -e -ne "$green#############             (66%)\r"
sleep 0.7
echo -e -ne "$green#######################   (100%)\r"
echo -ne "\n"

echo -e -n "$yellow\033[104m RUNNING... BUILD \033[0m"
echo

# change DEFCONFIG to you are defconfig name or device codename

DEFCONFIG="gs201_defconfig"

# you can set you name or host name(optional)

export KBUILD_BUILD_USER=@riyanjulai
export KBUILD_BUILD_HOST=Ubuntu-Linux

# change TC_DIR(directory) on where you clone proton-clang toolchain

TC_DIR=$(pwd)/../clang-r547379

# do not modify export PATCH it's been including with TC_DIR

export PATH="$TC_DIR/bin:$PATH"

COMPILE_START=$(date +"%s")

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 LTO=full 2>&1 | tee log.txt

any_kernel_setup() {
if [ -d $(pwd)/../anykernel/ ] ; then
echo "setup"
else
git clone https://github.com/sudoyottaxbyte/any_kernel.git $(pwd)/../anykernel/
fi
}

zip_function() {
    if [[ -f out/arch/arm64/boot/Image.lz4 ]] && [[ -f out/arch/arm64/boot/dts/google/dtbo.img ]] ; then
        echo -e "$yellow zipping Kernel to flashable zip ! "
        rm -rf $(pwd)/../anykernel/Image.lz4
        rm -rf $(pwd)/../anykernel/dtbo.img
        sleep 0.5
        cp out/arch/arm64/boot/Image.lz4 $(pwd)/../anykernel/
        cp out/arch/arm64/boot/dts/google/dtbo.img $(pwd)/../anykernel/
        cd $(pwd)/../anykernel/ && zip -r9 $zipname *
        mv $zipname "$OLDPWD"
        cd -
        sleep 1
        echo
        echo -e "\033[96msize \n"
        du -sh $zipname
        sleep 1
        echo -e "\n$green====== $normal"
        echo -e "$green done √ $normal"
        echo -e "$green====== $normal\n"
    else
        echo -e "$red failed to zip"
    fi
}

if [[ -f out/arch/arm64/boot/Image.lz4 ]] ; then
COMPILE_END=$(date +"%s")
COMPILE_TIME=$((COMPILE_END - COMPILE_START))
echo -e "\n $yellow BUILD COMPLITE  $((COMPILE_TIME / 60)) minute(s) and $((COMPILE_TIME % 60)) second(s) \n"
    echo -e "$cyan===========================\033[0m"
    echo -e "$cyan=  SUCCESS COMPILE KERNEL =\033[0m"
    echo -e "$cyan===========================\033[0m"
sleep 0.5
rm -rf $zipname
sleep 1
any_kernel_setup
sleep 1
zip_function
else
COMPILE_END=$(date +"%s")
COMPILE_TIME=$((COMPILE_END - COMPILE_START))
echo -e "\n $red BUILD FAILED  $((COMPILE_TIME / 60)) minute(s) and $((COMPILE_TIME % 60)) second(s) \n"
echo -e "$red!ups...something wrong!?\033[0m"
fi
