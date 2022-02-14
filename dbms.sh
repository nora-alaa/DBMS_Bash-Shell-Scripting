#!/bin/bash
export LC_COLLATE=C
shopt -s extglob
connectToDb=""
returnFromFun=""
PS3="You Select => "

#________________________insert new column____________________________

function insertNewCol
{
	read -p "please insert name of new column: " nameCol

        if [[ $infoNewTable[0] == *"$nameCol"* ]]; then
 		 echo This column $nameCol  already exsits
		 helperNewCol
	fi  
	infoNewTable[0]+=$nameCol","

	echo "--------- select data type for column $nameCol : ---------"
	options=("int" "text")
	select opt in "${options[@]}"
	do	
		case $REPLY in
			1) infoNewTable[1]+="int," 
				echo colname ${infoNewTable[0]}
				echo datatype ${infoNewTable[1]}
				helperNewCol
				;;
        		2) infoNewTable[1]+="text," 
				echo colname ${infoNewTable[0]}
				echo datatype ${infoNewTable[1]}
				helperNewCol
				;;
			*) echo invalid option $REPLY;;
		esac
	done
}

#________________________helper new column____________________________

function finishAddTable
{
        touch ./DBs/$connectToDb/$nameTable.table

        echo $nameTable >> ./DBs/$connectToDb/$nameTable.metaData
       	echo "${infoNewTable[0]%?}" | awk -F',' '{ print NF }' >> ./DBs/$connectToDb/$nameTable.metaData
        echo "${infoNewTable[0]%?}" >> ./DBs/$connectToDb/$nameTable.metaData
        echo "${infoNewTable[1]%?}" >> ./DBs/$connectToDb/$nameTable.metaData
       
	infoNewTable[0]=""
        infoNewTable[1]=""
	TableMenu 
}

function helperNewCol
{
	echo '--------- Please Select :) ---------'     
        options=("Insert new column" "Finish" "Exit")
        select opt in "${options[@]}"
         do
         	case $REPLY in
			1) insertNewCol ;;
               		2) finishAddTable
				 ;;
               		3) infoNewTable[0]=""
        			infoNewTable[1]="" 
				TableMenu ;;
               		*) echo invalid option $REPLY;;
        	 esac
          done
}

#________________________create Table____________________________

function createTable
{
	read -p "please insert name of table: " nameTable
	if [ -f ./DBs/$connectToDb/$nameTable.table ] 
	then
		echo table $nameTable is exist

	elif [ -d ./DBs/$nameTable ]
	then 
		echo invalid, there is folder has same name

	elif [[ $nameTable == *"/"* ]]
	then 
		echo invalid "$nameTable" table name 
	else
		helperNewCol
	fi			
}
#________________________Select From Table____________________________

function SelectFromTable(){
        read -p "Please Enter Table Name  : "NameTable
        
        if [[ -f $ NameTable ]] ;
          then
           PS3="You Select => "
           select choice in "Select  Al l Records" "Select One Record"  "Select Column" "Exit"
             do
               case $choice in
                    "Select AllRecords" )column -t -s ':' $tbName.type
                                         column -t -s ':' $NameTable ;;
                                   
                    "Select Record" ) colname=`awk -F ":" '{if(NR==1) print $1}' $NameTable`;
                      read -p "Enter your $colname: " value
                          if [[ -z $value ]] ;
                           then
                              echo "Empty Input"
                                    
                            
                           else if [[ $value =~ [`cut -d':' -f1 $NameTable | grep -x $value`] ]]; then
            
                   recordNum=$(awk 'BEGIN{FS=":"}{if ( $1 == "'$value'" ) print NR}' $NameTable)
                   echo $(awk 'BEGIN{FS=":";}{if ( NR == '$recordNum' ) print $0 }' $NameTable)
                                       
                            
                       fi
                       fi;;
                       
                   "Select Column" )
                            read -p "PLease Enter Column Number : " value
                            while ! [[ $value =~ ^[1-9]+$ ]]
                                 do
                           
                                read -p "Column Number Must be Integer : " value
                             
                                done
                                     cut -d':' -f$value $NameTable.type
                                     cut -d':' -f$value $NameTable     ;;
                                    

                   "TableMenu " )TableMenu ;;
                                *)echo "Please, Enter valid Number"
                                      
                                  echo "select again :" ;;     
                                        
                        esac
                 done
        SelectFromTable
        else
        echo $NameTable Not Found ;

        fi

}

#________________________list Tables___________________________

function listTables
{


	if [[ `ls -l ./DBs/$connectToDb | grep '.table' | wc -l` == 0 ]]
	then 
		echo No tables found	
	else
        	echo '--------- Tables are: ---------'

		ls -l ./DBs/$connectToDb | grep '.table' | awk '{print NR"-", $9}'
	fi
        TableMenu
}

#________________________insert into Tables___________________________


#________________________Table Menu____________________________

function TableMenu 
{
	echo '--------- Please Select From Tabel Menu :) ---------'	
	options=("Create Table" "List Tables" "Drop Table" "Insert Into Table"  "Select From Table"  "Delete From Table"  "Back to start")
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

	echo '--------- name of databases ---------' 
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

<<<<<<< HEAD
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
=======
#________________________start DBMS____________________________

function startDBMS
{
echo '--------- start DBMS ---------'
options=("CREATE Database" "LIST ALL Database" "CONNECT TO Database" "DROP database" "EXIT")
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








