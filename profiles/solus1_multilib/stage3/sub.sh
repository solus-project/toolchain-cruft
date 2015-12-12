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

# PACKAGES=(YADAYADA)

TOOLCHAIN_ASSETS=(common.sh config.sh master.sh stage_common.sh sub_common.sh)

CHROOT_STAGE_DIR="/tools/buildsys/profiles/${BUILD_PROFILE}/${STAGE}"
CHROOT_PROFILE_DIR="/tools/buildsys/profiles/${BUILD_PROFILE}"

# Copy our own system into the chroot for further usage.
copy_chroot_system()
{
    if [[ ! -d /tools/buildsys ]]; then
        echo "Copying chroot system across"
        sudo mkdir -p /tools/buildsys || do_fatal "Unable to create dir"
    fi
    # Update the chroot assets
    for asset in "${TOOLCHAIN_ASSETS[@]}" ; do
        sudo cp -v "${SYSTEM_BASE_DIR}/${asset}" "/tools/buildsys/${asset}" || do_fatal "Could not copy required asset: ${asset}"
    done

    # new stage dir.
    if [[ ! -d "${CHROOT_STAGE_DIR}" ]]; then
        sudo mkdir -p "${CHROOT_STAGE_DIR}" || do_fatal "Cannot create chroot directory"
    fi

    for package in "${PACKAGES[@]}" ; do
        sudo cp -v "${package}.sh" "${CHROOT_STAGE_DIR}/${package}.sh" || do_fatal "Cannot copy package: ${package}"
    done
    sudo cp -v sub.sh "${CHROOT_STAGE_DIR}/sub.sh" || do_fatal "Cannot copy required sub.sh"

    sudo tee  "${CHROOT_PROFILE_DIR}/profile.sh" >/dev/null << EOF
source "\${STAGEFILE}"

STAGES=(${STAGE_ID})

execute_stages
EOF
}

# Allow prefetching
if [[ ! -z "${PREFETCH}" ]]; then
    build_all
    exit 0
fi

# Only build within the chroot.
if [[ -z "${TOOLCHAIN_CHROOT}" ]]; then
    copy_chroot_system
    # TODO: demangle gcc
    # TODO: execute new sub
else
    build_all
fi

