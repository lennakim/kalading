#!/bin/sh
# Abort commiting if unit tests failed. 
echo "Run pre-commit"
/usr/local/bin/rspec
# Check process return code
RESULT = $?
[ $RESULT -ne 0 ] && exit 1
exit 0

