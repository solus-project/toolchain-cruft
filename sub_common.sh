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

trap 'do_cleanup; exit' SIGHUP SIGINT SIGTERM EXIT

function do_fatal()
{
    echo "$*"
    exit 1
}

function do_cleanup()
{
    echo "TODO: Add cleanup handler"
}

function build_package()
{
    if [[ -z "${1}" ]]; then
        echo "Missing package. Aborting"
        exit 1
    fi

    local tfile="${WORKDIR}/${1}.status"
    local tstatus="$(cat ${tfile} 2>/dev/null)"

    case ${tstatus} in
        fetch)
            steps=(setup build install)
            ;;
        setup)
            steps=(build install)
            ;;
        build)
            steps=(install)
            ;;
        install)
            echo "Skipping ${1} as it is complete"
            return
            ;;
        *)
            steps=(fetch setup build install)
            ;;
    esac

    for step in "${steps[@]}" ; do
        eval "./${1}.sh" "${step}" || do_fatal "Failure in ${1}: ${step}"
        if [[ ! -d "${WORKDIR}" ]]; then
            mkdir -p "${WORKDIR}" || do_fatal "Cannot create work directory"
        fi
        echo "${step}" > "${tfile}"
    done
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

