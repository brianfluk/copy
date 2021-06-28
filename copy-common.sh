#!/bin/sh
# USAGE:
# Prerequisite: 
#       Install Mac OS X tools: https://github.com/morgant/tools-osx.
#       But if you really want to be dangerous... Go down and uncomment.
# Either
#       A) provide a copy-from (-c) and a paste_to folder (-v)
#       B) create a copy-config.txt in this same directory with format e.g.:
#           myconfig ~/folders/folder1 ~/folder2
#           then do `-f 'myconfig'`
# Notes: 
# - copy-config 
#       - only allows absolute path. 
#         (or technically relative, but no ~ or . Untested: $HOME variable.) 
#       - needs to end in newline if you want the last item


FILE=copy-config.txt
COPY_PATH_SUFFIX="the/path/to/dist/build"
PASTE_PATH_SUFFIX="node_modules/your/module"

drawline() {
    printf '\e[94m'
    printf %"$(tput cols)"s |tr " " "=";
    printf '\e[0m'
}
execute() {
    echo "\033[31m"
    trash ${paste_to}/${PASTE_PATH_SUFFIX}/*;
    # rm -rf ${paste_to}/${PASTE_PATH_SUFFIX}/*; # Only enable this if you can't get trash to work.
    cp -a ${copy_from}/${COPY_PATH_SUFFIX}/* ${paste_to}/${PASTE_PATH_SUFFIX};
    echo "\033[0m"
}
prompt() {
    echo "\n\n\033[33m\033[1mAre you sure you want to:\033[0m\033[33m\n - remove contents of $paste_to/$PASTE_PATH_SUFFIX/* \n - and replace with $paste_to/$PASTE_PATH_SUFFIX?\033[0m"
    while [ "$answer" != "y" ]
    do
        read answer;
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
            execute
        elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
            echo "aborted.";
            exit 1;
        else
            echo "Yes or no. (y/n)";
        fi
    done
}
donezo() { printf "\n\n\033[32m✅ Done.\033[0m\n"; }

drawline
printf "\nCopying common-components library into node_modules of app...\n\n";

while getopts ":c:v:f:" opt; do
    case "${opt}" in
        c)
            copy_from=${OPTARG}
            ;;
        v)
            paste_to=${OPTARG}
            ;;
        f)
            cv_config=${OPTARG}
            ;;
        *) 
            echo "\033[31m Invalid option -$OPTARG \033[0m" >&2
            ;;
    esac
done
shift $((OPTIND-1))

FOUND_CONFIG=0
if [ -z $copy_from ] || [ -z $paste_to ]; then
    if [ -z $cv_config ]; then
        echo "\033[31m Requires -c {copy_from_folder} and -v {paste_to_folder}\\033[0m\
        ,\or a -f {config from $FILE}"
        exit 3
    else
        echo "config: $cv_config\n"
        if test -f "${BASH_SOURCE%/*}/$FILE"; then
            echo "${BASH_SOURCE%/*}/$FILE exists"
            IFS=' '
            while read line; do
                read -ra LINE_PARTS  <<< ${line}
                if [ ${LINE_PARTS[0]} == ${cv_config} ]; then
                    copy_from=${LINE_PARTS[1]}
                    paste_to=${LINE_PARTS[2]}
                    FOUND_CONFIG=1;
                    echo "copy_from=\033[1m$copy_from\033[0m"
                    echo "paste_to=\033[1m$paste_to\033[0m"
                    break;
                fi
            done < ${BASH_SOURCE%/*}/$FILE
            echo "FOUND_CONFIG ${FOUND_CONFIG}"
            if [ ${FOUND_CONFIG} == 1 ]; then
                prompt
                donezo
                exit 0;
            fi
            echo "\033[31mNo config named ${cv_config} in ${FILE}\033[0m";    
            exit 0
        fi
        echo "\033[31mNo copy-config.txt found in this directory. Please make one.\033[0m";
        exit 3
    fi
fi

printf "\e[2mNow copying contents of $copy_from to replace contents of $paste_to ... \e[22m";

if [ -z $PASTE_PATH_SUFFIX ]; then
    echo '\n\033[31m PASTE_PATH_SUFFIX cannot be empty. Safety reasons.\033[0m\n';
    exit 3
fi

prompt
donezo