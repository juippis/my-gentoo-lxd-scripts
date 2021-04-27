#!/bin/bash

# Start the container and launch root bash in it
lxc start my-test-container
lxc exec my-test-container -- su --login
lxc stop my-test-container
#lxc exec my-test-container -- poweroff
