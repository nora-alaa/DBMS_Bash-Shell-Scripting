#!/bin/bash
export LC_COLLATE=C
shopt -s extglob
connectToDb=""
returnFromFun=""
#________________________Table Menu____________________________



function TableMenu {
echo "Please Select From Tabel Menu :)"
PS3='You Select ==>'

options=("CreateTable"
            "List Tables"
       "Drop Table"
               "Insert Into Table"
           "Select From Table"
               "Delete From Table"
           "Exit")
select opt in "${options[@]}"
do
case $REPLY in
                1) createTable ;;
                2) listTables ;;
                3) dropTable ;;
                4) insertIntoTable ;;
                5) selectFromTable ;;
                6) deleteFromTable ;;
                7) startDBMS ;;
           *) echo invalid option $REPLY;;


esac
done
}
#________________________list Tables___________________________
function listTables{
  read -p "Please Enter DataBase Name: "  nameDatabase

                if [[ $nameDatabase]; then
                        echo "There are all tables ==> "
                        ls ;
                else
                        echo "There is no DataBase with this Name :( "
                        exit;
                fi
        TableMenu
}


#________________________start DBMS____________________________

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
	TableMenu 
}

#________________________drop database____________________________

function dropDatabase
{
	listDatabaseToSelect
        nameDbToDrop=$returnFromFun
	rm -rf ./DBs/${nameDbToDrop}
        echo drop database $nameDbToDrop successfully 
}

#________________________drop Table___________________________

function dropTable ()
{       read -p "Please Enter a DataBase name you want to delete it’s table: " nameDatabase
        if [ -d ./DBs/$nameDatabase ]
            then
                echo database $nameDatabase already exists
                read -p "Please Enter a table name: " NameTable
        if [[ -f $NameTable ]]; 
            then
                 echo "Are you Sure You Want to drop This Table? Yy/Nn"
                 read choice;
                     case $Ans in
                           [Yy]*)  rm -r $NameTable
                                   rm -r $NameTable.type
                           echo "This $NameTable dropped successfully  "  ;;

                            [Nn]*) echo "Delete is Canceled"  ;;
                               * )  echo invalid Answer $Ans ;;
                      esac
         else
                 echo "The $NameTable Table is Not Found! :("
   
      fi

}





