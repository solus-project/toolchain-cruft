#!/bin/bash
# 
# Copyright (c) 2015 Ikey Doherty
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

source "${SUBFILE}"

PACKAGES=(linux-headers)

TOOLCHAIN_ASSETS=(common.sh config.sh master.sh stage_common.sh sub_common.sh)

CHROOT_PREFIX="${PKG_INSTALL_DIR}/buildsys" # /buildsys

CHROOT_STAGE_DIR="${CHROOT_PREFIX}/profiles/${BUILD_PROFILE}/${STAGE}"
CHROOT_PROFILE_DIR="${CHROOT_PREFIX}/profiles/${BUILD_PROFILE}"
CHROOT_SOURCES_DIR="${CHROOT_PREFIX}/sources" # /buildsys/sources
CHROOT_PATCHES_DIR="${CHROOT_PREFIX}/patches" # /buildsys/patches

NORMAL_DIRECTORIES=(
    /usr/include /usr/share/man /usr/share/doc /usr/lib64 /usr/lib32 /usr/bin /usr/sbin
    /bin /sbin /lib64 /lib32
)

prepare_chroot()
{
    set -e

    # Defines the filesystem characteristics pretty much permanently.
    # Tread careful
    for directory in "${NORMAL_DIRECTORIES[@]}" ; do
        tgt="${PKG_INSTALL_DIR}/${directory}"
        if [[ ! -d "${tgt}" ]]; then
            sudo mkdir -pv "${tgt}"
        fi
    done

    # Makes lib64 primary, with "lib" as a symlink
    if [[ ! -e "${PKG_INSTALL_DIR}/lib" ]]; then
        sudo ln -sv lib64 "${PKG_INSTALL_DIR}/lib"
    fi
    if [[ ! -e "${PKG_INSTALL_DIR}/usr/lib" ]]; then
        sudo ln -sv lib64 "${PKG_INSTALL_DIR}/usr/lib"
    fi

    if [[ ! -d "${PKG_INSTALL_DIR}/dev" ]]; then
        sudo mkdir -pv "${PKG_INSTALL_DIR}/dev"
    fi
    if [[ ! -e "${PKG_INSTALL_DIR}/dev/console" ]]; then
        sudo mknod -m 600 "${PKG_INSTALL_DIR}/dev/console" c 5 1
    fi
    if [[ ! -e "${PKG_INSTALL_DIR}/dev/null" ]]; then
        sudo mknod -m 666 "${PKG_INSTALL_DIR}/dev/null" c 1 3
    fi

    # Partly demangle the LFS style gcc
    sudo ln -sv /tools/lib/libgcc_s.so{,.1} "${PKG_INSTALL_DIR}/usr/lib64" || :
    sudo ln -sv /tools/lib32/libgcc_s.so{,.1} "${PKG_INSTALL_DIR}/usr/lib32" || :
    sudo ln -sv /tools/lib/libstdc++.so{,.6} "${PKG_INSTALL_DIR}/usr/lib64" || :
    sudo ln -sv /tools/lib32/libstdc++.so{,.6} "${PKG_INSTALL_DIR}/usr/lib32" || :

    sudo mount -v --bind /dev/ "${PKG_INSTALL_DIR}/dev"
    sudo mount -v -t devpts devpts "${PKG_INSTALL_DIR}/dev/pts"
    sudo mount -v -t tmpfs shm "${PKG_INSTALL_DIR}/dev/shm"
    if [[ ! -d "${PKG_INSTALL_DIR}/sys" ]]; then
        sudo mkdir -pv "${PKG_INSTALL_DIR}/sys"
    fi
    if [[ ! -d "${PKG_INSTALL_DIR}/proc" ]]; then
        sudo mkdir -pv "${PKG_INSTALL_DIR}/proc"
    fi
    sudo mount -v -t sysfs sysfs "${PKG_INSTALL_DIR}/sys"
    sudo mount -v -t proc proc "${PKG_INSTALL_DIR}/proc"
}

# Copy our own system into the chroot for further usage.
copy_chroot_system()
{
    if [[ ! -d ${CHROOT_PREFIX} ]]; then
        echo "Copying chroot system across"
        sudo mkdir -p ${CHROOT_PREFIX} || do_fatal "Unable to create dir"
    fi
    # Update the chroot assets
    for asset in "${TOOLCHAIN_ASSETS[@]}" ; do
        sudo cp -v "${SYSTEM_BASE_DIR}/${asset}" "${CHROOT_PREFIX}/${asset}" || do_fatal "Could not copy required asset: ${asset}"
    done

    sudo chmod +x "${CHROOT_PREFIX}/master.sh" || do_fatal "Cannot make master.sh executable"

    # new stage dir.
    if [[ ! -d "${CHROOT_STAGE_DIR}" ]]; then
        sudo mkdir -p "${CHROOT_STAGE_DIR}" || do_fatal "Cannot create chroot directory"
    fi

    # Ensure bash actually works properly (shebangs)
    if [[ ! -d "${PKG_INSTALL_DIR}/bin" ]]; then
        sudo mkdir -p "${PKG_INSTALL_DIR}/bin"  || do_fatal "Cannot create bin directory"
    fi
    if [[ ! -e "${PKG_INSTALL_DIR}/bin/bash" ]]; then
        sudo ln -sv /tools/bin/bash "${PKG_INSTALL_DIR}/bin/bash" || do_fatal "Cannot create bash link"
    fi
    if [[ ! -e "${PKG_INSTALL_DIR}/bin/sh" ]]; then
        sudo ln -sv /tools/bin/bash "${PKG_INSTALL_DIR}/bin/sh" || do_fatal "Cannot create sh link"
    fi

    for package in "${PACKAGES[@]}" ; do
        sudo cp -v "${package}.sh" "${CHROOT_STAGE_DIR}/${package}.sh" || do_fatal "Cannot copy package: ${package}"
        sudo chmod +x "${CHROOT_STAGE_DIR}/${package}.sh"
    done
    sudo cp -v sub.sh "${CHROOT_STAGE_DIR}/sub.sh" || do_fatal "Cannot copy required sub.sh"

    sudo tee  "${CHROOT_PROFILE_DIR}/profile.sh" >/dev/null << EOF
source "\${STAGEFILE}"

STAGES=(${STAGE_ID})

execute_stages
EOF
    sudo chmod +x "${CHROOT_PROFILE_DIR}/profile.sh" || do_fatal "Cannot chmod profile"
}

up_chroot()
{
    prepare_chroot
    export BUILD_SYS_HAVE_MOUNT="1"
    echo "Mounting sources/patches binds"
    if [[ ! -d "${CHROOT_SOURCES_DIR}" ]]; then
        sudo mkdir -p "${CHROOT_SOURCES_DIR}" || do_fatal "Cannot make sources directory"
    fi
    if [[ ! -d "${CHROOT_PATCHES_DIR}" ]]; then
        sudo mkdir -p "${CHROOT_PATCHES_DIR}" || do_fatal "Cannot make patches directory"
    fi
    sudo mount --bind "${SOURCESDIR}" "${CHROOT_SOURCES_DIR}" || do_fatal "Cannot bind-mount sources"
    sudo mount --bind "${PATCHESDIR}" "${CHROOT_PATCHES_DIR}" || do_fatal "Cannot bind-mount patches"
}

down_chroot()
{
    sync
    sudo umount "${CHROOT_SOURCES_DIR}"
    sync
    sudo umount "${CHROOT_PATCHES_DIR}"
    sync
    sudo umount "${PKG_INSTALL_DIR}/dev/pts"
    sudo umount "${PKG_INSTALL_DIR}/dev/shm"
    sudo umount "${PKG_INSTALL_DIR}/dev"
    sudo umount "${PKG_INSTALL_DIR}/proc"
    sudo umount "${PKG_INSTALL_DIR}/sys"
    export BUILD_SYS_HAVE_MOUNT="0"
}
    
do_cleanup()
{
    if [[ "${BUILD_SYS_HAVE_MOUNT}" == "1" ]]; then
        echo "Cleaniing up bind mounts"
        down_chroot
    fi
}

# Allow prefetching
if [[ ! -z "${PREFETCH}" ]]; then
    build_all
    exit 0
fi

# Only build within the chroot.
if [[ -z "${TOOLCHAIN_CHROOT}" ]]; then
    copy_chroot_system
    up_chroot
    # TODO: execute new sub and not this place holder :P
    sudo chroot "${PKG_INSTALL_DIR}" "/tools/bin/bash" "/buildsys/master.sh" "CHROOTED_BUILD"

    sleep 1
    down_chroot
else
    # TODO: demangle gcc
    build_all
fi

