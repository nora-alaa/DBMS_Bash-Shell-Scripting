#!/bin/bash
export LC_COLLATE=C
shopt -s extglob
connectToDb=""
returnFromFun=""
PS3="You Select => "

function printInto
{
	echo
	echo "       *" $1 "*               "               
	echo
}


#________________________insert new column____________________________

function insertNewCol
{
	read -p "please insert name of new column: " nameCol

        if [[ $infoNewTable[0] == *"$nameCol"* ]]; then
 		 printInto This column $nameCol  already exsits
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
	printInto '--------- Please Select :) ---------'     
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
		printInto "table $nameTable is exist"

	elif [ -d ./DBs/$nameTable ]
	then 
		printInto "invalid, there is folder has same name"

	elif [[ $nameTable == *"/"* ]]
	then 
		echo "invalid "$nameTable" table name" 
	else
		helperNewCol
	fi			
}

#________________________Select From Table____________________________

function selectFromTable
{
        read -p "Please Enter Table Name  : " NameTable
        
        if [[ -f ./DBs/$connectToDb/$NameTable.table ]] ;
        then   
PS3=$PS3"From Menu select6: "
        	select choice in "Select All Records" "Select by certain condition"  "Select Column" "Exit"
             	do
               		case $REPLY in
                    		1) head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | column -t -s ',' 
                                	column -t -s ',' ./DBs/$connectToDb/$NameTable.table ;;
                                   
                    		2) colname=`awk -F "," '{if(NR==3) print $0}' ./DBs/$connectToDb/$NameTable.metaData`;
                      			read -p "Enter your $colname: " value
                          		if [[ -z $value ]]
                           		then
                              			printInto "Empty Input"                
                           		else

                                                 if [[ `head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\n" | grep $value | wc -l` == 1 ]] 
					         then
                                              x=`head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\n" | grep -n $value | cut -d: -f1`	
							read -p "Enter value for $value: " valueSearch
							head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\t"
							awk -F, -v val=$valueSearch '{ if( $'$x' == val ) print $0 }' ./DBs/$connectToDb/$NameTable.table | tr "," "\t"


						
						 else
							printInto "this column doesn't exsit" 								 
						 fi
                       			fi
					;;
                       
                   		3) read -p "PLease Enter Column Number : " value
                            		while ! [[ $value =~ ^[1-9]+$ ]]
                                 	do
                                		read -p "Column Number Must be Integer : " value
                             
                                	done
                                        head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | cut -d',' -f$value
                                        cut -d',' -f$value ./DBs/$connectToDb/$NameTable.table     ;;
                                    

                   		4)TableMenu ;;
                                *)printInto "Please, Enter valid Number"  echo "select again :" ;;     
                                        
                        esac
                 done
        selectFromTable
        else
        printInto $NameTable Not Found ;
        fi

}




#________________________delete From Table____________________________

function deleteFromTable
{
        read -p "Please Enter Table Name  : " NameTable
        
        if [[ -f ./DBs/$connectToDb/$NameTable.table ]] ;
        then   
			PS3=$PS3"From Menu delete: "
        	select choice in "delete All Records" "delete by certain condition" "Exit"
             	do
               		case $REPLY in
                    		1)  echo "" > ./DBs/$connectToDb/$NameTable.table; 
                                         printInto "All rows Deleted Successfully"					
					 ;;
                                   
                    		2) colname=`awk -F "," '{if(NR==3) print $0}' ./DBs/$connectToDb/$NameTable.metaData`;
                      			read -p "Enter your $colname: " value
                          		if [[ -z $value ]]
                           		then
                              			printInto "Empty Input"                
                           		else

                                                 if [[ `head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\n" | grep $value | wc -l` == 1 ]] 
					         then
                                                        x=`head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\n" | grep -n $value | cut -d: -f1`	
							read -p "Enter value for $value to delete: " valueSearch
							head -3 ./DBs/$connectToDb/$NameTable.metaData | tail -1 | tr "," "\t"
							awk -F, -v val=$valueSearch '{ if( $'$x' != val ) print $0 }' ./DBs/$connectToDb/$NameTable.table > tmpfile && mv tmpfile ./DBs/$connectToDb/$NameTable.table

                                                        printInto "Rows Deleted Successfully"

						
						 else
							printInto "this column doesn't exsit" 								 
						 fi
                       			fi
					;;

                   		3)TableMenu ;;
                                *)echo "Please, Enter valid Number"  echo "select again :" ;;     
                                        
                        esac
                 done
        selectFromTable
        else
        printInto "$NameTable Not Found" ;
        fi

}






#________________________list Tables___________________________

function listTables
{

	if [[ `ls -l ./DBs/$connectToDb | grep '.table' | wc -l` == 0 ]]
	then 
		printInto "No tables found"	
	else
        	printInto '--------- Tables are: ---------'

		ls -l ./DBs/$connectToDb | grep '.table' | awk '{print NR"-", $9}'
	fi
	read -n1
        TableMenu
}

#________________________drop Table___________________________

function dropTable
{       
        read -p "Please Enter a table name: " NameTable

        if [[ -f ./DBs/$connectToDb/$NameTable.table ]] 
        then
                 echo "Are you Sure You Want to drop This Table? Yy/Nn"
                 read choice
                     case $choice in
                           [Yy]*)  rm -r ./DBs/$connectToDb/$NameTable.table
                                   rm -r ./DBs/$connectToDb/$NameTable.metaData
                           	   printInto "This $NameTable dropped successfully  "  ;;

                            [Nn]*) printInto "Delete is Canceled"  ;;
                               *)  echo invalid Answer $Ans ;;
                      esac
         else
                 printInto "The $NameTable Table is Not Found! :("
   
      fi

}


#________________________insert into Tables___________________________

checkTypeReturn='false'
type='int'

function checkType
{
	case $1 in
	+([0-9])) type='int' 
		;;
	+([a-zA-Z0-9])) type='text' 
		;;
	esac


	if [[ $2 == $type ]]
	then
		checkTypeReturn='true'
	else
		checkTypeReturn='false'
	fi
}

function checkTypeOfCol
{
	found='false'
	values=$1
	onlyVals=(   $(echo ${values:7:-1} | tr ',' "\n") )
	typeVals=( $( tail -1 ./DBs/$connectToDb/${commandInsertArr[2]}.metaData | tr "," "\n" ) )

	#found=`awk -F, '{ if($1 == '${onlyVals[0]}') print $1 }' ./DBs/$connectToDb/${commandInsertArr[2]}.table`
	found=`awk -F, -v val=${onlyVals[0]} '{ if( $1 == val ) print $1 }' ./DBs/$connectToDb/${commandInsertArr[2]}.table` 

	if [[ $found != "" ]]
	then
		printInto "pk must be unquie"
		return 0
	fi
	
	if [[ onlyVals == "" || ${#onlyVals[@]} != ${#typeVals[@]} ]]
	then 
		printInto "please insert all column data"
		return 0

	else
		for c in ${!onlyVals[@]}
		do
			checkType ${onlyVals[c]} ${typeVals[c]}
			if [[ $checkTypeReturn == 'false' ]]
			then 
				printInto "${onlyVals[c]} wrong data type, it is not ${typeVals[c]}"
				return 0
			fi
		done	
	fi

	echo ${values:7:-1} >> ./DBs/$connectToDb/${commandInsertArr[2]}.table
	printInto "done insert 1 record to database :) "

}

function insertIntoTable
{
	printInto 'please write command insert like insert into nameTable valuses(nameCol,...)'
        read -p "please Enter command: " commandInsert

	commandInsertArr=(${commandInsert})

	if [[ ${#commandInsertArr[@]} == 4 ]]
	then

		if [[ ${commandInsertArr[0]} == 'insert' && ${commandInsertArr[1]} == 'into' && ${commandInsertArr[3]} == "values("*")" ]]
		then 
			if [[ -f ./DBs/$connectToDb/${commandInsertArr[2]}.table && -f ./DBs/$connectToDb/${commandInsertArr[2]}.metaData  ]]
			then
				checkTypeOfCol ${commandInsertArr[3]}
			else
				printInto "table ${commandInsertArr[2]} not found in database" 
			fi	
		else
			printInto "wrong statement"

		fi
	else
       		printInto "you insert more arguments"	
	fi 

}




#________________________Table Menu____________________________

function TableMenu 
{
	clear
        PS3=$connectToDb":You Select => "
	printInto '--------- Please Select From Tabel Menu :) ---------'	
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
        read -p "please enter name of data base: " nameDatabase
	if [ -d ./DBs/$nameDatabase ]
	then 
		
		printInto "database $nameDatabase already exists"
		
	elif [[ $nameDatabase == *"/"* ]]
	then 
		printInto "invalid database name"
	elif [ -f ./DBs/$nameDatabase ]
	then 
		printInto " invalid, there is file has same name"
		
	else
		mkdir -p ./DBs/$nameDatabase

		printInto " done create database $nameDatabase "
		
	fi
}


#_______________________list database________________________

function listDatabase
{ 
	if [[ `ls -l ./DBs | grep '^d' | wc -l` == 0 ]]
	then 
		printInto "No database found"1
		
	else
		
		 printInto "Database are" 
		

		ls -l ./DBs | grep '^d' | awk '{print NR"-", $9}'
	fi
	read -n1
	startDBMS
}


#_______________________list database to select________________________

function listDatabaseToSelect
{
        whichDB=( $(ls -d ./DBs/* | cut -d"/" -f3 ) "Back to start" )
        numberOfDB=${#whichDB[@]}
	PS3="select number of database to "$1" : "
	printInto '---------------- select number of databases ----------------' 
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
                        printInto "invalid option $REPLY"
                fi
        done
}

#_______________________connect to database________________________

function connectToDatabase
{

	listDatabaseToSelect "connect"
	connectToDb=$returnFromFun
	printInto "go to DB $connectToDb"
	TableMenu 
}

#________________________drop database____________________________

function dropDatabase
{
	listDatabaseToSelect "drop"
        nameDbToDrop=$returnFromFun
	rm -rf ./DBs/${nameDbToDrop}
        printInto "drop database $nameDbToDrop successfully" 
	printInto '------------------------ drop again or back to menu -------------------'
	PS3="You Select => "
	options=("Drop another Database" "Menu database")
	select opt in "${options[@]}"
	do
		case $REPLY in 
			1) dropDatabase
				;;
			2) startDBMS
			       	;;
			*) echo invalid option $REPLY;;
		esac
	done
}

#________________________start DBMS____________________________

function startDBMS
{
clear
PS3="You Select => "

printInto '------------------------ start DBMS --------------------'

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

