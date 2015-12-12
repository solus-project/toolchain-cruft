toolchain-cruft
---------------

Scripts to enable bootstrap of the Solus toolchain and core system.
The need for this scripting arises for two major reasons:

 * We need a multilib toolchain for Solus 1.0
 * Solus 2.0 will need to be rebootstapped with a clean root

TODO:
=====

 - [x] Create profile based system
 - [x] Add task tracking (`$PKGNAME.status`)
 - [x] Set up a stage1 cross-compiler
 - [x] Create a stage2 /tools/ style rootfs
 - [ ] Prefetch all downloads, avoid wget in chroot system
 - [ ] Create a stage3 chroot base "final" builder
 - [ ] Have stage3 back up (DESTDIR,install_root) trees

Authors
=======

 - Ikey Doherty <ikey@solus-project.com>

License
========

toolchain-cruft is made available under the terms of the MIT license.
Please see `LICENSE` for details.
