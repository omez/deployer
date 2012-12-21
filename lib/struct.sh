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
	test ! -d $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory doesn't exist" "struct_check.recovery";
	test -L $CONFIG_STRUCT_MAINTENANCE || error "Maintenance mode directory should not be a symbolic link" "struct_check.recovery";
	
	
	# Build directory
	test ! -d $CONFIG_STRUCT_BUILDS || error "Build directory doesn't exist" "struct_check.recovery";
	test -L $CONFIG_STRUCT_BUILDS || error "Build directory should not be a symbolic link" "struct_check.recovery";
	
	
	# Current directory
	test ! -L $CONFIG_STRUCT_CURRENT || error "Build directory should be a symbolic link" "struct_check.recovery";
	test -w $CONFIG_STRUCT_CURRENT || error "Current directory should be able to be changed with current user" "struct_check.recovery";
	
	hook "struct_check.post"
}


## Turns structure ON to specific build
function turnon() {
	echo "Switching site ON"
	struct_check;
	
	# Prepare arguments
	if [ -z $2 ]; then
		echo "Build name or directory required" 
		exit $ERROR_CODE_NORMAL;
	fi 
	
	if [ -d $CONFIG_BUILD_DIR/$2 ]; then
		test $CONFIG_VERBOSE && echo "> using build number $BUILD"
		$TARGET=$CONFIG_BUILD_DIR/$BUILD
	else 
		test $CONFIG_VERBOSE && echo "> using directory $BUILD"
		$TARGET=$2
	fi
	
	hook "turn-on.pre"
	
	test -d $TARGET || error "Unable to access directory $TARGET" "turn-on.recovery"
		
	## switch current directory to specified build
	ls -sf $TARGET $CONFIG_STRUCT_CURRENT	
	
	hook "turn-on.post"
}


## Turns structure off to maintenance mode
function turnoff() {
	echo "Switching site OFF to maintenance"
	struct_check;
	
	hook "turn-on.pre"
	
	ls -sf $TARGET $CONFIG_STRUCT_MAINTENANCE
	
	hook "turn-on.post"
}





