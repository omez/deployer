#!/bin/bash
# Initialization script
# Has a hook to check if structure is okay
#
# Desired directory strcuture
# 

CONFIG_STRUCT_CURRENT="current"
CONFIG_STRUCT_RELEASE="release"
CONFIG_STRUCT_MAINTENANCE="maintenance"
CONFIG_STRUCT_SHARED="shared"


## Creates directory structure and set appropriate access rights
# @triggers init.pre
# @triggers init.post
function init() {
	echo "Initializing core structure"
	hook init pre
	
	mkdir -p $CONFIG_STRUCT_RELEASE || error "Unable to create $CONFIG_STRUCT_RELEASE" init recovery
	mkdir -p $CONFIG_STRUCT_SHARED || error "Unable to create $CONFIG_STRUCT_SHARED" init recovery
	mkdir -p $CONFIG_STRUCT_MAINTENANCE || error "Unable to create $CONFIG_STRUCT_MAINTENANCE" init recovery
	ln -nsf $CONFIG_STRUCT_MAINTENANCE $CONFIG_STRUCT_CURRENT || error "Unable to create link $CONFIG_STRUCT_CURRENT" init recovery
	
	# adding .custom dir here
	mkdir $CONFIG_CUSTOM_DIR 
	mkdir $CONFIG_CUSTOM_DIR/hooks
	
	validate
	
	hook init post
}


## Validates existing structure for errors
# @triggers validate.pre
# @triggers validate.post
function validate() {
	test $CONFIG_VERBOSE && echo "> validating core structure"
	
	hook validate pre
	
	# Releases
	test -d $CONFIG_STRUCT_RELEASE || error "Release directory '$CONFIG_STRUCT_RELEASE' doesn't exist" validate recovery;
	
	# Shared
	test -d $CONFIG_STRUCT_SHARED || error "Shared directory '$CONFIG_STRUCT_SHARED' doesn't exist" validate recovery;
	
	# Maintenance
	test -d $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory '$CONFIG_STRUCT_MAINTENANCE' doesn't exist" validate recovery;
	
	
	
	# Current directory
	test -L $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be a symbolic link" validate recovery;
	# @todo check for writable, maybe by chmod flags
	#test -w $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be able to be changed with current user" "struct_check.recovery";
	
	hook validate post
	
	test $CONFIG_VERBOSE && echo "> validating core structure complete"
}


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
	
	ln -nsf $CONFIG_STRUCT_MAINTENANCE $CONFIG_STRUCT_CURRENT
	test -L $CONFIG_STRUCT_CURRENT || error "Link '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_MAINTENANCE' not created"
	test $CONFIG_VERBOSE && echo "> '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_MAINTENANCE'"
	
	hook turn-off post
}


## Turns structure ON to specific build
# @triggers turn-on.pre
# @triggers turn-on.post 
function turnon() {
	echo "Switching site ON to release"  && validate;
	
	if [ `readlink -f $CONFIG_STRUCT_RELEASE` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		error "Site already points to release '$CONFIG_STRUCT_RELEASE' ($(readlink -f $CONFIG_STRUCT_RELEASE))"
	fi
	
	hook turn-on pre
	
	ln -nsf $CONFIG_STRUCT_RELEASE $CONFIG_STRUCT_CURRENT
	test -L $CONFIG_STRUCT_CURRENT || error "Link '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_RELEASE' not created"
	test $CONFIG_VERBOSE && echo "> '$CONFIG_STRUCT_CURRENT'->'$CONFIG_STRUCT_RELEASE'"
	
	hook turn-on post
}
