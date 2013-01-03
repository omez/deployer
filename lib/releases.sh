#!/bin/bash

CONFIG_STRUCT_RELEASES="releases"

function init_releases() {
	echo "Initializing releases structure"
	
	hook init-releases pre
	
	mkdir -p $CONFIG_STRUCT_RELEASES || error "Unable to create $CONFIG_STRUCT_RELEASES" init-releases recovery
	
	validate_releases
	
	hook init-releases post
}

function validate_releases() {
	test $CONFIG_VERBOSE && echo "> validating releases structure"
	
	hook validate-releases pre
	
	# Release link
	#test -L $CONFIG_STRUCT_RELEASE || error "Release pointer '$CONFIG_STRUCT_RELEASE' should be a link" validate-releases recovery;
	
	# Releases dir
	test -d $CONFIG_STRUCT_RELEASES || error "Backup directory '$CONFIG_STRUCT_RELEASES' doesn't exist" validate-releases recovery;
	
	hook validate-releases post
	
	test $CONFIG_VERBOSE && echo "> validating releases structure complete"
}



##### Switches current location to specified #####
# 
# @triggers switch.pre
# @triggers switch.post
function switch() {
	echo "Switching to new version $1" && validate && validate_releases;
	
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
	
	if [ `readlink -f $TARGET` == `readlink -f $CONFIG_STRUCT_RELEASE` ]; then
		echo "'$CONFIG_STRUCT_RELEASE' already points to target '$TARGET'"
		exit $ERROR_STRUCT_OK;
	fi
	
	
	# if release dir is not a link - remove it
	test -L $CONFIG_STRUCT_RELEASE || rm -R $CONFIG_STRUCT_RELEASE
	
	ln -nsf $TARGET $CONFIG_STRUCT_RELEASE
	test $CONFIG_VERBOSE && echo "> pointed to '$CURRENT'->'$TARGET'"
	
	hook switch post
	success "Switching complete"
}

