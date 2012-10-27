#!/bin/bash -i
# Second, start a new window in the screen session using that identifier
#screen -RR #-S $SCREEN_ID

#screen -ls cron | grep -q '(\w*tached)' >&- || screen -dmS cron
#screen -S cron -X screen ping example.com

SESSION_NAME="system"
WINDOW_NAME=`date +%s%N`

screen -S $SESSION_NAME -X screen -t "$WINDOW_NAME" \
    || screen -dmS $SESSION_NAME -t "$WINDOW_NAME"
screen -S $SESSION_NAME -X other  # switch existing attached terminal back to its old window
screen -x -S $SESSION_NAME -p "$WINDOW_NAME"  # connect to new window

bold=`tput smso`
offbold=`tput rmso`
echo "${bold}WARNING: YOU ARE NO LONGER IN A SCREEN SESSION!"
