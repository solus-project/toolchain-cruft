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
PKG_NAME="make"
PKG_URL="http://ftp.gnu.org/gnu/make/make-4.1.tar.gz"
PKG_HASH="9fc7a9783d3d2ea002aa1348f851875a2636116c433677453cc1d1acc3fc4d55"

source "${FUNCTIONSFILE}"

CONFIGURE_OPTIONS+="--without-guile"

pkg_setup()
{
    set -e
    pkg_extract

    pushd "$(pkg_source_dir)" >/dev/null
    patch -p1 < "${PATCHESDIR}/make/bug43434.patch"
    popd >/dev/null

    pkg_configure
}

# Now handle the arguments
handle_args $*
