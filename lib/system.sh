#!bin/bash

# Executes hook with given name
# > hook deploy.pre
# will execute /hooks/[hook][.sh]
# or/and $(pwd)/.deployer/hooks/[hook][.sh]
function hook() {
	
	HOOKS="$CONFIG_APP_DIR/hooks/$1 $CONFIG_APP_DIR/hooks/$1.sh $CONFIG_CUSTOM_DIR/hooks/$1 $CONFIG_CUSTOM_DIR/hooks/$1.sh"
	
	for hook in $HOOKS; do
		if [ -x $hook ]; then
			test $CONFIG_VERBOSE && echo "> $hook hook call"  
			"$hook" || error "$hook failed"
		fi
	done;
		
}
