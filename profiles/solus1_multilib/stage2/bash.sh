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
PKG_NAME="bash"
PKG_URL="https://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz"
PKG_HASH="317881019bbf2262fb814b7dd8e40632d13c3608d2f237800a8828fbb8a640dd"

source "${FUNCTIONSFILE}"

pkg_setup()
{
    set -e
    pkg_extract

    pushd $(pkg_source_dir) >/dev/null

    # need all these sadly. CVEs n whatnot.
    PATCH_START=031
    PATCH_END=042
    for i in $(seq -f "%03g" $PATCH_START $PATCH_END)
    do
        zcat "${PATCHESDIR}/bash/bash43-$i.gz" | patch -p0
    done

    pkg_configure

    popd >/dev/null
}

pkg_install()
{
    pkg_make install

    ln -sv bash /tools/bin/sh
}

# Now handle the arguments
handle_args $*
