#!/bin/bash
userinput=""
echo "Press ESC key to quit"
# read a single character
while read -r -n1 key
do
# if input == ESC key
if [[ $key == $'\e' ]];
then
break;
fi
# Add the key to the variable which is pressed by the user.
userinput+=$key
done
printf "\nYou have typed : $userinput\n"