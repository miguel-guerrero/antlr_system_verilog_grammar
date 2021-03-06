#!/bin/bash
#set -o xtrace

if [ "$1" == "" ]; then
    echo "Usage: $0 [-python|-java] [-lisp|-json|-xml] filename ..."
    echo " "
    echo "Code binding to use is defined by the following:"
    echo "  -python : to use python binding"
    echo "  -java   : to use java binding - default"
    echo " "
    echo "Output format is defined by the following"
    echo "  -lisp   : to geerate lisp style output"
    echo "  -json   : to geerate JSON output"
    echo "  -xml    : to geerate XML output - default"
    echo " "
    exit 1
fi

top_bin=`dirname $0`
top=$top_bin/..
JAR=$(ls $top_bin/antlr*.jar)
export CLASSPATH="${top}/java:$JAR:$CLASSPATH"

pyth_binding=0
ext=xml
while [ "$1" != "" ]; do
    if [ "$1" == "-python" ]; then
        pyth_binding=1
    elif [ "$1" == "-java" ]; then
        pyth_binding=0
    elif [ "$1" == "-lisp" ]; then
        ext=lisp
    elif [ "$1" == "-json" ]; then
        ext=json
    elif [ "$1" == "-xml" ]; then
        ext=xml
    elif [ -f "$1" ]; then
        inpBase=`basename $1`
        postProc=post.$inpBase
        $top_bin/sv_preproc.sh $1 $postProc
        if [ $? == 0 ]; then
            if [ $pyth_binding == 0 ]; then
                echo "=== generating $inpBase.$ext with java binding ===" 
                if [ $ext == xml ]; then
                    java Testjson $postProc | $top_bin/j2x_filter.py > $inpBase.$ext 
                else
                    java Test$ext $postProc > $inpBase.$ext 
                fi
            else
                echo "=== generating $inpBase.$ext with python binding ===" 
                if [ $ext == xml ]; then
                    ${top}/python/TestSvVisitor.py $postProc /dev/stdout | \
                        $top_bin/j2x_filter.py > $inpBase.xml
                else
                    ${top}/python/TestSvVisitor.py $postProc $inpBase.$ext
                fi
            fi
        else
            exit 1
        fi
    else
        echo "# Warning: skipping $1, not found/not an option"
    fi

    shift
done
