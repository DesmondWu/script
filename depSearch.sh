#!/bin/bash
#
# depSearch.sh
# this is a simple script to show all dependcies of packge on apt source
#
# Copyright (C) 2013 Desmond Wu <wkunhui@gmail.com>
#

package_name="$1"
name_list=""
usage()
{
	echo "usage:"
	echo "	$0 package_name "
}
name_tag ()
{
	if [ -z "$(echo $name_list | grep -a "$1")" ]; then 	
		name_list=`echo -e " $1 \n$name_list"`
		return 0
	fi
	return 1
}
recus_search()
{
	local name=''
	for name in `apt-cache depends $1 | grep Depends | awk '{print $2}' | tr -d '<'| tr -d '>'`
	do
		name_tag "$name"
		if [ $? == "0" ] ; then
			recus_search "$name"
		fi
	done
}

if [ -z "$1" ]; then
	usage 
	exit 0
fi

recus_search $package_name
echo "$package_name dependence as below list:"
echo "$name_list" | awk '{print NR"."$1}'
