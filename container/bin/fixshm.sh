#!/bin/bash

### Simple snippet to populate required devices in container. Can also be done 
### via your container/lxc.conf, see
### https://ahelpme.com/linux/tmpfs-mount-on-dev-shm-in-lxc-container-or-chroot-environment/
###
### Add 
###   /root/bin/fixshm.sh
### to your /root/.bashrc or /root/.profile to execute this each time you log 
### in to your container.

mkdir -p /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec,mode=1777,size=6144m tmpfs /dev/shm
