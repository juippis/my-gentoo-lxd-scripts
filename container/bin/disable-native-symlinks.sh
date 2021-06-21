#!/bin/bash

# Quick and dirty way for disabling native-symlinks. Intended to be used with 
# discardable containers, ie, does not "toggle" the state of native-symlinks.

mkdir -p /etc/portage/profile/
{
	echo "dev-lang/python-exec -native-symlinks"
	echo "sys-devel/binutils-config -native-symlinks"
	echo "sys-devel/gcc-config -native-symlinks"
} > /etc/portage/profile/package.use.force

if [[ -d /etc/portage/package.use ]]; then
	{
		echo "dev-lang/python-exec -native-symlinks"
		echo "sys-devel/binutils-config -native-symlinks"
		echo "sys-devel/gcc-config -native-symlinks"
	} > /etc/portage/package.use/native-symlinks

else
	{
	echo "dev-lang/python-exec -native-symlinks"
	echo "sys-devel/binutils-config -native-symlinks"
	echo "sys-devel/gcc-config -native-symlinks"
	} >> /etc/portage/package.use
fi

emerge -1av --usepkg=n dev-lang/python-exec sys-devel/binutils-config sys-devel/gcc-config
