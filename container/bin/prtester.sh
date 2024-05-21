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

# git rev-list --quiet doesn't seem to work as intended (v2.44.1)
if [[ -z "$(git rev-list origin/HEAD..HEAD)" ]]; then
	echo "Couldn't find new commits to test. Exiting..."
	exit
fi

pkgstobetested=(
	$(git show --name-only --diff-filter=AMR --format=tformat: \
	origin/HEAD..HEAD | sort -u | grep ebuild)
)

# Let's print what we're about to test.
echo "Ebuilds to be tested:"
printf "%s\n" "${pkgstobetested[@]}"
echo ""

commit="$(git rev-parse --short=8 HEAD)"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' \
	--extra-env-file 'test.conf' \
	--test-feature-scope once --max-use-combinations 6 \
	--report /var/tmp/portage/vbslogs/"${commit}".json \
	"${pkgstobetested[@]/#/-f }"

echo "Error reports for failed atoms, use errors_and_qa_notices.sh to find out exact errors:"
# Print previous line after a pattern match using sed: https://unix.stackexchange.com/a/206887
grep -e atom -e exit_code /var/tmp/portage/vbslogs/"${commit}".json | \
	sed -n '/exit_code": 1/{x;p;d;}; x' | uniq | \
	awk -F ": " '{print $2}'
