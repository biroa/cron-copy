#!/usr/bin/env bash

#User
user=twggroupaws

# Color initializations for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# config we read from the user's home folder
configFile=~/.env

# The cron config we need to use for cron creation
copyToPath=$PWD
copyFromPath="Crontab/"
# delete cron file
deleteCron () {
	crontab -r || true
}

# copy file from the $copyFromPath to the $copyToPath as $fileName
copyCron () {
	parameter=("$@")
	copyFrom="$copyFromPath${parameter[0]}"
	 sudo crontab -u $user -l 2>/dev/null
	 cat "${copyFrom}" | crontab
}

# loop over all the lines of a file
# look for a specific name
readProp () {
    parameter=("$@")
    file="${parameter[0]}"
    keyword="${parameter[1]}"
	todoFunctions="${@:3}"
	functionsNum="${#todoFunctions[@]}"

	counter=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
		propertyName=$(awk -F= '{print $1}' <<< "$line")
		#counter=$[counter + 1]
		if [ "$propertyName" == $keyword ];
		then
		    environment=$(awk -F= '{print $2}' <<< "$line")
		fi
	done < "$file"

		# if the functionsNum array is not empty
	if [ "$functionsNum" -gt 0 ];
	then
		for i in $todoFunctions
		do
			if [ -n "$(type -t ${i})" ] && [ "$(type -t ${i})" = function ];
			then
				${i} $environment
			else
				echo -e "${RED}There is no function defined as:${YELLOW} $i ${RED}!!!${NC}"
			fi
		done
	fi


}

tasks=("deleteCron" "copyCron")

# $1 : {name of the file} as the source of haystack
# $2 : The keyword we look for in the haystack
# $3 : List of function we like to chain for further process
readProp $configFile TWG_ENV "${tasks[@]}"
