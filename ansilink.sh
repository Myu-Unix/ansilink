#!/bin/bash
# Ansilink, get notified when ansible tasks are finished, automatically !
# Requires mpv to play a notification sound

# variables
VERSION="1.0"
DATADIR=$HOME/bin/ansilink/data
ICON=$DATADIR/link_alpha.png
SOUND=$DATADIR/WW_Get_Rupee.wav
PLAYER="mpv --really-quiet --volume=60"

function watch {
task_exist=0

while [ 1 ]
do
  # Look for the PID of an ansible-playbook run for a given "$1"
  # e.g : if your playbook is called "apache24.yml", put "apache24" (without quotes)
  if [ $task_exist -eq 0 ]
  then
    pid=$(ps a --sort=start_time | grep ansible-playbook | grep $1 | head -n 1 | sed 's/^ *//' | cut -d " " -f 1)
  # Could be improved (kill -0 ?) 
    if [ $pid != NULL 2> /dev/null ]
    then
      task_exist=1
    else  
  # No task exist for "$1", let's sleep
      sleep 2
    fi
  
  # If PID exist
  elif [ $task_exist -eq 1 ]
  then
  # Does PID still exist ?
    kill -0 $pid
    if [ $? -eq 0 ]
    then
      printf "$pid : task running\n"
      runtime=$((runtime+1))
      sleep 1
    else
        printf "task is over\n"
	$PLAYER $SOUND &
        notify-send "Hey, the \"$1\" playbook finished !" "~ $runtime secs" -i $ICON
        task_exist=0
        runtime=0
    fi
  fi
done
}

printf "Ansilink v $VERSION\n"
notify-send "Ansilink $VERSION started !" -i $ICON
printf "kill me with killall ansilink.sh\n"
printf "Spawning processes...\n"

# Add below the playbook keywords you want to be notified of :
# syntax : watch <keyword> &
watch frontend &
watch backend &
