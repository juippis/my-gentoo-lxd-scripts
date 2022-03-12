#!/bin/bash

# prtester.sh: Find all build errors fast, find all QA notices after emerge for the 
# atom we just tested.
#
# rdeptester.sh: With pkg-testing-tool --report, and with a custom "test.conf", 
# find out exact errors easier.
#

if [[ -d "/var/tmp/portage/vbslogs/build/" ]]; then
	echo "Grepping through the logs for any errors or QA notices..."
	grep -r "QA Notice:" /var/tmp/portage/vbslogs/build/
	grep -r "ERROR:" /var/tmp/portage/vbslogs/build/ | grep "failed"
	grep -r "* Failed to" /var/tmp/portage/vbslogs/build/
	grep -r "installing to one or more unexpected paths" /var/tmp/portage/vbslogs/build/
	grep -r "Permission denied" /var/tmp/portage/vbslogs/build/
	grep -r "command not found" /var/tmp/portage/vbslogs/build/
	grep -r "WARNING: Unknown options:" /var/tmp/portage/vbslogs/build/
	grep -r "QA:" /var/tmp/portage/vbslogs/build/
	grep -r "fatal:" /var/tmp/portage/vbslogs/build/
	echo "Finished grepping."

else
	echo "No desired atoms were tested apparently? Exiting..."

fi
