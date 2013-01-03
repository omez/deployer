#!/bin/bash


CONFIG_STRUCT_MAINTENANCE="$CONFIG_STRUCT_SHARED/maintenance"
CONFIG_STRUCT_BACKUP="$CONFIG_STRUCT_SHARED/backup"
CONFIG_CURRENT_BKP="$(dirname $CONFIG_STRUCT_CURRENT)/~$(basename $CONFIG_STRUCT_CURRENT)"
#CONFIG_RELEASE_PREFIX="build-"


## Turns structure off to maintenance mode
# @triggers turn-off.pre
# @triggers turn-off.post
function turnoff() {
	echo "Switching site OFF to maintenance mode" && validate;
	
	if [ `readlink -f $CONFIG_STRUCT_MAINTENANCE` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		echo "Site already points to maintenance '$CONFIG_STRUCT_MAINTENANCE'"
		exit $ERROR_STRUCT_OK;
	fi	
	
	hook turn-off pre
	
	# Copy existing pointer to build into actual (no override if exists)
	cp -npT $CONFIG_STRUCT_CURRENT $CONFIG_STRUCT_CURRENT_BKP  && success "$CONFIG_STRUCT_CURRENT_BKP->$(readlink -f $CONFIG_STRUCT_CURRENT_BKP)" || error "Unable to create actual symlink" turn-off recovery 
	
	# Creating link to maintenance mode
	symlink maintenance
	
	hook turn-off post
}
