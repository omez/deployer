#!/bin/bash
# Errors and sussess messages


# Simple notification
function notification() {
	echo $1
}

# Success check message
function success() {
	echo "SUCCESS: $1"
}

# Warning, will not fail the script
function warning() {
	echo "WARNING: ${1:-"Unknown Error"}" 1>&2
}

# Fatal error, will fail the script
function error() {
	echo "ERROR: ${1:-"Unknown Error"}" 1>&2
	# Halt
	test $2 -eq 0 && exit $2 || exit 1;	
}

