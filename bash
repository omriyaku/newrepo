#!/bin/bash
#####################################################################
################## -------- Hi and welcome!------- ##################
#-------------------------------------------------------------------#


# This script manages a list of records. Every action will be logged.

# You have 7 options in this script: Insert, Delete, Search (by name), Update Name, Update Amount, Printing sum of records, Print All.
 
# The log file is: RecordFileName_Log

#-------------------------------------------------------------------#

# Script Author: omri yakubovsky
# Date is issue: 4/3/2021
# mail for contact: omri.ski@gmail.com

#-------------------------------------------------------------------#
# Welcome Massage in case there is no parameter input #

if [ $# -lt 1 ]
then
  echo  ""
  echo -n "------------"
  echo -n "Hi and Welcome!"
  echo -n "------------"
  echo ""
  echo -e "For running this program you must enter a File Record Name"
  echo -e "Every time you wamt to use this script write down the name of the script and the File Record Name"
  echo -e "On this file, all the record will be saved in the format of Record_Name and Amount"
  read -p "Please enter the File Record Name: " RecordFileName
  if [ ! -e $RecordFileName ];
  then
   touch $RecordFileName
  fi
else
  RecordFileName=$1
  if [ ! -e $RecordFileName ];
  then
  touch $RecordFileName
  fi
fi

#-------------------------------------------------------------------#

# Script Functions # 

# Function 1) Insert -  Adding a record with 2 parameters: RecordName and Amount.
# Function 2) Delete -  Removing a record with 2 parameters: RecordName and Amount.
# Function 3) Search -  Search by name.
# Function 4) UpdateName -  Rename a record with 2 parameters: Old name and New name.
# Function 5) UpdateAmount -  Updating amount with 2 parameters: RecordName and NewAmount.
# Function 6) PrintAmount -  Printing Sum of records.
# Function 7) PrintAll -  Printing Sort RecordFilneName.
# Function 8) Press_Enter-  Press Enter to Continue
# Function 9) Incorrect_Selection
# Function 10) Inserting all option of grep into a variable
# Function 11) Log
# Function 12) Numeric - Only numbers in Record Amount
# Function 13) Record_Name_Alpha - Only Alpha in Record Name

log=_log

function Numeric() {
while [ -z $Record_Amount ]
do
 read -p "Record amount must be greater than 0, Please enter Record amount: " Record_Amount
done

until [[ $Record_Amount -gt 0 ]] && [[ $Record_Amount != [a-zA-Z'!'@#\$%^\&*()_+] ]]
do
  read -p "The record amount must be Numeric and greater than 0, Please re-enter the record amount: " Record_Amount
done
}

function alpha() {
while [[ $Record_Name =~ ['!'@#\$%^\&*()_+] ]]
do
 read -p "Record name must contain only Numbers, Alpha latters and space, Please re-enter the record name: " Record_Name
done
}

function Press_Enter() {
  echo ""
  echo -n "      Press Enter to return to the main menu "
  read
  clear
}

function NewRecord() {
     read -p "How many records of $Record_Name would you like to add? " Record_Amount
     Numeric
     "You Added sussesfully $Record_Amount copies of $Record_Name"
     echo $Record_Name","$Record_Amount >> $RecordFileName
     Press_Enter
}

function Insert() {
read -p "Please enter the name of the Record you want to add: " Record_Name
alpha
mapfile -t options < <(grep -i "$Record_Name" $RecordFileName)
echo $options
if [[ $options -gt 0 ]];
then
     echo "There seem to be more than one search result."
     echo "Please select the record you want:"
  select opt in "${options[@]}" "Add new record" "Rerturn to Menu" ; do 
   if (( REPLY == 1 + "${#options[@]}" )) ; then
     NewRecord
     break
   elif (( REPLY == 2 + "${#options[@]}" )) ; then
     break
   else
     Record_Picked_Option=$(echo $opt | cut -d "," -f1)
     Old_Amount=$(echo $opt | cut -d "," -f2)
     echo "#---------------------------------#"
     echo "You picked" $Record_Picked_Option
     read -p "How many records of $Record_Picked_Option would you like to add?" Record_Amount
     Numeric
     New_Amount=$(echo $Old_Amount + $Record_Amount | bc)
     sed -i /$Record_Picked_Option/s/$Old_Amount/$New_Amount/ $RecordFileName
     echo "You Added sussesfully $Record_Amount copies of $Record_Picked_Option"
     echo "Total copies if $Record_Picked_Option is now: $New_Amount"
     LS=IS
     Log
     break
   fi
  done
else
 read -p "How many records of $Record_Name would you like to add?" Record_Amount
 Numeric
 echo "You Added sussesfully $Record_Amount copies of $Record_Name"
 echo $Record_Name","$Record_Amount >> $RecordFileName
 LS=IF
 Log
 Press_Enter
fi
}

function Delete() {
read -p "Please enter the name of the Record you want to Delete: " Record_Name
alpha
mapfile -t options < <(grep -i "$Record_Name" $RecordFileName)
if [[ $options -gt 0 ]];
then
  echo "There seem to be more than one search result."
  echo "Please select the record you want Delete:"
  select opt in "${options[@]}" "Quit" ; do 
   if (( REPLY == 1 + "${#options[@]}" )) ; then
     break
   elif (( REPLY > 0 && REPLY <= "${#options[@]}" )) ; then
     Record_Picked_Option=$(echo $opt | cut -d "," -f1)
     echo "#---------------------------------#"
     echo  "You picked $Record_Picked_Option"
     echo "$Record_Picked_Option is deleted Successfully from $RecordFileName!"
     sed -i /$Record_Picked_Option/d $RecordFileName
     LS=DS
     Log
     Press_Enter
     break
   fi
  done
else
 LS=DF
 Log
 Press_Enter
fi
}

function Search() {
read -p "Please enter the name of the Record you want to Search: " Record_Name
mapfile -t options < <(grep -i "$Record_Name" $RecordFileName)
if [[ $options -gt 0 ]];
then
  echo "There seem to be more than one search result."
  echo "Please select the record you want:"
  select opt in "${options[@]}" "Return to Menu" ; do 
   if (( REPLY == 1 + "${#options[@]}" )) ; then
     break
   elif (( REPLY > 0 && REPLY <= "${#options[@]}" )) ; then
     Record_Picked_Option=$(echo $opt | cut -d "," -f1)
     echo "#---------------------------------#"
     echo  "You picked $Record_Picked_Option"
     LS=SS
     Log
     Press_Enter 
     break
   fi
  done
else
 LS=SF
 Log
 Press_Enter
 break
fi
}

function UpdateName() {
read -p "Please enter the name of the Record name you want to Update: " Record_Name
mapfile -t options < <(grep -i "$Record_Name" $RecordFileName)
if [[ $options -gt 0 ]];
then
  echo "There seem to be more than one search result."
  echo "Please select the record you want:"
  select opt in "${options[@]}" "Return to main menu" ; do 
   if (( REPLY == 1 + "${#options[@]}" )) ; then
     break
   elif (( REPLY > 0 && REPLY <= "${#options[@]}" )) ; then
     Record_Picked_Option=$(echo $opt | cut -d "," -f1)
     echo "#---------------------------------#"
     echo  "You picked $Record_Picked_Option"
     read -p "Please enter the new record name: " New_Name
     sed -i~ -e s/$Record_Picked_Option/$New_Name/g $RecordFileName
     echo "You have successfully upted the record name from $Record_Picked_Option to $New_Name" 
     LS=UNS
     Log
     break
   fi
  done
else
 LS=UNF
 Log
 Press_Enter
fi
}

function UpdateAmount() {
read -p "In order to update record amount, Please enter the name of the record: " Search_Record_Name
mapfile -t options < <(grep -i "$Search_Record_Name" $RecordFileName)
if [[ $options -gt 0 ]];
then
  echo "There seem to be more than one search result."
  echo "Please Select the correct record:"
  select opt in "${options[@]}" "Quit" ; do 
   if (( REPLY == 1 + "${#options[@]}" )) ; then
     break
   elif (( REPLY > 0 && REPLY <= "${#options[@]}" )) ; then
     Old_Amount=$(echo $opt | cut -d "," -f2)
     Record_Picked_Option=$(echo $opt | cut -d "," -f1)
     echo "#---------------------------------#"
     echo  "You picked $Record_Picked_Option"
     read -p "Please enter the new amount: " Record_Amount
     Numeric
     while [[ $Record_Amount -gt $Old_Amount ]]
     do
      echo "New record amount can not be greater than existing record amount"
      read -p "Please re-enter record amount: " Record_Amount
     done
     sed -i /$Record_Picked_Option/s/$Old_Amount/$Record_Amount/ $RecordFileName
     echo "Good Job! You updated the amount of record" $Record_Picked_Option
     echo "Old record amount: " $Old_Amount
     echo "New record amount: " $Record_Amount
     LS=UAS
     X=S
     Log
     Press_Enter
     break
   fi
  done
else
 LS=UAF
 x=F
 Log
 Press_Enter
fi
}

function DeleteRA() {
until [ "$selection" = "0" ]; do
clear
  echo "What would you like to do?"
  echo ""
  echo "        1) Delete Record"
  echo "        2) Reducing Record Amount"
  echo "        3) Return to main menu"
  echo ""
  echo -n "  Enter selection: "
  read -p "Please choose: " selection
  echo " "
  case $selection in
    1 ) clear ; Delete ;;
    2 ) clear ; UpdateAmount ;;
    3 ) clear ; break ;;
  esac
done
}

function PrintAmount() {
Sum_Records=$(awk -F ',' ' $2 {sum+=$2} END {print sum}' $RecordFileName)
if [[ $Sum_Records -gt 0 ]];
then
 echo "#-------------------------------#"
 echo "#        Sum of Records         #"
 echo "Sum of records is: $Sum_Records"
 LS=PAS
 Log
else
 Sum_Records=0
 LS=PAF
 Log
 Press_Enter
fi
}

function PrintAll() {
Line=$(awk 'END{print NR}' $RecordFileName)

if [[ $Line -gt 0 ]];
 then
  sort -d $RecordFileName
  LS=PS
  Log
 else
  LS=PF
  Log
fi
}

function Incorrect_Selection() {
  echo "Incorrect selection! Please try again."
}

function Log() {

if [[ $LS == "IS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Insert Success" >> $RecordFileName$log
elif [[ $LS == "IF" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Insert Failure" >> $RecordFileName$log
elif [[ $LS == "DS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Delete Success" >> $RecordFileName$log
elif [[ $LS == "DF" ]];
then
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert" 
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Delete Failure" >> $RecordFileName$log
elif [[ $LS == "SS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Search Success" >> $RecordFileName$log
elif [[ $LS == "SF" ]]; 
then
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert" 
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Search Failure" >> $RecordFileName$log
elif [[ $LS == "UNS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "UpdateName Success" >> $RecordFileName$log
elif [[ $LS == "UNF" ]];
then
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert" 
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "UpdateName Failure" >> $RecordFileName$log
elif [[ $LS == "UAS" ]] && [[ $x == "S" ]];
then 
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Delete Success" >> $RecordFileName$log
elif [[ $LS == "UAS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "UpdateAmount Success" >> $RecordFileName$log
elif [[ $LS == "UAF" ]] && [[ $x == "F" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "Delete Failure" >> $RecordFileName$log
elif [[ $LS == "UAF" ]];
then
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert"
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "UpdateAmount Failure" >> $RecordFileName$log
elif [[ $LS == "PAS" ]];
then
 echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "PrintAmount Success Sum=$Sum_Records" >> $RecordFileName$log
elif [[ $LS == "PAF" ]];
then
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert" 
elif [[ $LS == "PS" ]];
then
 while IFS= read -r line; do
  echo $(date +%d/%m/%Y) $(date +%H:%M:%S) "PrintAll $line" >> $RecordFileName$log
 done < $RecordFileName
else
 echo "oops, there seem to be no records on the list"
 echo "If you want to add records to the file, Please return to the main menu and pick option 1: Insert"
fi
}



#-------------------------------------------------------------------#

# Script Menu #

until [ "$selection" = "0" ]; do
  clear
  echo "--------------------------------"
  echo "------------Welcome-------------"
  echo "--------------------------------"
  echo ""
  echo "        1) Insert"
  echo "        2) Delete"
  echo "        3) Search"
  echo "	4) UpdateName"
  echo "	5) UpdateAmount"
  echo "	6) PrintAmount"
  echo "	7) PrintAll"
  echo "        0) Exit"
  echo ""
  echo -n "  Enter selection: "
  read selection
  echo " "
  case $selection in
    1 ) clear ; Insert ;;
    2 ) clear ; DeleteRA ;;
    3 ) clear ; Search ;;
    4 ) clear ; UpdateName ;;
    5 ) clear ; UpdateAmount ; Press_Enter ;;
    6 ) clear ; PrintAmount ; Press_Enter ;;
    7 ) clear ; PrintAll ; Press_Enter ;;
    0 ) clear ; exit ;;
    * ) clear ; Incorrect_Selection ; Press_Enter ;;
  esac
done

#-------------------------------------------------------------------#
