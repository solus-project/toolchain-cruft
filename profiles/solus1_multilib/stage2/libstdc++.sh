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
PKG_NAME="libstdc++"
PKG_URL="http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2"
PKG_HASH="5f835b04b5f7dd4f4d2dc96190ec1621b8d89f2dc6f638f9f8bc1b1014ba8cad"

source "${FUNCTIONSFILE}"

CONFIGURE_COMMON="--prefix=/tools \
                  --disable-nls \
                  --disable-multilib \
                  --disable-libstdcxx-pch \
                  --with-gxx-include-dir=/tools/${XTOOLCHAIN}/include/c++/5.2.0"

CONFIGURE_OPTIONS32="${CONFIGURE_OPTIONS} \
                     ${CONFIGURE_COMMON} \
                     --host=${XTOOLCHAIN32} \
                     --libdir=/tools/lib32 \
                     CC=\"${XTOOLCHAIN}-gcc -m32\" \
                     CXX=\"${XTOOLCHAIN}-g++ -m32\" "
CONFIGURE_OPTIONS64="${CONFIGURE_OPTIONS} \
                     ${CONFIGURE_COMMON} \
                     --host=${XTOOLCHAIN} \
                     CC=\"${XTOOLCHAIN}-gcc -m64\" \
                     CXX=\"${XTOOLCHAIN}-g++ -m64\" "
                     
                     
pkg_setup()
{
    local sourcedir=`pkg_source_dir`
    local builddir=`pkg_build_dir`

    # Extract main package
    pkg_extract

    pushd "${builddir}" >/dev/null || do_fatal "Could not change to builddir"

    mkdir {b32,b64} || do_fatal "Could not create required dirs"

    # Configure 32-bit
    pushd b32 || do_fatal "could not change to b32"
    echo "slibdir=/tools/lib32" > configparms
    eval "${sourcedir}/libstdc++-v3/configure " ${CONFIGURE_OPTIONS32} || do_fatal "Could not configure libstdc++ 32-bit"
    popd

    # Now 64-bit
    pushd b64 > /dev/null || do_fatal "could not change to b64"
    eval "${sourcedir}/libstdc++-v3/configure " ${CONFIGURE_OPTIONS64} || do_fatal "Could not configure libstdc++ 64-bit"
    popd > /dev/null

    popd > /dev/null
}

pkg_build()
{
    local builddir=`pkg_build_dir`
    pushd "${builddir}" >/dev/null || do_fatal "Could not change to builddir"

    # Build 32-bit libstdc++
    pushd b32 || do_fatal "could not change to b32"
    pkg_make
    popd >/dev/null

    # Build 64-bit libstdc++
    pushd b64 || do_fatal "could not change to b64"
    pkg_make
    popd >/dev/null


    popd >/dev/null
}

pkg_install()
{
    local builddir=`pkg_build_dir`
    pushd "${builddir}" >/dev/null || do_fatal "Could not change to builddir"

    # Install 32-bit libstdc++
    pushd b32 || do_fatal "could not change to b32"
    pkg_make install
    popd >/dev/null

    # Install 64-bit libstdc++
    pushd b64 || do_fatal "could not change to b64"
    pkg_make install
    popd >/dev/null


    popd >/dev/null
}

# Now handle the arguments
handle_args $*
