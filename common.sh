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

# Default configuration options
if [[ -z "${CONFIGURE_OPTIONS}" ]]; then
    CONFIGURE_OPTIONS="--prefix=/usr "
fi

# TODO: Make this a configuration item somewhere
MAKE_CONCURRENCY="-j5"

# Perform some sanity checks or bail immediately
function sanity_check()
{
    if [[ -z "${WORKDIR}" ]]; then
        echo "WorkDir is not set in ${0}"
        exit 1
    fi

    if [[ -z "${PKG_NAME}" ]]; then
        echo "PKG_NAME is not set in ${0}"
        exit 1
    fi

    if [[ -z "${PKG_URL}" ]]; then
        echo "PKG_URL is not set in ${0}"
        exit 1
    fi
    if  [[ -z "${PKG_HASH}" ]]; then
        echo "PKG_HASH is not set in ${0}"
    fi
}

function do_fatal()
{
    echo "$*"
    exit 1
}

function ensure_file_hash()
{
    local url="${1}"
    local filename="$(basename ${1})"
    local tarball="${SOURCESDIR}/${filename}"
    local ehash="${2}"

    if [[ -f "${tarball}" ]]; then
        echo "${filename} exists, skipping download"
    else
        # Fetch the tarball
        pushd "${SOURCESDIR}" >/dev/null || do_fatal "Failed to change to sources dir"
        wget "${url}" || do_fatal "Failed to retrieve: ${url}"
        popd >/dev/null
    fi

    # Ensure hash is consistent
    local hash="$(sha256sum ${SOURCESDIR}/${filename}|cut -f 1 -d ' ')"
    echo "Checking hash for ${PKG_NAME}: ${filename}"
    if [[ "${hash}" != "${ehash}" ]]; then
        do_fatal "Incorrect hash for ${filename}, expected: ${ehash}"
    fi
}

function pkg_fetch()
{
    ensure_file_hash "${PKG_URL}" "${PKG_HASH}"

    # See if this package has extra files it needs
    for tarball in "${!PKG_EXTRAS[@]}"; do
        local sum="${PKG_EXTRAS["${tarball}"]}";
        ensure_file_hash "${tarball}" "${sum}"
    done
}

function pkg_build_dir()
{
    echo "${WORKDIR}/${PKG_NAME}-build"
}

function pkg_source_dir()
{
    local filename="$(basename ${PKG_URL})"
    local name="${filename%.*}"
    local name="$(echo ${filename} | sed 's/\.tar\..*//')"
    echo "${WORKDIR}/${name}"
}

function pkg_tarball()
{
    echo "${SOURCESDIR}/$(basename ${PKG_URL})"
}

function check_prereqs()
{
    # Default behaviour, extract tarball
    pkg_dir=`pkg_source_dir`
    build_dir=`pkg_build_dir`


    if [[ ! -d "${build_dir}" ]]; then
        mkdir -p "${build_dir}" || do_fatal "Cannot create ${build_dir}"
    fi
}

# Default extract routine
function pkg_extract()
{
    check_prereqs

    local pkg_dir=`pkg_source_dir`
    local build_dir=`pkg_build_dir`
    local tarball=`pkg_tarball`

    # Extract tarball if needed
    if [[ ! -d "${pkg_dir}" ]]; then
        pushd "${WORKDIR}" >/dev/null || do_fatal "Cannot cd to workdir"
        echo "Extracting source for ${PKG_NAME}"
        tar xf "${tarball}" || do_fatal "Could not decompress tarball"
        popd > /dev/null
        mkdir -p "${pkg_dir}" || do_fatal "Cannot create ${pkg_dir}"
    fi
}

#
# Default configure routine
#
function pkg_configure()
{
    local pkg_dir=`pkg_source_dir`
    local build_dir=`pkg_build_dir`

    pushd "${build_dir}" >/dev/null || do_fatal "Unable to use build directory"

    pkg_configure_no_cd
    
    popd >/dev/null
}

function pkg_configure_no_cd()
{
    (set -x ; eval "${pkg_dir}/configure ${CONFIGURE_OPTIONS}" || do_fatal "Failed to configure ${PKG_NAME}")
}

function pkg_setup()
{
    pkg_extract
    pkg_configure
}

function pkg_build()
{
    check_prereqs

    local build_dir=`pkg_build_dir`
    pushd "${build_dir}" >/dev/null || do_fatal "Unable to use build directory"

    (set -x ; eval "make ${MAKE_CONCURRENCY}" || do_fatal "Failed to build ${PKG_NAME}")
}

function pkg_make()
{
    (set -x ; eval "make ${MAKE_CONCURRENCY} $*" || do_fatal "Failed to build ${PKG_NAME}")
}

function make_install()
{
    check_prereqs

    local build_dir=`pkg_build_dir`
    pushd "${build_dir}" >/dev/null || do_fatal "Unable to use build directory"

    (set -x ; eval "make ${MAKE_CONCURRENCY} install $*" || do_fatal "Failed to build ${PKG_NAME}")
}

function pkg_install()
{
    make_install
}

function handle_args()
{
    if [[ -z "${1}" ]]; then
        do_fatal "Missing arguments for ${PKG_NAME}"
    fi
    case $1 in
        fetch)
            pkg_fetch
            ;;
        setup)
            pkg_setup
            ;;
        build)
            pkg_build
            ;;
        install)
            pkg_install
            ;;
        *)
            do_fatal "Unrecognised argument for ${PKG_NAME}: $1"
            ;;
    esac
}

sanity_check
