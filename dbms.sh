#!/bin/bash
export LC_COLLATE=C
shopt -s extglob
connectToDb=""
returnFromFun=""

#_______________________create database________________________

function createDatabase
{
        read -p "please enter name of data base " nameDatabase
	if [ -d ./DBs/$nameDatabase ]
	then 
		echo database $nameDatabase already exists
	elif [[ $nameDatabase == *"/"* ]]
	then 
		echo invalid database name
	elif [ -f ./DBs/$nameDatabase ]
	then 
		echo invalid, there is file has same name
	else
		mkdir -p ./DBs/$nameDatabase
		echo done create database $nameDatabase
	fi
}


#_______________________list database________________________

function listDatabase
{ 
	if [[ `ls -l ./DBs | grep '^d' | wc -l` == 0 ]]
	then 
		echo No database found	
	else
		echo "Database are: "
		ls -l ./DBs | grep '^d' | awk '{print NR"-", $9}'
	fi
}


#_______________________list database to select________________________

function listDatabaseToSelect
{
        whichDB=( $(ls -d ./DBs/* | cut -d"/" -f3 ) "Back to start" )
        numberOfDB=${#whichDB[@]}


        select opt in "${whichDB[@]}"
        do
                if [ "$REPLY" -lt  "$numberOfDB" -a "$REPLY" -gt 0 ]
                then
                        (( index = $REPLY -1 ))
			returnFromFun=${whichDB[$index]}
                        return 1

                elif [[ $REPLY == $numberOfDB  ]]
                then
                        startDBMS
                else
                        echo invalid option $REPLY
                fi
        done
}

#_______________________connect to database________________________

function connectToDatabase
{

	listDatabaseToSelect
	connectToDb=$returnFromFun
	echo go to DB $connectToDb
	########## func to list menu table
}

#________________________drop database____________________________

function dropDatabase
{
	listDatabaseToSelect
        nameDbToDrop=$returnFromFun
	rm -rf ./DBs/${nameDbToDrop}
        echo drop database $nameDbToDrop successfully 
}

#________________________creat database____________________________

function startDBMS
{
PS3='Please select option: '
options=("1- CREATE Database" "2- LIST ALL Database" "3- CONNECT TO Database" "4- DROP database" "5- EXIT")
select opt in "${options[@]}"
do
	case $REPLY in 
		1) createDatabase
			;;
		2) listDatabase
			;;
		3) connectToDatabase
			;;
		4) dropDatabase
			;;
		5) exit
		       	;;
		*) echo invalid option $REPLY;;
	esac
done
}

startDBMS

