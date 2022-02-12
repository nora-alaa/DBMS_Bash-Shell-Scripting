#!/bin/bash
PS3='Please select option: '
options=("1- CREATE Database" "2- LIST ALL Database" "3- CONNECT TO Database" "4- DROP database" "5- EXIT")
select opt in "${options[@]}"
do
	case $REPLY in 
		1) echo create database
			;;
		2) echo list all databas
			;;
		3) echo connect to database
			;;
		4) echo drop database
			;;
		5) exit
		       	;;
		*) echo invalid option $REPLY;;
	esac
done

