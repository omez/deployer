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

# Creates directory structure and set appropriate access rights
# @triggers struct_init.pre
# @triggers struct_init.post
function struct_init() {
	
	hook "struct_init.pre"
	
	if [ ! -d builds ]; then
		mkdir builds && success "Builds directory created" || error "Error during build directory creation" "struct_init.recovery";
	else
		warning "Builds directory exists"	
	fi
	
	if [ ! -d maintenance ]; then
		mkdir maintenance && success "Maintenance mode directory created" || error "Error during maintenance mode directory creation" "struct_init.recovery";
	else
		warning "Maintenance mode directory exists"	
	fi
	
	if [ ! -L current ]; then
		ln -s current maintenance && success "Created symbolic link ./current -> ./maintenance" || error "Error during 'Current' link creation" "struct_init.recovery";
	else
		warning "Current symbolic link exists or not accessible"	
	fi
	
	echo "Checking created structure"	
	struct_check
	
	hook "struct_init.post"
}


# Validates existing structure for errors
# @triggers struct_check.pre
# @triggers struct_check.post
function struct_check() {
	
	hook "struct_check.pre"
	
	# Maintenance
	test ! -d maintenance || error "Maintenance mode directory doesn't exist" "struct_check.recovery";
	test -L maintenance || error "Maintenance mode directory should not be a symbolic link" "struct_check.recovery";
	
	
	# Build directory
	test ! -d build || error "Build directory doesn't exist" "struct_check.recovery";
	test -L build || error "Build directory should not be a symbolic link" "struct_check.recovery";
	
	
	# Current directory
	test ! -L build || error "Build directory should be a symbolic link" "struct_check.recovery";
	
	hook "struct_check.post"
}
