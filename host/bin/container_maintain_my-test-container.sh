#!/bin/bash

# Update the container. Sleeps are added just in case bringing network up is slow. 
# Adjust to your needs. 
lxc start my-test-container
lxc exec my-test-container -- su --login -lc "(sleep 10 && emerge --sync)"
lxc exec my-test-container -- su --login -lc "(sleep 10 && emerge -uvDN --with-bdeps=y --binpkg-changed-deps=y --keep-going world && emerge --depclean)"
lxc exec my-test-container -- su --login -lc "(eclean-kernel -n 1)"
lxc exec my-test-container -- su --login -lc "(eselect news read && etc-update)"
lxc exec my-test-container -- su --login -lc "(sleep 10 && cd ~/bin/pkg-testing-tools && git pull)"
lxc exec my-test-container -- su --login -lc "(sleep 10 && pfl)"
lxc exec my-test-container -- su --login -lc "eclean packages --changed-deps"
lxc stop my-test-container

# Delete all old snapshots. Note that this will NOT delete active containers!
lxc list | awk '{print $2}' | grep my-test-container-snap | xargs -I SNAP lxc delete SNAP

# For problems with inittab, use
#lxc exec my-test-container -- poweroff

echo "All done."
echo
