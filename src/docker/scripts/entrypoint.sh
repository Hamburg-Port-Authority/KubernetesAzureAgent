#! /bin/bash

# parse options
while getopts f: flag
do
    case "${flag}" in
        f) filepath=${OPTARG};;
    esac
done

# print debug
echo "[x]====== 1.0 - calling setup scripts for further setup"
#add executable tag to all scripts in setup dir
find $filepath -name "*.sh" -exec chmod +x {} \;
#execute all scripts in setup dir
find $filepath -name "*.sh" -exec sh -c {} \;
# print debug
echo "[x]====== 2.0 - start azure client"
sh -c /azp/start.sh
