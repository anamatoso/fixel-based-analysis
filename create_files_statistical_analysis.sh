#!/bin/bash
set -e

subject=$1

group=${subject:4:7}
cycle=${subject:19}

if [ $group == "control" ]; then
    c="1"
    p="0"
else
    c="0"
    p="1"
fi

if [ $cycle == "midcycle" ] || [ $cycle == "interictal" ]; then
    c1="1"
    c2="0"
else
    c1="0"
    c2="1"
fi


printf "1 ${c} ${p} ${c1} ${c2}\n" >> design_matrix.txt
printf "template/fd/${subject}.mif\n" >> files_fd.txt
printf "template/fdc/${subject}.mif\n" >> files_fdc.txt
printf "template/log_fc/${subject}.mif\n" >> files_log_fc.txt