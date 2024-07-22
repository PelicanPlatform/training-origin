#!/bin/bash

# sample-exec.sh: a short discovery job
printf "Start time: "; /bin/date
printf "Job is running on node: "; /bin/hostname
printf "Job running as user: "; /usr/bin/id
printf "Job is running in directory: "; /bin/pwd

printf "Contents of input.txt is "; cat input.txt
cat input.txt > output$1.txt
sleep 10
