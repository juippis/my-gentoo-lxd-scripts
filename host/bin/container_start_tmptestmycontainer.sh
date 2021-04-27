#!/bin/bash

# Just a skeleton file to launch a "basic test environment". This will be 
# deleted normally by container_maintain_my-test-container.sh, unless this 
# container is powered on with lxc start.

echo "Initializing new test environment... this will take a while."
lxc copy my-test-container my-test-container-snap-tmp

lxc start my-test-container-snap-tmp
lxc exec my-test-container-snap-tmp -- bash

echo "Uploading pfl data..." 

lxc exec my-test-container-snap-tmp -- su --login -lc "(sleep 10 && pfl &>/dev/null)"
lxc stop my-test-container-snap-tmp
