#!/bin/bash
# Initialization script
# Has a hook to check if structure is okay
#
# Desired directory strcuture
# 
# /builds
# /maintenance
# /current
# /workspace
#

CONFIG_STRUCT_CURRENT="current"
CONFIG_STRUCT_MAINTENANCE="maintenance"
CONFIG_STRUCT_BUILDS="builds"
CONFIG_STRUCT_ACTUAL="actual"
CONFIG_BACKUP_DIR="backup"

## Creates directory structure and set appropriate access rights
# @triggers init.pre
# @triggers init.post
function init() {
	
	hook "init.pre"
	
	if [ ! -d ./$CONFIG_STRUCT_BUILDS ]; then
		mkdir ./$CONFIG_STRUCT_BUILDS && success "Builds directory created" || error "Error during build directory creation" "struct_init.recovery";
	else
		warning "'./$CONFIG_STRUCT_BUILDS' directory exists"	
	fi
	
	if [ ! -d ./$CONFIG_STRUCT_MAINTENANCE ]; then
		mkdir ./$CONFIG_STRUCT_MAINTENANCE && success "Maintenance mode directory './$CONFIG_STRUCT_MAINTENANCE' created" || error "Error during maintenance mode directory '$CONFIG_STRUCT_MAINTENANCE' creation" "struct_init.recovery";
	else
		warning "Maintenance mode directory './$CONFIG_STRUCT_MAINTENANCE' exists"	
	fi
	
	if [ ! -L ./$CONFIG_STRUCT_CURRENT ]; then
		ln -sf $CONFIG_STRUCT_MAINTENANCE $CONFIG_STRUCT_CURRENT && success "Created symbolic link ./$CONFIG_STRUCT_CURRENT -> ./$CONFIG_STRUCT_MAINTENANCE" || error "Error during 'Current' link creation" "struct_init.recovery";
	else
		warning "Current symbolic link './$CONFIG_STRUCT_CURRENT' exists or not accessible"	
	fi
	
	# adding .custom dir here
	mkdir $CONFIG_CUSTOM_DIR 
	mkdir $CONFIG_CUSTOM_DIR/hooks
	
	echo "Checking created structure"	
	validate
	
	hook "init.post"
}


## Validates existing structure for errors
# @triggers validate.pre
# @triggers validate.post
function validate() {
	test $CONFIG_VERBOSE && echo "> testing directory structure"
	
	hook "validate.pre"
	
	# Maintenance
	test -d $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory '$CONFIG_STRUCT_MAINTENANCE' doesn't exist" "struct_check.recovery";
	test ! -L $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory '$CONFIG_STRUCT_MAINTENANCE' should not be a symbolic link" "struct_check.recovery";
	
	
	# Build directory
	test -d $CONFIG_STRUCT_BUILDS || error "Build directory '$CONFIG_STRUCT_BUILDS' doesn't exist" "struct_check.recovery";
	test ! -L $CONFIG_STRUCT_BUILDS || error "Build directory '$CONFIG_STRUCT_BUILDS' should not be a symbolic link" "struct_check.recovery";
	
	
	# Current directory
	test -L $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be a symbolic link" "struct_check.recovery";
	# @todo check for writable, maybe by chmod flags
	#test -w $CONFIG_STRUCT_CURRENT || error "Current directory '$CONFIG_STRUCT_CURRENT' should be able to be changed with current user" "struct_check.recovery";
	
	hook "struct_check.post"
	
	test $CONFIG_VERBOSE && echo "> testing directory complete"
}


## Test pointer for folder
## Usage testpointer "where/to/link" "message if wrong"
function testpointer() {
	test $CONFIG_VERBOSE && echo "> testing pointer $CONFIG_STRUCT_CURRENT -> $1"
	if [ `readlink -f $1` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		echo $2;
		exit $ERROR_STRUCT_OK;
	fi
}


## Turns structure ON to specific build
# @triggers turn-on.pre
# @triggers turn-on.post 
function turnon() {
	echo "Switching site ON"
	validate;
	
	local NOCHANGE=0
	
	# Prepare arguments
	if [ -z $1 ]; then
		test -L $CONFIG_STRUCT_ACTUAL || error "Build name, directory or actual state required"
		TARGET=$(readlink $CONFIG_STRUCT_ACTUAL)
		unlink $CONFIG_STRUCT_ACTUAL
		NOCHANGE=1
	elif [ -d $CONFIG_STRUCT_BUILDS/$1 ]; then
		TARGET="$CONFIG_STRUCT_BUILDS/$1"
		test $CONFIG_VERBOSE && echo "> using build number $1"
	elif [ -d $1 ]; then
		TARGET=$1
		test $CONFIG_VERBOSE && echo "> using directory $1"
	else
		error "Unable to recognize target directory from specified '$1'" "turn-on.recovery"
	fi
	
	test -d $TARGET || error "Unable to access directory $TARGET" 
	
	if [ `readlink -f $TARGET` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		echo "Site already points to target '$TARGET'"
		exit $ERROR_STRUCT_OK;
	fi
	
	hook "turn-on.pre"
	
	## switch current directory to specified build
	setlink $CONFIG_STRUCT_CURRENT $TARGET
	
	hook "turn-on.post"
}

## Turns structure off to maintenance mode
# @triggers turn-off.pre
# @triggers turn-off.post
function turnoff() {
	echo "Switching site OFF to maintenance mode"
	validate;
	
	if [ `readlink -f $CONFIG_STRUCT_MAINTENANCE` == `readlink -f $CONFIG_STRUCT_CURRENT` ]; then
		echo "Site already in maintenance mode"
		exit $ERROR_STRUCT_OK;
	fi
	
	hook "turn-off.pre"
	
	# Copy existing pointer to build into actual (no override if exists)
	cp -nPT $CONFIG_STRUCT_CURRENT $CONFIG_STRUCT_ACTUAL \
	&& success "$CONFIG_STRUCT_ACTUAL->$(readlink -f $CONFIG_STRUCT_ACTUAL)" \
	|| error "Unable to create actual symlink" "turn-off.recovery" 
	
	# Creating link to maintenance mode
	setlink $CONFIG_STRUCT_CURRENT $CONFIG_STRUCT_MAINTENANCE
	
	hook "turn-off.post"
}




##### Creates fully-working backup version #####
#
# @triggers backup.pre
# @triggers backup.post
function backup() {
	
	# Exit if backup exists
	if [ -d $CONFIG_BACKUP_DIR ]; then
		echo "Backup directory already exists";
		exit $ERROR_CODE_NORMAL;
	fi
	
	hook "backup.pre"
	
	
	
	hook "backup.post"
	
}

##### Finalizes deployment #####
#
# @triggers finalize.pre
# @triggers finalize.post
function finalize() {
	
	# Process finalization of build. Can be run only from console
	echo "Are you sure you want to finalize current build?"
	# @todo add confirmation command here
	
	hook "finalize.pre"	
	
	
	
	hook "finalize.post"
	
}

##### Recovers deployment from stash #####
#
# @triggers backup.pre
# @triggers backup.post
function fallback() {
	echo "Falling back to backuped version"
	
	hook "backup.pre"
	
	
	
	hook "backup.post"
	
	unlink $CONFIG_BACKUP_DIR;
}

##### Switches current location to specified #####
#
# @triggers switch.pre
# @triggers switch.post
function switch() {
	echo "Switching to new version"
	
	hook "switch.pre"
	
	
	
	hook "switch.post"
	
}



