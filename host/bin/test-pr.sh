#!/bin/bash

# Test a https://github.com/gentoo/gentoo number, for example:
# Input: test-pr.sh 12345
# Would test https://github.com/gentoo/gentoo/pull/12345

id="${1}"

echo "Initializing new test environment... this will take a while."
lxc copy my-test-container my-test-container-snap-"${1}"
lxc start my-test-container-snap-"${1}"
lxc exec my-test-container-snap-"${1}" -- su --login -lc "(sleep 10 && cd /var/db/repos/gentoo && curl -s -L https://patch-diff.githubusercontent.com/raw/gentoo/gentoo/pull/${1}.patch | git -c user.email=my@email -c user.name=MyName am --keep-cr -3)"
lxc exec my-test-container-snap-"${1}" -- su --login -lc "(sleep 10 && ~/bin/prtester.sh)"
lxc exec my-test-container-snap-"${1}" -- su --login -lc "(sleep 10 && pfl &>/dev/null)"
lxc exec my-test-container-snap-"${1}" -- su --login -lc "(~/bin/errors_and_qa_notices.sh)"
lxc exec my-test-container-snap-"${1}" -- bash
lxc stop my-test-container-snap-"${1}"

