#!/bin/bash
DIRVIRTPYTHON='.env'
source $DIRVIRTPYTHON/bin/activate
echo "`id`"
python3 ./laguntest.py $1
deactivate


