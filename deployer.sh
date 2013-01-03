#!/bin/bash

readonly CONFIG_VERSION="0.1.4-alpha1"
CONFIG_APP_DIR=$(dirname $(readlink -f $0))		# Application directory
CONFIG_WORK_DIR=$(pwd)							# Current working directory
CONFIG_CUSTOM_DIR=".deployer"					# Overriding directory with configuration in pwd
CONFIG_VERBOSE=''								# Show debug information during execution
CONFIG_NO_INTERACTION=''						# Sets into no-interaction mode

readonly ERROR_CODE_OK=0
readonly ERROR_CODE_NORMAL=1
readonly ERROR_CODE_CORE=2
readonly ERROR_CODE_EXTERNAL=3

# Include configuration files
test -f $CONFIG_APP_DIR/config.cfg && . $CONFIG_APP_DIR/config.cfg
test -d $CONFIG_CUSTOM_DIR/config.cfg && . $CONFIG_CUSTOM_DIR/config.cfg

## Some functions for information
# Prints information string
function usage() {
	echo "Usage:"
	echo "  init                    - initializes directory structure"
	echo "  validate                - validates directory structure for errors"
	echo "  switch [build number]   - switches current build to other"
	echo "  backup                  - creates backup version of site"
	echo "  turn-off                - turns site off into maintenance mode"
	echo "  turn-on                 - turns site on from maintenace/other modes"
	echo "  rescue, fallback        - restores current build form backup"
	echo "  stabilize               - marks current version as stable and removes backup"
	echo ""
	
	echo "Options:"
	echo "  -h, --help              - print this help"
	echo "  -v, --verbose           - show debug information while execution"
	echo "  -V, --version           - show version info"
	echo "  -y, --no-interaction    - no interaction"
	echo ""
}

#Parse script options
params="$(getopt -o vVhy -l verbose,version,help,no-interaction --name "deployer" -- "$@")"
eval set -- "$params"
unset params

# Collect options and set configuration flags
while true; do
	case $1 in
		-v|--verbose)
			CONFIG_VERBOSE=0;
			shift
			;;
		-y|--no-interaction)
			CONFIG_NO_INTERACTION=0;
			shift;
			;;
		-V|--version)
			echo "$CONFIG_VERSION";
			exit $ERROR_CODE_OK
			;;
		-h|--help)
			usage
			exit $ERROR_CODE_OK
			;;
		--)
			shift
			break
			;;
		*)
			usage
			exit $ERROR_CODE_NORMAL
			;;
	esac
done

## Some Introduction
echo "Web-application deployer (c) 2012 Alexander Sergeychik aka OmeZ"
#echo "Contact with <alexander.sergeychik@gmail.com>" 
test $CONFIG_VERBOSE && echo "> working dir: $CONFIG_WORK_DIR"
test $CONFIG_VERBOSE && echo "> app dir: $CONFIG_APP_DIR"

# Laod required libraries
echo -n "Loading libraries... ";
. $CONFIG_APP_DIR/lib/errors.sh && echo -n "." || exit $ERROR_CODE_CORE;
. $CONFIG_APP_DIR/lib/system.sh && echo -n "." || exit $ERROR_CODE_CORE;
. $CONFIG_APP_DIR/lib/core.sh && echo -n "." || exit $ERROR_CODE_CORE;
. $CONFIG_APP_DIR/lib/backup.sh && echo -n "." || exit $ERROR_CODE_CORE;
. $CONFIG_APP_DIR/lib/releases.sh && echo -n "." || exit $ERROR_CODE_CORE;
echo " OK"

# Workflow start
if [ $# -lt 1 ]; then
	usage
	exit $ERROR_CODE_NORMAL	
fi

case $1 in
	init)
		init;
		init_backup;
		init_releases;
		;;
	validate)
		valiadte || echo "Structure is not valid"
		valiadte_backup || echo "Backup structure is not valid"
		valiadte_releases || echo "Releases structure is not valid"
		;;
	turn-on)
		turnon
		;;
	turn-off)
		turnoff
		;;
	switch)
		switch $2
		;;
	backup)
		backup
		;;
	rescue|fallback)
		rescue
		;;
	stabilize)
		stabilize
		;;
	*)
		echo "Unrecognized command '$1'"
		exit $ERROR_CODE_NORMAL
		;;
esac

## Done!
