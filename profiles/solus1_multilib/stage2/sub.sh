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

PACKAGES=(libstdc++ binutils gcc ncurses bash coreutils util-linux grep
          sed tar bzip2 gzip xz diffutils patch file findutils gawk gettext
          m4 make texinfo perl)

old_path="${PATH}"

export PATH="/tools/bin:/tools/usr/bin:${PATH}"

# We also have our own pre-requisites on the toolchain..
export CONFIGURE_OPTIONS="--prefix=/tools "

if [[ ! -d "${PKG_INSTALL_DIR}/tools" ]]; then
    mkdir -p "${PKG_INSTALL_DIR}/tools" || do_fatal "Cannot create required tools directory"
fi

# Ensure we have a /tools/ symlink
if [[ ! -e /tools/ ]]; then
    sudo ln -sv "${PKG_INSTALL_DIR}/tools" /tools || do_fatal "Cannot create required /tools/ symlink"
fi

build_all

if [[ ! -e /tools/.cleaned ]]; then
    echo "Cleaning tools rootfs"
    strip --strip-debug /tools/lib/*
    strip --strip-debug /tools/lib32/*
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/*
    rm -rf /tools/{,share}/{info,man,doc}
    echo "cleaned" >> /tools/.cleaned
    echo "Chowning /tools/ to root"
    sudo chown -R root:root "${PKG_INSTALL_DIR}/tools" || do_fatal "Could not chown rootfs. Please fix."
fi
