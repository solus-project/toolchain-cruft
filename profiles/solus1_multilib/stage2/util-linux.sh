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
PKG_NAME="util-linux"
PKG_URL="https://www.kernel.org/pub/linux/utils/util-linux/v2.26/util-linux-2.26.tar.xz"
PKG_HASH="a23c6f39dea0ed215ccd589509ffc7bb6f706f6e1a04760f493fb0fd7e93c489"

source "${FUNCTIONSFILE}"

CONFIGURE_OPTIONS+="--disable-makeinstall-chown \
                    --without-systemdsystemunitdir \
                    --without-systemd \
                    --disable-bash-completion \
                    --without-python \
                     PKG_CONFIG=\"\""

# Now handle the arguments
handle_args $*
