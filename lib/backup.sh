#!/bin/bash

CONFIG_STRUCT_BACKUP="backup"


function init_backup() {
	echo "Initializing backup structure"
	
	hook init-backup pre
	
	mkdir -p $CONFIG_STRUCT_BACKUP || error "Unable to create $CONFIG_STRUCT_BACKUP" init recovery
	
	validate_backup
	
	hook init-backup post
}

function validate_backup() {
	test $CONFIG_VERBOSE && echo "> validating backup structure"
	
	# Backup
	test -d $CONFIG_STRUCT_BACKUP || error "Backup directory '$CONFIG_STRUCT_BACKUP' doesn't exist" validate recovery;
	
	hook validate-backup pre
	
	test $CONFIG_VERBOSE && echo "> validating backup structure complete"
	
	hook validate-backup post
	
	
}

##### Creates fully-working backup version #####
#
# @triggers backup.pre
# @triggers backup.action
# @triggers backup.post
function backup() {
	echo "Backuping current release"  && validate_backup;
	
	# Exit if backup exists
	if [ "$(ls -A $CONFIG_STRUCT_BACKUP)" ]; then
		echo "Backup directory already exists and has content";
		exit $ERROR_CODE_NORMAL;
	fi	
	
	hook backup pre
	
	# backup is here
	hook backup action
	
	hook backup post
	
}

##### Recovers deployment from crash #####
#
# @triggers rescue.pre
# @triggers rescue.action
# @triggers rescue.post
function rescue() {
	echo "Falling back to backuped version" && validate && validate_backup;
	
	if [ ! "$(ls -A $CONFIG_BACKUP_DIR)" ]; then
		echo "No backup to recue";
		exit $ERROR_CODE_OK;
	fi	
	
	hook rescue pre
	
	ln -nsf $CONFIG_STRUCT_BACKUP $CONFIG_STRUCT_CURRENT
	test -L $CONFIG_STRUCT_CURRENT || error "Link '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_BACKUP' not created"
	test $CONFIG_VERBOSE && echo "> '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_BACKUP'"
	
	hook rescue post
}

##### Finalizes deployment #####
#
# @triggers finalize.pre
# @triggers finalize.post
function stabilize() {
	echo "Stabilizing current version and cleaning up backup" && validate && validate_backup;
	
	if [ ! "$(ls -A $CONFIG_BACKUP_DIR)" ]; then
		echo "Backup directory has no backup content";
		exit $ERROR_CODE_OK;
	fi	
	
	if [ -z $CONFIG_NO_INTERACTION ]; then
		read -n 1 -p "Are you sure you want to finalize current build? (Yes/[a]): " AMSURE
		echo ""
		case $AMSURE in
			yes|y|Y)
				## Do nothing here
				;;
			*)
				exit $ERROR_CODE_NORMAL
				;;
		esac
	fi
	
	hook stabilize pre	
	
	rm -Rf $CONFIG_STRUCT_BACKUP/*
	test $CONFIG_VERBOSE && echo "> clean $CONFIG_STRUCT_BACKUP"
	
	hook stabilize post
	
}
