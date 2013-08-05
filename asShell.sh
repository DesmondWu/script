#!/bin/bash
#
# asShell.sh
# this is a simple script to do asustor nas ecd setting
#
# Copyright (C) 2013 Desmond Wu <wkunhui@gmail.com>
#

IP_ADDR=$1
ACCUNT=$2
PASSWORD=$3
SID=""
as_usage()
{
	echo "usage:"
	echo "	$0 ipaddr username password "
}
as_login()
{
	local strBuf=""
	strBuf="$(wget -qO - --post-data="account=$ACCUNT&password=$PASSWORD" "http://$IP_ADDR:8000/portal/apis/login.cgi?act=login")"
		
	#login failed ?
	[ ! -z "$(echo -e $strBuf | grep true )" ] || return 1
	
	SID="$(echo -e $strBuf | sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep sid | awk '{print $2}' | tr -d '"' )"
	
	#SID is null?
	[ ! -z "$(echo -e $SID )" ] || return 1
	
	return 0
}

as_logout()
{
	local strBuf=""
	strBuf="$(wget -qO -  --post-data="account=$ACCUNT&password=$PASSWORD" "http://$IP_ADDR:8000/portal/apis/login.cgi?act=logout&sid=$SID")"
	
	#logout failed ?
	[ ! -z "$(echo -e $strBuf | grep true )" ] || return 1
	
	return 0
}
as_disklist()
{
	[ ! -z "$(echo -e $SID )" ] || return 1
	wget -qO - "http://$IP_ADDR:8000/portal/apis/storageManager/disk_smart.cgi?sid=$SID&act=list&property=did&direction=ASC"
}

main()
{
	#input null?
	[ ! -z "$IP_ADDR" -a ! -z "$ACCUNT" -a  ! -z "$PASSWORD" ] || as_usage
	
	as_login
	if [ $? == "1" ] ; then 
		echo "login failed"
		exit 1
	fi
	
	while [ 1 ]
	do
		read -n1 cmd ;
		
		printf "\b \b"
		case $cmd in
		d) as_disklist ;;
		q) break;;
		esac		
	done

	as_logout
	[ $? == "0" ] || echo "logout failed"

}

main
