#!/bin/bash
folderName=$1
program=$2
shift 2
arguments=$@
currentLocation=`pwd`
echo $folderName
echo $program
echo $arguments

cd $folderName
if [ -f "Makefile" ]
then #make file found
    make &> /dev/null
    if [ $? -eq 0 ]
    then #compilation successed
        compile="PASS"
        left=0
        valgrind --leak-check=full --error-exitcode=1 ./$program &>/dev/null
        if [ $? -eq 0 ]
        then
            memory="PASS"
            mid=0
        else
            memory="FAIL"
            mid=1
        fi

        valgrind --tool=helgrind --error-exitcode=1 ./$program &>/dev/null
        if [ $? -eq 0 ]
        then
            thread="PASS"
            right=0
        else
            thread="FAIL"
            right=1
        fi

    else #compilation failed
        compile="FAIL"
        memory="FAIL"
        thread="FAIL"
        left=1
        right=1
        mid=1

    fi
else #no make file found
    compile="FAIL"
    memory="FAIL"
    thread="FAIL"
    left=1
    right=1
    mid=1
fi

#print output
echo -e "Compilation \t Memory leaks \t thread race" 
echo -e "  "$compile"\t\t  "$memory"\t\t  "$thread
# exiting by number: 

math=$(($((4*$left)) + $((2*$mid)) + $((1*$right))))
cd $currentLocation
exit $math
