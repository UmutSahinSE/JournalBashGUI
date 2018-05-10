#!/bin/bash

profileName=""
profilePassword=""
authenticationFlag=0
result=$(mktemp /tmp/result.XXXXXX) #tempfile to keep results received from user.

function finisher(){
	if [[ $authenticationFlag == 1 ]]
	then
	zip -P $profilePassword $profileName.zip *-Journal.txt #Put every entry back to user's zip
	fi
	rm *\-Journal.txt #Deleting all entries left outside user's zip 
	exit 0
}

function writeForToday(){
	day=$(date | awk '{print $3;}' )
	month=$(LANG=en_us_88591; date +"%b") #To have english months
	year=$(date| awk '{print $6;}' ) 
       
	if [[ $month == "Jan" ]] 
	then month=1
	elif [[ $month == "Fan" ]] 
	then month=2
	elif [[ $month == "Man" ]] 
	then month=3
	elif [[ $month == "Apr" ]] 
	then month=4
	elif [[ $month == "May" ]] 
	then month=5
	elif [[ $month == "Jun" ]] 
	then month=6
	elif [[ $month == "Jul" ]] 
	then month=7
	elif [[ $month == "Aug" ]] 
	then month=8
	elif [[ $month == "Sep" ]] 
	then month=9
	elif [[ $month == "Oct" ]] 
	then month=10
	elif [[ $month == "Nov" ]] 
	then month=11
	elif [[ $month == "Dec" ]] 
	then month=12 
	fi

	entryFile="$day-$month-$year-Journal.txt"
	> $entryFile
	dialog --clear  --backtitle $appName --title "$day/$month/$year" --editbox $entryFile 80 80   2> $entryFile
	dialog --clear  --backtitle $appName --title "$day/$month/$year" --msgbox "Saved on $entryFile" 20 50
	
}

                        
function readOrWriteADay(){
	
	dialog --clear  --backtitle $appName --title "Information" --msgbox "Enter a date. If an entry for chosen day doesn't exist, a new entry will be created.\nIf entery for chosen day exists, you can write or edit the entry." 20 50

	while true
	do
	dialog --clear  --backtitle $appName --title "Reading a day" --inputbox "Enter day" 20 50 2> $result
	dayToRead=$(cat $result)
	if ! [[ $dayToRead =~ ^[0-9]+$  ]]
	then
		dialog --clear  --backtitle $appName --title "Problem"  --yesno "Day can only contain numeric, try again?" 20 50 2> $result
		if [[ $? == 1  ]]
		then finisher
		else continue
		fi
	elif (( $dayToRead < 1 || $dayToRead > 31 )) 
	then
		dialog --clear  --backtitle $appName --title "Problem"  --yesno "Entry must be between 1-31, try again?" 20 50 2> $result
		if [[ $? == 1  ]]
		then finisher
		else continue
		fi 
	fi
	
	dialog --clear  --backtitle $appName --title "Reading a month" --inputbox "Enter month in numeric" 20 50 2> $result
	monthToRead=$(cat $result)
	if ! [[ $monthToRead =~ ^[0-9]+$ ]]
	then
		dialog --clear  --backtitle $appName --title "Problem"  --yesno "Month can only contain numeric, try again?" 20 50 2> $result
		if [[ $? == 1  ]]
	        then finisher
		else continue
		fi													
	elif (( $monthToRead < 1 || $monthToRead > 12 ))
	then
	       dialog --clear  --backtitle $appName --title "Problem"  --yesno "Entery must be between 1-12, try again?" 20 50 2> $result
	       if [[ $? == 1  ]]
	       then finisher
	       else continue
	       fi
	elif (( $dayToRead >= 30 && $monthToRead == 2 )) #if month is february and user gives day more than 29 
	then
		dialog --clear  --backtitle $appName --title "Problem"  --yesno "Day for February can be 29 at most, try again?" 20 50 2> $result
		if [[ $? == 1  ]]
		then finisher
		else continue
		fi
	elif (( $dayToRead == 31 ))
	then 
		if (( $monthToRead == 2 ||$monthToRead == 4 || $monthToRead == 6 || $monthToRead == 9 || $monthToRead == 11 )) #months with 30 days
		then
			dialog --clear  --backtitle $appName --title "Problem"  --yesno "You chose day 31 for a non 31 length month, try again?" 20 50 2> $result
			if [[ $? == 1  ]]
			then finisher
			else continue
			fi
		fi								
	fi

        dialog --clear  --backtitle $appName --title "Reading a year" --inputbox "Enter year" 20 50 2> $result
	yearToRead=$(cat $result)
	if ! [[ $yearToRead =~ ^[0-9]+$  ]]
	then
		dialog --clear  --backtitle $appName --title "Problem"  --yesno "Year can only contain numeric, try again?" 20 50 2> $result
	        if [[ $? == 1  ]]
		then finisher
		else continue
		fi
	elif (( $yearToRead < 1900 || $yearToRead > 2018 ))
	then
	        dialog --clear  --backtitle $appName --title "Problem"  --yesno "Entry must be between 1900-2018, try again?" 20 50 2> $result
	        if [[ $? == 1  ]]
	        then finisher
	        else continue
	        fi 
        fi
	break
        done
	
	if ls "$dayToRead-$monthToRead-$yearToRead-Journal.txt" >&1;
	then
		dialog --clear  --backtitle $appName --title "Information" --msgbox "Entry exists. You can read and edit the entry." 20 50
		
		file="$dayToRead-$monthToRead-$yearToRead-Journal.txt"
		cat $file > $result
		dialog --backtitle $appName --title "$dayToRead/$monthToRead/$yearToRead" --editbox $result 50 50 2> $file
		dialog --clear  --backtitle $appName --title "$dayToRead/$monthToRead/$yearToRead" --msgbox "Saved on $file" 20 50
	else
		dialog --clear  --backtitle $appName --title "Information" --msgbox "Entery doesn't exist. Creating one." 20 50
		file="$dayToRead-$monthToRead-$yearToRead-Journal.txt"
		> $file
		dialog --clear  --backtitle $appName --title "$dayToRead/$monthToRead/$yearToRead" --editbox $file 80 80   2> $file
		dialog --clear  --backtitle $appName --title "$dayToRead/$monthToRead/$yearToRead" --msgbox "Saved on $file" 20 50
	fi
}

function createProfile(){
	while true
	do
		dialog --clear  --backtitle $appName --title "Create Profile" --inputbox "Your Name" 20 50 2> $result
		profileName=$(cat $result)
		if ! [[ $profileName =~ ^[a-zA-Z]+$ ]]
		then
			dialog --clear  --backtitle $appName --title "Problem"  --yesno "Please only use letters a-z (english characters)  without spaces or special characters, try again?" 20 50 2> $result
			if [[ $? == 1  ]]
			then finisher 
			fi
		else
			break	
		fi
	done

	while true
	do
		dialog --clear  --backtitle $appName --title "Create Profile" --passwordbox "Your Password" 20 50 2> $result
		if ! [[ $(cat $result) =~ ^$ ]]
		then break
		fi
	done
	profilePassword=$(cat $result)
	zip -P $profilePassword $profileName.zip $result
       	zip -d $profileName.zip $result	
	authenticationFlag=1
}

function prepareProfile(){
	while true  
	do
		dialog --clear  --backtitle $appName --title "Access Profile" --inputbox "Your Name (case sensitive)" 20 50 2> $result
		nameEntry=$(cat $result)
		if [[ -e $nameEntry.zip ]]
		then 
			profileName=$nameEntry
			break
		fi
	done

	while true
	do
		dialog --clear  --backtitle $appName --title "Access Profile" --passwordbox "Your Password" 20 50 2> $result
		profilePassword=$(cat $result)
		unzip -uP $profilePassword $profileName.zip #unzipping to have all files outside and working with them easily
		file=("./*Journal.txt")	
		if ls ./*-Journal.txt >&1; #if any entry did came out from zip
		then 
			break
		else    
   			dialog --clear  --backtitle $appName --title "Problem"  --yesno "Something is wrong with password, try again?" 20 50 2> $result
			if [[ $? == 1  ]]
			then finisher
			fi											
		fi
	done
	authenticationFlag=1
}

appName="Journal"

rm *\-Journal.txt #removing all entries, just to be sure there isn't any left 

dialog --clear  --backtitle $appName --title "Accessing Profile" --menu "Options" 20 50 3 1 "Already Existing Profile" 2 "New Profile" 3 "Exit" 2> $result
menuitem=$(cat $result)
 
case $menuitem in
	1) prepareProfile;;
	2) createProfile;;
	3) finisher;;	
esac

if [[ $authenticationFlag == 1 ]]
then
	dialog --clear  --backtitle $appName --title "Main Menu" --menu "Choose one" 20 50 3 1 "Write for Today" 2 "Write, read or Edit a Day" 3 "Exit" 2> $result
	menuitem=$(cat $result)

case $menuitem in
        1) writeForToday;;
        2) readOrWriteADay;;
	3) finisher;;
esac
	finisher
fi 

