#!/bin/bash

### Gets non-pushed commits from the local git-tree, and tests every modified
### .ebuild. Uses pkg-testing-tool to test them, so it runs a compile test with
###   FEATURES="-test"
### and
###   FEATURES="test"
### and maximum of 6 runs with randomized USE flag combinations, given that the
### package has enough USE flags.
###

cd /var/db/repos/gentoo || exit

# Create an array of commits
mapfile -t newcommits < <(git rev-list origin/HEAD..HEAD)
declare -a pkgstobetestedtmp1
declare -a pkgstobetestedfinalarray

if [[ ${#newcommits[@]} -eq 0 ]]; then
	echo "Couldn't find new commits to test. Exiting..."
	exit
fi

# Please send help with the grepping...
# /^[+-]{3} [a-z]\/([^\/]+)\/[^\/]+\/(.*)\.ebuild/
# | grep -E '\+\+\+' | grep ".ebuild" | cut -d  "/" -f 2,4 | awk -F  '.ebuild' '{print $1}'
# | grep -E '^[+]{3} [a-z]/([^\/]+)/[^\/]+/(.*)\.ebuild$' | sed 's#^[+-]\{3\} [a-z]/ \([^/]\+\)/[^/]\+/\(.*\)\.ebuild#\1/\2#'
for i in "${newcommits[@]}"; do
	pkgstobetestedtmp1+=( $(git show "${i}" | grep -E '^[+]{3} [a-z]/([^\/]+)/[^\/]+/(.*)\.ebuild$' | sed 's#^[+]\{3\} [a-z]/\([^/]\+\)/[^/]\+/\(.*\)\.ebuild#\1/\2#') )
	pkgstobetestedtmp1+=( $(git show "${i}" | grep "rename to" | grep ".ebuild" | cut -d " " -f3 | cut -d  "/" -f 1,3 | awk -F  '.ebuild' '{print $1}') )
done

# Remove any duplicate entries, we only need to test the final ebuild once.
eval pkgstobetestedfinalarray=( $(printf "%q\n" "${pkgstobetestedtmp1[@]}" | uniq) )

# Let's print what we're about to test.
echo "Packages to be tested:"
echo "${pkgstobetestedfinalarray[@]}"
echo ""

# We'll need to go through commit array in reverse order.
for (( j=${#pkgstobetestedfinalarray[@]}-1; j>=0; j-- )); do
	~/bin/pkg-testing-tools/pkg-testing-tool --extra-env-file 'test.conf' \
		--append-required-use '!libressl !profile !systemd' --test-feature-scope once \
		--max-use-combinations 6 --report /var/tmp/portage/vbslogs/"${j}".json \
		-p "=${pkgstobetestedfinalarray[${j}]}"
done

echo "Error reports for failed atoms, use errors_and_qa_notices.sh to find out exact errors:"
grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"
