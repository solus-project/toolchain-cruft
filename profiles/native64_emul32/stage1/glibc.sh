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
PKG_NAME="glibc"
PKG_URL="http://ftp.gnu.org/gnu/glibc/glibc-2.22.tar.xz"
PKG_HASH="eb731406903befef1d8f878a46be75ef862b9056ab0cde1626d08a7a05328948"

source "${FUNCTIONSFILE}"

# We told GCC we didn't have any headers (lied), but here we now
# give glibc the system include path, /usr/include
CONFIGURE_COMMON="--disable-profile \
                  --enable-kernel=2.6.25 \
                  --enable-add-ons \
                  --without-selinux \
                  libc_cv_forced_unwind=yes \
                  libc_cv_ctors_header=yes \
                  --with-headers=/usr/include \
                  libc_cv_c_cleanup=yes"

CONFIGURE_OPTIONS32="${CONFIGURE_OPTIONS} \
                     ${CONFIGURE_COMMON} \
                     --host=${XTOOLCHAIN32} \
                     --build=${TOOLCHAIN} \
                     CC=\"${XTOOLCHAIN}-gcc -m32\" \
                     CXX=\"${XTOOLCHAIN}-g++ -m32\" "
CONFIGURE_OPTIONS64="${CONFIGURE_OPTIONS} \
                     ${CONFIGURE_COMMON} \
                     --host=${XTOOLCHAIN} \
                     --build=${TOOLCHAIN} \
                     CC=\"${XTOOLCHAIN}-gcc -m64\" \
                     CXX=\"${XTOOLCHAIN}-g++ -m64\" "
                     
                     
pkg_setup()
{
    local sourcedir=`pkg_source_dir`
    local builddir=`pkg_build_dir`

    # Extract main package
    pkg_extract

    # Now extract our own..
    pushd "${sourcedir}" >/dev/null || do_fatal "Could not change to source dir"
    # patch glibc regression
    sed -e '/ia32/s/^/1:/' -e '/SSE2/s/^1://' -i  sysdeps/i386/i686/multiarch/mempcpy_chk.S
    popd >/dev/null

    pushd "${builddir}" >/dev/null || do_fatal "Could not change to builddir"

    mkdir {b32,b64} || do_fatal "Could not create required dirs"

    # Configure 32-bit
    pushd b32 || do_fatal "could not change to b32"
    echo "slibdir=/usr/lib32" > configparams
    CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS32}" pkg_configure_no_cd || do_fatal "Could not configure glibc 32-bit"
    popd

    # Now 64-bit
    pushd b64 > /dev/null || do_fatal "could not change to b64"
    echo "slibdir=/usr/lib64" > configparams
    CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS64}" pkg_configure_no_cd || do_fatal "Could not configure glibc 64-bit"
    popd > /dev/null

    popd > /dev/null
}

pkg_build()
{
    local builddir=`pkg_build_dir`
    pushd "${builddir}" >/dev/null || do_fatal "Could not change to builddir"

    # Build 32-bit glibc
    pushd b32 || do_fatal "could not change to b32"
    pkg_make
    popd >/dev/null

    # Build 64-bit glibc
    pushd b64 || do_fatal "could not change to b64"
    pkg_make
    popd >/dev/null


    popd >/dev/null
    }

pkg_install()
{
    echo "Not yet implemented"
}

# Now handle the arguments
handle_args $*
