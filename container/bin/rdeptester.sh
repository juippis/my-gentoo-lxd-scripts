#!/bin/bash

### Usage: rdeptester.sh category/package
### Example: rdeptester.sh dev-libs/efl
###
### Matches the parameter to a list in 
###   https://qa-reports.gentoo.org/output/genrdeps/dindex/
###
### By default tests 6 random reverse dependencies, can test ALL 
### (not including-9999 packages) with an -a option.
### 
### Example: rdeptester.sh -a dev-cpp/glibmm
### 
### By default, we disable 'doc', 'examples, and 'gtk-doc' USE flags,
### because we're just interested in compile-test. We also don't run 
### FEATURES="test", or test multiple USE flag combinations.
###
### Uses pkg-testing-tool, https://github.com/slashbeast/pkg-testing-tools
### 

main() {
	local all=0
	local atom=""

	while [[ ${#} -gt 0 ]]; do
		case ${1} in
			-a)
				all=1
				atom="${2}"
				;;
			*)
				atom="${1}"
				;;
		esac
		shift
	done

	local pkgname=""
	pkgname=$(echo "${atom}" | cut -d  "/" -f 2)

	# Do necessary file manipulation.
	if [[ -f /tmp/"${pkgname}"-rdeps.txt ]]; then
		echo "/tmp/""${pkgname}""-rdeps.txt exists."
		echo "Won't overwrite. Please move or remove the file before continuing."
		exit 1
	fi

	wget https://qa-reports.gentoo.org/output/genrdeps/dindex/"${atom}" -O /tmp/"${pkgname}"-rdeps.txt
	sed -e '/9999/d' -e '/[B]/d' -e '/virtual\//d' -i /tmp/"${pkgname}"-rdeps.txt

	mapfile -t allrdepsarray < <(cat /tmp/"${pkgname}"-rdeps.txt)

	if [[ ${all} == 0 ]] && [[ ${#allrdepsarray[@]} -ge 6 ]]; then
		local randomizedarraylength="${#allrdepsarray[@]}"
		mapfile -t randomizearray < <(shuf --input-range=0-"$((randomizedarraylength-1))")
		local shuffledarray=()
		for (( j=0; j<6; j++ )); do
			shuffledarray+=( "${allrdepsarray[${randomizearray[${j}]}]}" )
		done

		for (( k=0; k<6; k++ )); do
			local testingpkgname=""
			local atomname=""
			local uses=""
			local exportlist=""

			atomname=$(echo "${shuffledarray[${k}]}" | awk -F  ":" '{print $1}')
			uses=$(echo "${shuffledarray[${k}]}" | awk -F  ":" '{print $2}')
			testingpkgname=$(echo "${atomname}" | cut -d  "/" -f 2)

			if [[ -n ${uses} ]]; then
				exportlist=$(echo "${uses}" | sed 's/+/ /g' | sed 's/!\w\+//g')
			fi

			export USE="${exportlist}"
			pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never
				--append-required-use '!doc !examples !gtk-doc ' --max-use-combinations 1 \
				--report /var/tmp/portage/vbslogs/"${testingpkgname}-${k}.json" \
				-p "=${atomname}"
			unset USE
		done
	
	else
		for (( l=0; l<${#allrdepsarray[@]}; l++)); do
			local testingpkgname=""
			local atomname=""
			local uses=""
			local exportlist=""

			atomname=$(echo "${allrdepsarray[${l}]}" | awk -F  ":" '{print $1}')
			uses=$(echo "${allrdepsarray[${l}]}" | awk -F  ":" '{print $2}')
			testingpkgname=$(echo "${atomname}" | cut -d  "/" -f 2)

			if [[ -n ${uses} ]]; then
				exportlist=$(echo "${uses}" | sed 's/+/ /g' | sed 's/!\w\+//g')
			fi

			export USE="${exportlist}"
			pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
				--append-required-use '!doc !examples !gtk-doc' --max-use-combinations 1 \
				--report /var/tmp/portage/vbslogs/"${testingpkgname}-${l}.json" \
				-p "=${atomname}"
			unset USE
		done
	fi

	echo "Error reports for failed atoms:"
	grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"

	# Finally clean the tmp file.
	rm /tmp/"${pkgname}"-rdeps.txt
		
}

main "${@}"
