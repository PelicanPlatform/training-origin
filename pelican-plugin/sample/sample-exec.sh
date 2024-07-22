#!/bin/bash

JOBID=$1
INPUT=$2

# sample-exec.sh: a short discovery job
printf "Start time: "; /bin/date
printf "Job is running on node: "; /bin/hostname
printf "Job running as user: "; /usr/bin/id
printf "Job is running in directory: "; /bin/pwd

printf "Contents of $INPUT is "; cat $INPUT
cat $INPUT > output$JOBID.txt
sleep 10
