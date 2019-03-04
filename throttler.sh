#!/bin/bash
cmd=$1
src=$2
dst=$3

threshold=7500

while true
do
	time_wait=`netstat -nat | awk '{print $6}' | sort | uniq -c | sort -n | grep TIME_WAIT | awk '{print $1}'`
	if [[ "$time_wait"  -gt $threshold ]]
	then
		echo "Threshold exceeded."
		if pgrep -x "gsutil" > /dev/null
		then
			echo "a process is running, killing it..."
			ps -ef | grep 'gsutil' | grep -v grep | awk '{print $2}' | xargs -r kill -9
		fi

		sleep 5
	else
		echo "Threshold safe."
		if ! pgrep -x "gsutil" > /dev/null
		then
			echo "No process running, run it..."
			eval "nohup gsutil -m $1 $2 $3 &"
			sleep 5
		fi

	fi
	sleep 5
done
