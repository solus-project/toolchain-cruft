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
                    --with-local-prefix=/tools \
                    --disable-bootstrap \
                    --with-native-system-header-dir=\"/tools/include\" \
                    --disable-libstdcxx-pch \
                    --disable-libgomp \
                    --with-multilib-list=m32,m64"

pkg_root_mangle()
{
    # Credit to LFS!
    for file in \
     $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
    do
      cp -uv $file{,.orig}
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
          -e 's@/usr@/tools@g' $file.orig > $file
      echo '
    #undef STANDARD_STARTFILE_PREFIX_1
    #undef STANDARD_STARTFILE_PREFIX_2
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
      touch $file.orig
    done
    sed -i -e 's@/libx32/ld-linux-x32.so.2@/tools/libx32/ld-linux-x32.so.2@g' gcc/config/i386/linux64.h
    sed -i -e 's@/lib/ld-linux.so.2@/lib32/ld-linux.so.2@g' gcc/config/i386/linux64.h
    sed -i -e '/MULTILIB_OSDIRNAMES/d' gcc/config/i386/t-linux64
    echo "MULTILIB_OSDIRNAMES = m64=../lib m32=../lib32 mx32=../libx32" >> gcc/config/i386/t-linux64
}

pkg_setup()
{
    local sourcedir=`pkg_source_dir`

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

    pkg_root_mangle

    popd >/dev/null

    # Now go back to the main configure routine
    pkg_configure CC="${XTOOLCHAIN}-gcc" CXX="${XTOOLCHAIN}-g++" AR="${XTOOLCHAIN}-ar" RANLIB="${XTOOLCHAIN}-ranlib"
}

# Now handle the arguments
handle_args $*
