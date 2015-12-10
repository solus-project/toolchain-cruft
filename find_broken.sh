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

# Find binaries not built for /usr/lib64 (i.e /lib64/ld-linux-x86-64.so.2)
check_borked()
{
    output="$(readelf -a ${1} 2>/dev/null| grep interpreter)"

    if [[ "${output}" != *"[Requesting program interpreter"* ]]; then
        continue
    fi

    if [[ "${output}" == *"/usr/lib64"* ]]; then
        continue
    fi
    echo "Needs rebuild: ${i}"
}

for i in /usr/bin/* ; do
    if [[ -x $i && -f $i ]]; then
        check_borked $i
    fi
done

for i in /bin/* ; do
    if [[ -x $i && -f $i ]]; then
        check_borked $i
    fi
done
