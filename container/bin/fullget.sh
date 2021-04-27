#!/bin/bash

# Just a simple PR patch merger. It's much more wise to set up your git config with (any) 
# user.email and user.name, but this in general should work without setup everywhere.

cd /var/db/repos/gentoo || exit

curl -s -L https://patch-diff.githubusercontent.com/raw/gentoo/gentoo/pull/${1}.patch | git -c user.email=my@email -c user.name=MyName am --keep-cr -3
