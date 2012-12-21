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

## Creates directory structure and set appropriate access rights
# @triggers struct_init.pre
# @triggers struct_init.post
function struct_init() {
	
	hook "struct_init.pre"
	
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
	
	echo "Checking created structure"	
	struct_check
	
	hook "struct_init.post"
}


## Validates existing structure for errors
# @triggers struct_check.pre
# @triggers struct_check.post
function struct_check() {
	test $CONFIG_VERBOSE && echo "> testing directory structure"
	
	hook "struct_check.pre"
	
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


## Turns structure ON to specific build
# @triggers turnon.pre
# @triggers turnon.post
function turnon() {
	echo "Switching site ON"
	struct_check;
	
	# Prepare arguments
	if [ -z $1 ]; then
		echo "Build name or directory required" 
		exit $ERROR_CODE_NORMAL;
	elif [ -d $CONFIG_STRUCT_BUILDS/$1 ]; then
		TARGET="$CONFIG_STRUCT_BUILDS/$1"
		test $CONFIG_VERBOSE && echo "> using build number $1"
	elif [ -d $1 ]; then
		TARGET=$1
		test $CONFIG_VERBOSE && echo "> using directory $1"
	else
		error "Unable to recognize target directory from specified '$1'" "turn-on.recovery"
	fi
	
	hook "turn-on.pre"
	
	test -d $TARGET || error "Unable to access directory $TARGET" 
		
	## switch current directory to specified build
	setlink $CONFIG_STRUCT_CURRENT $TARGET
	
	hook "turn-on.post"
}


## Turns structure off to maintenance mode
# @triggers turnoff.pre
# @triggers turnoff.post
function turnoff() {
	echo "Switching site OFF to maintenance mode"
	struct_check;
	
	hook "turn-on.pre"
	
	setlink $CONFIG_STRUCT_CURRENT $CONFIG_STRUCT_MAINTENANCE
	
	hook "turn-on.post"
}

## Creates/modifies link
function setlink() {
	
	unlink $1 && ln -sf $2 $1 \
	|| error "Unable to create link '$1'->'$2'" \
	&& success "Link '$1'->'$2' successfully created"
	
}


