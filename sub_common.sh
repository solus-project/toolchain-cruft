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

function do_fatal()
{
    echo "$*"
    exit 1
}

function build_package()
{
    if [[ -z "${1}" ]]; then
        echo "Missing package. Aborting"
        exit 1
    fi

    eval "./${1}.sh" fetch   || do_fatal "Failed to fetch package ${1}"
    eval "./${1}.sh" setup   || do_fatal "Failed to setup package ${1}"
    eval "./${1}.sh" build   || do_fatal "Failed to build package ${1}"
    eval "./${1}.sh" install || do_fatal "Failed to install package ${1}"
}

function build_all()
{
    if [[ -z "${PACKAGES}" ]]; then
        echo "Packages not set. Aborting"
        exit 1
    fi

    for pkg in "${PACKAGES[@]}" ; do
        echo "Building package: ${pkg}"
        build_package "${pkg}"
    done
}

