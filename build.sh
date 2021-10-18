#!/usr/bin/env bash
IMAGE=$(pwd)/out/arch/arm64/boot/Image-gz.dtb
START=$(date +"%s")
KERNEL_DIR=$(pwd)
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
VERSION="$(cat arch/arm64/configs/vendor/surya_defconfig | grep "CONFIG_LOCALVERSION\=" | sed -r 's/.*"(.+)".*/\1/' | sed 's/^.//')"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_BUILD_HOST="IU"
export KBUILD_BUILD_USER="dlwlrma123"

#clear screen
clear

#always do clean compilation
rm -rf out

function compile() {
    make O=out ARCH=arm64 vendor/surya_defconfig
    make -j$(nproc --all) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

compile

# Build flashable zip
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3/
cp out/arch/arm64/boot/dtbo AnyKernel3/
zipfile="./$VERSION-surya-NON-Unified-$(date +%Y%m%d-%H%M).zip"
7z a -mm=Deflate -mfb=258 -mpass=15 -r $zipfile ./AnyKernel3/*

#clean leftovers
rm -rf AnyKernel3/Image.gz-dtb

END=$(date +"%s")
DIFF=$(($END - $START))

echo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
