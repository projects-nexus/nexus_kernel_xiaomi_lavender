!/usr/bin/env bash

#
# Script For Building Android Kernel
#

MODEL="Redmi Note 7"

DEVICE="Lavender"

DEFCONFIG=lavender-perf_defconfig

KERNEL_DIR=$(pwd)

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb

COMPILER=clang

# Verbose build
VERBOSE=0

                export PROCS=$(nproc --all)

# Set Date 
DATE=$(TZ=Asia/Kolkata date +"%Y%m%d-%T")
START=$(date +"%s")
TANGGAL=$(date +"%F-%S")

# Commit Head
COMMIT_HEAD=$(git log --oneline -1)

# Kernel Version
KERVER=$(make kernelversion)

clone() {
	echo " Cloning Dependencies "
	if [ $COMPILER = "gcc" ]
	then
		echo "|| Cloning GCC ||"
		git clone --depth=1 https://github.com/mvaisakh/gcc-arm64.git -b gcc-new gcc64
                git clone --depth=1 https://github.com/mvaisakh/gcc-arm.git -b gcc-new gcc32
	elif [ $COMPILER = "clang" ]
	then
	        echo  "|| Cloning Clang-14 ||"
		git clone --depth=1 https://gitlab.com/ImSpiDy/azure-clang.git clang
	fi

         echo "|| Cloning Anykernel ||"
	git clone --depth=1 -b lavender https://github.com/nexus-projects/AnyKernel3
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER="prashant"

function XD() {
if [ $COMPILER = "clang" ]
	then
        export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
		PATH="${PWD}/clang/bin:$PATH"
	elif [ $COMPILER = "gcc" ]
	then
		export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/gcc64/bin/aarch64-elf-gcc --version | head -n 1)
		PATH=${KERNEL_DIR}/gcc64/bin/:/usr/bin:$PATH
	fi
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>$KBUILD_BUILD_VERSION CI Build Triggered</b>%0A<b>Kernel Version : </b><code>$KERVER</code>%0A<b>Date : </b><code>$(TZ=Asia/Kolkata date)</code>%0A<b>Device : </b><code>$MODEL [$DEVICE]</code>%0A<b>Pipeline Host : </b><code>$KBUILD_BUILD_HOST</code>%0A<b>Compiler Used : </b><code>$KBUILD_COMPILER_STRING</code>%0A<b>Top Commit : </b><a href='$DRONE_COMMIT_LINK'>$COMMIT_HEAD</a>"
}
# Push kernel to channel
function push() {
    cd AnyKernel3
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Redmi Note 7/7s (lavender)</b> | <b>${KBUILD_COMPILER_STRING}</b>"
}
# Fin Error
function finerr() {
    LOG=error.log
   curl -F document=@$LOG "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
           
    if [ $COMPILER = "clang" ]
	then
		make O=out ARCH=arm64 ${DEFCONFIG}
		make -j$(nproc --all) O=out \
				ARCH=arm64 \
				CC=clang \
				AR=llvm-ar \
				NM=llvm-nm \
				OBJCOPY=llvm-objcopy \
				OBJDUMP=llvm-objdump \
				STRIP=llvm-strip \
                                V=$VERBOSE \
                                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
				CROSS_COMPILE=aarch64-linux-gnu- 2>&1 | tee error.log

	elif [ $COMPILER = "gcc" ]
	then
	        make O=out ARCH=arm64 ${DEFCONFIG}
	        make -j$(nproc --all) O=out \
	                        ARCH=arm64 \
                                CROSS_COMPILE=aarch64-elf- \
			        AR=aarch64-elf-ar \
			        OBJDUMP=aarch64-elf-objdump \
			        STRIP=aarch64-elf-strip \
                                V=$VERBOSE \
			        CROSS_COMPILE_ARM32=arm-eabi- | tee error.log
	fi

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp $IMAGE AnyKernel3
}
# Zipping
function zipping() {
    cd AnyKernel3 || exit 1
    zip -r9 Nexus-EAS-v9.3-old-${DEVICE}-KERNEL-${TANGGAL}.zip *
    cd ..
}
clone
XD
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
