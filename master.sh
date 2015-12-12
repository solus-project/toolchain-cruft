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

# We might be in a chroot.
if [[ "${1}" == "CHROOTED_BUILD" ]]; then
    export TOOLCHAIN_CHROOT="1"
    export PATH="/usr/bin:/usr/sbin:/bin:/sbin:/tools/bin:/tools/sbin"
    cd /buildsys/
fi

. config.sh

export TOOLCHAIN
export XTOOLCHAIN
export TOOLCHAIN32
export XTOOLCHAIN32
export BUILD_PROFILE


# Required directories
export FUNCTIONSFILE="`realpath ./common.sh`"
export SUBFILE="`realpath ./sub_common.sh`"
export STAGEFILE="`realpath ./stage_common.sh`"
export PROFILEDIR="`realpath ./profiles`"
export PATCHESDIR="`realpath ./patches`"

SOURCESDIR="sources"
WORKDIRBASE="BUILD"
PKG_INSTALL_DIR="BUILD/install"

export SYSTEM_BASE_DIR=`realpath $(dirname ${0})`

function do_fatal()
{
    echo "$*"
    exit 1
}

# Construct support directories
if [[ -z "${TOOLCHAIN_CHROOT}" ]]; then
    if [[ ! -d "${SOURCESDIR}" ]]; then
        mkdir -p "${SOURCESDIR}" || do_fatal "Cannot create sources directory"
    fi
fi

export SOURCESDIR="$(realpath ${SOURCESDIR})"

if [[ ! -d "${WORKDIRBASE}" ]]; then
    mkdir -p "${WORKDIRBASE}" || do_fatal "Cannot create work base directory"
fi
export WORKDIRBASE="$(realpath ${WORKDIRBASE}/)"

if [[ ! -d "${PKG_INSTALL_DIR}" ]]; then
    mkdir -p "${PKG_INSTALL_DIR}" || do_fatal "Cannot create install directory"
fi
export PKG_INSTALL_DIR="$(realpath ${PKG_INSTALL_DIR}/)"

profile_file="${PROFILEDIR}/${BUILD_PROFILE}/profile.sh"
if [[ ! -x "${profile_file}" ]]; then
    do_fatal "Cannot execute profile ${BUILD_PROFILE}"
fi


pushd "${PROFILEDIR}/${BUILD_PROFILE}" >/dev/null || do_fatal "Cannot change to build profile dir"
if [[ -z "${TOOLCHAIN_CHROOT}" ]]; then
    eval PREFETCH="1" "${profile_file}" || do_fatal "Profile prefetch failed for ${BUILD_PROFILE}"
fi
eval "${profile_file}" || do_fatal "Profile build failed for ${BUILD_PROFILE}"
popd >/dev/null
