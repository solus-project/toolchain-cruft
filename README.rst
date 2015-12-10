toolchain-cruft
---------------

Scripts to enable bootstrap of the Solus toolchain and core system.
The need for this scripting arises for two major reasons:

 * We need a multilib toolchain for Solus 1.0
 * Solus 2.0 will need to be rebootstapped with a clean root

TODO:
=====

The first approach was to niavely coaxe native builds on native
roots using the least amount of work for a multilib toolchain.
Whilst technically feasible, it requires working around the
suicidal nature of glibc, in that installing it will remove various
core libraries and cause the install routine to fail..

Instead we'll do a full bootstrap of the rootfs, starting out with
a cross-compiler and then using that temporary system to rebuild a
native rootfs.

 * Enable multiple profiles
 * Implement full 1.0+multilib profile
 * Abstract the architecture details - no point going to all this work if
   it only ever supports a single architecture.

Authors
=======

 - Ikey Doherty <ikey@solus-project.com>

License
========

toolchain-cruft is made available under the terms of the MIT license.
Please see `LICENSE` for details.
