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
PKG_NAME="ncurses"
PKG_URL="http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz"
PKG_HASH="9046298fb440324c9d4135ecea7879ffed8546dd1b58e59430ea07a4633f563b"

source "${FUNCTIONSFILE}"

# Define overrides
CONFIGURE_COMMON="--prefix=/tools \
                  --with-shared \
                  --without-debug \
                  --enable-widec \
                  --enable-symlinks \
                  --disable-rpath \
                  --disable-static \
                  --enable-overwrite"

CONFIGURE_OPTIONS32="${CONFIGURE_COMMON} \
                     --libdir=/tools/lib32 \
                     CC=\"gcc -m32\" CXX=\"g++ -m32\""

CONFIGURE_OPTIONS64="${CONFIGURE_COMMON}"

pkg_setup()
{
    pkg_extract
}

pkg_build()
{
    return
}

pkg_install()
{
    set -e

    pushd $(pkg_source_dir) > /dev/null

    # Address failure on GCC5
    patch -p1 < "${PATCHESDIR}/ncurses/gcc5.patch"

    CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS32}" pkg_configure_no_cd
    pkg_make
    pkg_make install
    pkg_make clean

    CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS64}" pkg_configure_no_cd
    pkg_make
    pkg_make install
    pkg_make clean

    popd > /dev/null
}

# Now handle the arguments
handle_args $*
