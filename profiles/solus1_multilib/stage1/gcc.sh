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

CONFIGURE_OPTIONS+="--target=${XTOOLCHAIN} \
                    --enable-languages=c,c++ \
                    --with-arch32=i686 \
                    --with-newlib \
                    --with-sysroot=\"${PKG_INSTALL_DIR}\" \
                    --with-native-system-header-dir=\"${PKG_INSTALL_DIR}/usr/include\" \
                    --with-local-prefix=\"${PKG_INSTALL_DIR}/\" \
                    --without-headers \
                    --disable-nls \
                    --disable-shared \
                    --disable-decimal-float \
                    --disable-threads \
                    --disable-libatomic \
                    --disable-libgomp \
                    --disable-libitm \
                    --disable-libquadmath \
                    --disable-libsanitizer \
                    --disable-libssp \
                    --disable-libvtv \
                    --disable-libcilkrts \
                    --with-multilib-list=m32,m64 \
                    --disable-libstdc++-v3"
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
    for i in $(cat ${PATCHESDIR}/gcc/series); do
        patch -p1 < "${PATCHESDIR}/gcc/${i}" || do_fatal "Could not patch GCC"
    done

    popd >/dev/null

    # Now go back to the main configure routine
    pkg_configure
}

pkg_install()
{
    make_install DESTDIR="${PKG_INSTALL_DIR}"
    if [[ ! -d "${PKG_INSTALL_DIR}/lib" ]]; then
        install -D -d -m 00755 "${PKG_INSTALL_DIR}/lib"
    fi

    ln -sv ../usr/bin/cpp "${PKG_INSTALL_DIR}/lib/cpp"
    ln -svf gcc "${PKG_INSTALL_DIR}/usr/bin/cc"
}

# Now handle the arguments
handle_args $*
