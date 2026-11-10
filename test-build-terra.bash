#!/bin/bash

# Define a function to time commands
timeit() {
  local start=$(date +%s)
  "$@"  # Run the command passed to the function
  local end=$(date +%s)
  elapsed_s=$((end - start))
}
get_data() {
    cd $1
    if [[ $? -ne 0 ]] ; then exit 1; fi
    project=anda/devs/retrodebugger/pkg
    configs=()
    if [[ $# -gt 1 ]] ; then
        local array=( $* )
        for (( i=1; i < $# ; i++ )) ; do
            configs[$(($i - 1))]=${array[$i]}
        done
    fi
    if [[ ${#configs[*]} < 1 ]] ; then
        configs=(terra-44-x86_64 terra-45-x86_64 terra-rawhide-x86_64)
    fi
    count=${#configs[*]}
    times=()
}

if [[ $# -lt 1 ]] ; then
    echo "Please provide the path to the anda-packages repository as a parameter (minimum)!"
    echo
    echo "You may also provide as many mock-configurations as additional parameters."
    echo "(example mock configs: terra-44-x86_64, terra-45-x86_64, terra-rawhide-x86_64)"
    echo "(p.s.: these will be built, if no parameters are given by default)"
    exit 1
fi

get_data $*
echo "project folder: $project, number of mock-configs: $count → ${configs[*]}"
echo "starting: $(date)"
for (( i=0; i<$count; i++ )) ; do
    timeit anda build --mock-config ${configs[$i]} $project
    times[$i]=$elapsed_s
done
echo "finished: $(date)"
for (( i=0; i<$count; i++ )) ; do
    printf "config '${configs[$i]}' took %d:%02d Minutes.\n" $(( times[$i] / 60 )) $(( times[$i] % 60 ))
done
