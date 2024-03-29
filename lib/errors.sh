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
	
	# hook execution (fallback) if present
	test $2 && hook $2 $3
	
	# Halt
	exit 1;	
}

