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

export TOOLCHAIN="x86_64-solus-linux"
export TOOLCHAIN32="i686-solus-linux"
export WORKDIRBASE="`realpath ./BUILD/`"
export FUNCTIONSFILE="`realpath ./common.sh`"
export SUBFILE="`realpath ./sub_common.sh`"
export SOURCESDIR="`realpath ./sources`"

function do_fatal()
{
    echo "$*"
    exit 1
}

function execute_stage()
{
    local stage="$1"

    export STAGE="stage${stage}"
    export WORKDIR="${WORKDIRBASE}/${STAGE}"
    pushd "${STAGE}" > /dev/null 2>/dev/null || exit 1
    echo "Checking stage ${stage}"
    ./sub.sh
    popd >/dev/null 2>/dev/null
}

# Construct support directories
if [[ ! -d "${SOURCESDIR}" ]]; then
    mkdir -p "${SOURCESDIR}" || do_fatal "Cannot create sources directory"
fi
if [[ ! -d "${WORKDIRBASE}" ]]; then
    mkdir -p "${WORKDIRBASE}" || do_fatal "Cannot create work base directory"
fi

STAGES=(1)

for stage in "${STAGES[@]}" ; do
    execute_stage "${stage}"
done



