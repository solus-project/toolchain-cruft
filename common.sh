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
}

function do_fatal()
{
    echo "$*"
    exit 1
}

function pkg_setup()
{
    echo "Setup: Nothing to be done for ${PKG_NAME}"
}

function pkg_build()
{
    echo "Build: Nothing to be done for ${PKG_NAME}"
}

function pkg_install()
{
    echo "Install: Nothing to be done for ${PKG_NAME}"
}

function handle_args()
{
    if [[ -z "${1}" ]]; then
        do_fatal "Missing arguments for ${PKG_NAME}"
    fi
    case $1 in
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

echo "Setting Workdir is ${WORKDIR}"
if [[ ! -d "${WORKDIR}" ]]; then
    mkdir -p "${WORKDIR}" || do_fatal "Cannot create required work directory"
fi

pushd "${WORKDIR}" >/dev/null || do_fatal "Cannot change to work directory"
