#!/bin/bash
echo "Web-application deployer (c) 2012 Alexander Sergeychik aka OmeZ"
#echo "Contact with <alexander.sergeychik@gmail.com>" 

CONFIG_APP_DIR=`dirname $0`
CONFIG_WORK_DIR=`pwd`

echo -n "Loading libraries ";
`. $CONFIG_APP_DIR/lib/errors.sh` && echo -n "." || exit 1;
echo " loaded"


