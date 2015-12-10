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
PKG_NAME="linux-headers"
PKG_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.1.14.tar.gz"
PKG_HASH="56293a972a9c251bc8a03709fe6eafb5ca1dab9a072f44dc767d2f3984d8ad41"

source "${FUNCTIONSFILE}"

pkg_build()
{
    local sourcedir=`pkg_source_dir`
    pushd "${sourcedir}" >/dev/null
    make mrproper
}

pkg_setup()
{
    pkg_extract
}

pkg_install()
{
    local sourcedir=`pkg_source_dir`
    pushd "${sourcedir}" >/dev/null
    make headers_install INSTALL_HDR_PATH=./leheaders
    if [[ ! -d /tools/include ]]; then
        install -d -D -m 00755 /tools/include
    fi

    cp -Rv leheaders/include/* /tools/include/.
}

# Now handle the arguments
handle_args $*
