#!/bin/bash

# Update the container. Sleeps are added just in case bringing network up is slow. 
# Adjust to your needs. 
lxc start my-test-container
lxc exec my-test-container -- su --login -lc "(sleep 10 && cd ~/lxd-bin && git pull)"
lxc exec my-test-container -- su --login -lc "(cd ~/ionen-dev-scripts && git pull)"
lxc exec my-test-container -- su --login -lc "emerge --sync"
lxc exec my-test-container -- su --login -lc "(emerge -uvDN --binpkg-changed-deps=y --keep-going world && emerge --depclean --with-bdeps=n)"
lxc exec my-test-container -- su --login -lc "eclean-kernel -n 1"
lxc exec my-test-container -- su --login -lc "(eselect news read && etc-update)"
lxc exec my-test-container -- su --login -lc "pfl"
lxc exec my-test-container -- su --login -lc "eclean packages --changed-deps"
lxc stop my-test-container

# Delete all old snapshots. Note that this will NOT delete active containers!
lxc list | awk '{print $2}' | grep my-test-container-snap | xargs -I SNAP lxc delete SNAP

# For problems with inittab, use
#lxc exec my-test-container -- poweroff

echo "All done."
echo
