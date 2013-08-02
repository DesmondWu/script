#!/bin/bash
#
# depSearch.sh
# this is a simple script to show all dependcies of packge on apt source
#
# Copyright (C) 2013 Desmond Wu <wkunhui@gmail.com>
#
record_chk()
{
	local idx=$1
	local value=$2
	local mem_tmp=$3
	local tmp=""
	tmp=$(echo -e "$memtmp" | head -n $idx | tail -n 1 | awk '{print $2}' )
	echo "$idx $tmp $value last $(echo -e "$mem_tmp" | head -n $idx  | tail -n 1 | awk '{print $5" " $3}' | tr -d 'K') "| awk '{if( $3 > ($5+10)) print $1 " " $6}'
}

main()
{
	local idx=""
	local PID=""
	local memtmp=""
	memtmp="$(ps | grep -v PID | awk '{print NR" "$1" "$4" "}' | grep -v ps | grep -v awk | awk '{printf NR" "$2" "$3" "}{system("pmap "$2" | grep mapped")}')"
	echo "start search memory leak app"
	for idx in `echo -e "$memtmp" | awk '{print $1}'`
	do
		PID=$(echo -e "$memtmp" | head -n $idx | tail -n 1 | awk '{print $2}' )
		value=$(pmap $PID | grep mapped | awk '{print $2}' | tr -d 'K')
		[ -z "$value" ] || [  "$value" -eq "0" ] || record_chk "$idx" "$value" "$memtmp" 
	done
	echo "search end"
}


main
