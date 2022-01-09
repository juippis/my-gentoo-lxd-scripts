#!/bin/bash

# Start the container and launch root bash in it
lxc start my-test-container
lxc exec my-test-container bash
lxc stop my-test-container
#lxc exec my-test-container -- poweroff
