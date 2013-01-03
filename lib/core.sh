#!/bin/bash
# Initialization script
# Has a hook to check if structure is okay
#
# Desired directory strcuture
# 

CONFIG_STRUCT_CURRENT="current"
CONFIG_STRUCT_RELEASES="releases"
CONFIG_STRUCT_SHARED="shared"


## Creates directory structure and set appropriate access rights
# @triggers init.pre
# @triggers init.post
function init() {
	
	hook init pre
	
	mkdir -p $CONFIG_STRUCT_RELEASES || error "Unable to create $CONFIG_STRUCT_RELEASES" init recovery
	mkdir -p $CONFIG_STRUCT_SHARED || error "Unable to create $CONFIG_STRUCT_SHARED" init recovery
	mkdir -p $CONFIG_STRUCT_MAINTENANCE || error "Unable to create $CONFIG_STRUCT_MAINTENANCE" init recovery
	#mkdir -p $CONFIG_STRUCT_BACKUP || error "Unable to create $CONFIG_STRUCT_BACKUP" init recovery
	ln -nsf $CONFIG_STRUCT_MAINTENANCE $CONFIG_STRUCT_CURRENT || error "Unable to create link $CONFIG_STRUCT_CURRENT" init recovery
	
	# adding .custom dir here
	mkdir $CONFIG_CUSTOM_DIR 
	mkdir $CONFIG_CUSTOM_DIR/hooks
	
	echo "Checking created structure"	
	validate
	
	hook init post
}


## Validates existing structure for errors
# @triggers validate.pre
# @triggers validate.post
function validate() {
	test $CONFIG_VERBOSE && echo "> testing directory structure"
	
	hook validate pre
	
	# Releases
	test -d $CONFIG_STRUCT_RELEASES || error "Releases directory '$CONFIG_STRUCT_MAINTENANCE' doesn't exist" validate recovery;
	
	# Shared
	test -d $CONFIG_STRUCT_SHARED || error "Shared directory '$CONFIG_STRUCT_SHARED' doesn't exist" validate recovery;
	
	# Maintenance
	test -d $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory '$CONFIG_STRUCT_MAINTENANCE' doesn't exist" validate recovery;
	
	# Current directory
	test -L $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be a symbolic link" validate recovery;
	# @todo check for writable, maybe by chmod flags
	#test -w $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be able to be changed with current user" "struct_check.recovery";
	
	hook validate post
	
	test $CONFIG_VERBOSE && echo "> testing directory complete"
}


##### Switches current location to specified #####
# 
# @triggers switch.pre
# @triggers switch.post
function switch() {
	echo "Switching to new version $1" && validate;
	
	TARGET=$1
	
	# Prepare arguments
	test -z $TARGET && error "No version specified" switch recovery
	
	hook switch pre
	
	if [ -d $CONFIG_STRUCT_RELEASES/$1 ]; then
		TARGET="$CONFIG_STRUCT_RELEASES/$1"
		test $CONFIG_VERBOSE && echo "> using build number $1"
	elif [ -d $1 ]; then
		TARGET=$1
		test $CONFIG_VERBOSE && echo "> using directory $1"
	else
		error "Unable to recognize target directory from specified '$1'" switch recovery
	fi
	
	test -d $TARGET || error "Unable to access directory $TARGET" switch recovery
	
	if [ `readlink -f $TARGET` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		echo "Site already points to target '$TARGET'"
		exit $ERROR_STRUCT_OK;
	fi
	
	ln -nsf $TARGET $CONFIG_STRUCT_CURRENT
	test $CONFIG_VERBOSE && echo "> pointed to '$CURRENT'->'$TARGET'"
	
	hook switch post
	success "Switching complete"
}

