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

# Always set PKG_NAME
PKG_NAME="binutils"
PKG_URL="http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2"
PKG_HASH="b5b14added7d78a8d1ca70b5cb75fef57ce2197264f4f5835326b0df22ac9f22"

source "${FUNCTIONSFILE}"

OUR_LIB_DIRS="/tools/lib:/tools/lib32"

# Define overrides
CONFIGURE_OPTIONS+="--with-lib-path=${SYSTEM_LIB_DIRS} \
                    --disable-nls \
                    --disable-werror \
                    --disable-gold \
                    --target=${XTOOLCHAIN} \
                    --with-sysroot=\"${PKG_INSTALL_DIR}\" \
                    --enable-64-bit-bfd"

pkg_install()
{
    mkdir -p /tools/lib
    ln -sv lib /tools/lib64
    mkdir -p /tools/lib32
    make_install
}

# Now handle the arguments
handle_args $*
