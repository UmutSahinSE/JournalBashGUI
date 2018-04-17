#!/bin/bash

profileName=""
profilePassword=""
authenticationFlag=0

function createProfile(){
	while true
	do
		dialog --clear  --backtitle $appName --title "Create Profile" --inputbox "Your Name" 20 50 2> "result.txt"
		profileName=$(cat result.txt)
		if ! [[ $profileName =~ ^[a-zA-Z]+$ ]]
		then
			dialog --clear  --backtitle $appName --title "Problem"  --yesno "Please only use letters a-z without spaces or special characters, try again?" 20 50 2> "result.txt"
			if [[ $? == 1  ]]
			then exit 0 
			fi
		else
			break	
		fi
	done

	while true
	do
		dialog --clear  --backtitle $appName --title "Create Profile" --passwordbox "Your Password" 20 50 2> "result.txt"
		if ! [[ $profileName =~ ^$ ]]
		then break
		fi
	done
	profilePassword=$(cat result.txt)
	mkdir entries
	authenticationFlag=1
}

function prepareProfile(){
	while true  
	do
		dialog --clear  --backtitle $appName --title "Access Profile" --inputbox "Your Name (case sensitive)" 20 50 2> "result.txt"
		nameEntry=$(cat result.txt)
		if [[ -e $nameEntry.zip ]]
		then 
			profileName=$nameEntry
			break
		fi
	done

	while true
	do
		dialog --clear  --backtitle $appName --title "Create Profile" --passwordbox "Your Password" 20 50 2> "result.txt"
		profilePassword=$(cat result.txt)
		bg unzip -P $profilePassword $profileName.zip
	        sleep 1	
		if  [[ -e "aaa.sh" ]] 
		then 
			break
		else    
   			dialog --clear  --backtitle $appName --title "Problem"  --yesno "Something is wrong with password, try again?" 20 50 2> "result.txt"
			if [[ $? == 1  ]]
			then exit 0
			fi											
		fi
	done
	authenticationFlag=1
}

appName="Journal"

dialog --clear  --backtitle $appName --title "Accessing Profile" --menu "Options" 50 50 3 1 "Already Existing Profile" 2 "New Profile" 3 "Exit" 2> "result.txt"
menuitem=$(cat result.txt)
 
case $menuitem in
	1) prepareProfile;;
	2) createProfile;;
	3) exit 0;;	
esac

if [[ $authenticationFlag == 1 ]]
then echo "a"
fi
#dialog --clear  --backtitle $appName --title "Main Menu" --menu "Choose one" 20 20 4 1 "Write for Today" 2 "Write for Another Day" 3 "Read a Day" 4 "Edit a Day" 

