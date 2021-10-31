# My Gentoo LXD scripts

This repo collects the scripts and configs required to run ["ultimate lxd testing environment"](https://wiki.gentoo.org/wiki/User:Juippis/The_ultimate_testing_system_with_lxd). 


## Repository structure:

* container/bin

   Scripts to be executed inside the container.

* container/etc/portage

   All relevant /etc/portage files.

* host/bin

   Necessary scripts required to run from the host machine, in other words, outside the container.

* pkg-testing-tool-patches

   Easy to access patches for different needs, e.g. general PR testing, stabilization work...


## Links
* https://wiki.gentoo.org/wiki/User:Juippis/The_ultimate_testing_system_with_lxd
* https://wiki.gentoo.org/wiki/LXD
* https://linuxcontainers.org/lxd/getting-started-cli/
* https://packages.gentoo.org/packages/app-emulation/lxd


## TODO

Nothing too ambitious. As long as it works...

 * General container:
 
 	* I run often into multiple different build issues with packages in ::gentoo. A general bug reporting tool to automate bug reports would be nice.

 * container/bin/rdeptester.sh
 
	* Getting a list of only stable-rdeps, for better arch testing work. Eix can do this and should be utilized...
 
 	* Rdep list with "+" and "!" USE flags need to be taken into account better.

 * host/bin/test-pr.sh
 
	* Parameters for different kinds of testing, e.g.,
 	
 		* **-1** for a single test run. Useful if there's a simple `src_install` fix for example, no need to test multiple USE flag combinations.
 	
		* **-i** for "interactive mode" where shell is spawn before any testing. Allows to add missing `|| die`s, bump `EAPI`, add `PYTHON_COMPAT` etc minor issues spotted while reviewing before testing.
 		
		* **-n** for `-native-symlinks` run, since some PRs are made just for that.

