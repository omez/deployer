#!bin/bash

# Executes hook with given name
# > hook deploy.pre
# will execute /hooks/[hook][.sh]
# or/and $(pwd)/.deployer/hooks/[hook][.sh]
function hook() {
	
	hookin $CONFIG_APP_DIR/hooks $1 $2
	hookin $CONFIG_CUSTOM_DIR/hooks $1 $2
	
}

## Executes hooks in specified directory
#
function hookin() {
	
	test ! -z $1 && DIR=$1 || error "Hook directory is not specified"
	test ! -z $2 && HOOK=$2 || error "Hook name is not specified"
	test ! -z $3 && EVENT=$3 || EVENT=""
	
	test $CONFIG_VERBOSE && echo "> Hooking '$HOOK' of '$EVENT' in '$DIR'"
	
	test -z $EVENT && PATTERN=$HOOK || PATTERN="$HOOK\.$EVENT"
	
	FILES=`find $DIR -regex "^.*/$PATTERN\(\..+\)?\(.sh\)?$" -perm /u=x,g=x,o=x | sort`
	
	for hook in $FILES; do
		test $CONFIG_VERBOSE && echo ">> $hook hook call"  
			
		___tmp=$(pwd) # Remember position
		. $hook || error "$hook failed"
		cd $___tmp # back to prev PWD
			
	done;
	
}

## Creates/modifies link
function setlink() {
	
	test -L $1 && unlink $1;
	
	ln -sfT $2 $1 \
	|| error "Unable to create link '$1'->'$2'" \
	&& success "Link '$1'->'$2' successfully created"
	
}