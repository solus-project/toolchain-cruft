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
PKG_NAME="gcc"
PKG_URL="http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2"
PKG_HASH="5f835b04b5f7dd4f4d2dc96190ec1621b8d89f2dc6f638f9f8bc1b1014ba8cad"

# Required assets during build
declare -A PKG_EXTRAS=(
    ["http://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz"]="ed5a815cfea525dc778df0cb37468b9c1b554aaf30d9328b1431ca705b7400ff"
    ["http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.xz"]="399d0f47ef6608cc01d29ed1b99c7faff36d9994c45f36f41ba250147100453b"
    ["http://ftp.gnu.org/gnu/gmp/gmp-5.1.2.tar.xz"]="c7d943a6eceb4f0d3d3ab1176aec37853831cdfa281e012f8a344ba3ceefcbc2"
)

source "${FUNCTIONSFILE}"

CONFIGURE_OPTIONS+="--enable-languages=c,c++ \
                    --with-arch32=i686 \
                    --with-native-system-header-dir=\"/usr/include\" \
                    --with-local-prefix=/usr \
                    --disable-libstdcxx-pch \
                    --disable-libgomp \
                    --host=\"${XTOOLCHAIN}\" \
                    --target=\"${TOOLCHAIN}\" \
                    --with-multilib-list=m32,m64"

demangle_root()
{
    # Undo the LFS style /tools change, credit to them
    gcc -dumpspecs | sed -e 's@/tools@@g'                   \
        -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
        -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
        `dirname $(gcc --print-libgcc-file-name)`/specs

    mv -v /tools/bin/{ld,ld-old} || :
    mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old} || :
    cp -v /tools/bin/ld-new /tools/bin/ld || :
    ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld || :
}

pkg_setup()
{
    local sourcedir=`pkg_source_dir`
    local builddir=`pkg_build_dir`

    # Extract main package
    pkg_extract

    # Now extract our own..
    echo "Extracting GCC extras"
    pushd "${sourcedir}" >/dev/null || do_fatal "Could not change to source dir"
    tar xf "${SOURCESDIR}/mpc-1.0.1.tar.gz" || do_fatal "Could not extract mpc tarball"
    mv mpc-1.0.1 mpc
    tar xf "${SOURCESDIR}/mpfr-3.1.2.tar.xz" || do_fatal "Could not extract mpfr tarball"
    mv mpfr-3.1.2 mpfr
    tar xf "${SOURCESDIR}/gmp-5.1.2.tar.xz" || do_fatal "Could not extract gmp tarball"
    mv gmp-5.1.2 gmp

    # Apply patches
    patch -p1 < "${PATCHESDIR}/gcc/0001-Prebuild-changes.patch" || do_fatal "Could not patch GCC"
    patch -p1 < "${PATCHESDIR}/gcc/0001-Use-usr-lib-64-32-x32-for-linker-locations-on-Solus-.patch" || do_fatal "Could not patch GCC"

    popd >/dev/null

    pushd "${builddir}" > /dev/null || do_fatal "Cannot cd to build dir"
    # Now go back to the main configure routine
    eval "$(pkg_source_dir)/configure" $CONFIGURE_OPTIONS
    popd >/dev/null
}

# Now handle the arguments
handle_args $*
