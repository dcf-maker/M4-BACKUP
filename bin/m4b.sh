#!/bin/bash


CONFIG_PATH=$HOME/.M4-BACKUP                # Path folder application
CONFIG_FILE=$CONFIG_PATH/etc/config.cfg     # Path Config File
LOG_FILE=$CONFIG_PATH/temp/m4backup.log     # Path Log file
AMARILLO=$(tput setaf 11)                   # Color Yellow
VERDE=$(tput setaf 10)                      # Color Green
ROJO=$(tput setaf 9)                        # Color Red
BLANCO=$(tput sgr 0)                        # Color White
DELAY=3                                     # Number of seconds to display results

####################
# functions script #
####################


function do_cabecera() {
    clear
    echo $AMARILLO
    echo "$1" | boxes -d stone -p a15v0
    echo $BLANCO
}

function do_msg_ok() {
    clear
    echo $VERDE
    echo "$1" | boxes -d stone -p a15v0
    echo $BLANCO
}

function do_msg_err() {
    echo $ROJO
    echo "$1" | boxes -d stone -p a15v0
    echo $BLANCO
}

get_center(){
    COLS=$(tput cols)
    printf "%*s\n" "$(((${#1}+${COLS})/2))" "$1"
}

function do_about() {
    clear
    echo $(tput setaf 10)
    echo "\
Esta aplicación permite configurar un backup en la nube
para la M4 Motherboar. Para ello lo unico que necesita
es una cuenta MEGA.

M4-BACKUP v$VERSION
Copyright (C) 2021  Destroyer  dcf.maker@gmail.com
\
" | boxes -d stone -p a15v0
    echo " "
    read -p "Press any key to continue"
    echo "$(tput sgr 0)"
}

do_setProperty(){
    sed -i "s%$1=.*%$1=$2%g" $CONFIG_FILE
}

function do_user() {
    do_cabecera "Change User MEGA"
    read -p "User Mega (): " NUSER
    echo $NUSER
    sleep 3
}

function do_pass() {
    do_cabecera "Change Password MEGA"
    read -sp "Password Mega: " NPASSWORD
    echo $NPASSWORD
    sleep 3
}

function do_localpath() {
    do_cabecera "Change Local Path"
    read -p "Local Path Backup (): " NLOCALPAHT
    echo $NLOCALPAHT
    sleep 3
}

function do_remotepath() {
    do_cabecera "Change Remote Path (MEGA)"
    read -p "Remote Path MEGA (): " NREMOTEPAHT
    echo $NREMOTEPAHT
    sleep 3
}

function do_systemboot() {
    do_cabecera "System Boot"
    while true; do
    read -p "Start M4-Backup at system boot? (y/n) " yn
    case $yn in
        [Yy]* ) echo "dddd"
                sleep 3
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer y or n.";;
    esac
done
}

function do_menu_edit() {
    while true; do
        do_cabecera "Configurations M4-Backup"
        read -p " Do you want to modify the settings? (y/n) " yn
        case $yn in
            [Yy]* )
                while true; do
                clear
                echo $AMARILLO
                echo 'Configurations M4-Backup' | boxes -d stone -p a15v0
                echo $BLANCO
printf "\
$(cat menu.cfg) \
"
                read REPLY
                if [[ $REPLY =~ ^[0-5]$ ]]; then
                    case $REPLY in
                    1)  # User
                        do_user
                        continue
                        ;;
                    2)  # Password
                        do_pass
                        continue
                        ;;
                    3)  # Local Path
                        do_localpath
                        continue
                        ;;
                    4)  # Rempote path
                        do_remotepath
                        continue
                        ;;
                    5) # System Boot
                        do_systemboot
                        continue
                        ;;
                    0)
                        break
                        ;;
                    esac
                else
                    do_msg_err "Invalid entry"
                    sleep $DELAY
                fi
                done
                break;;
            [Nn]* ) break;;
            * ) echo "";;
        esac
    done
}

############################
#      Menu Principal      #
############################

while true; do
do_cabecera "M4-BACKUP (version 1.0)"
#echo 'M4-Backup Ver 1.0' | boxes -d stone -p a19v0
#figlet -f standard "M4-backup" | boxes -d stone -p a19v0

  cat << _EOF_
 Please Select:

    1. Configurations
    2. Start M4-Backup
    3. Stop M4-Backup
    4. About
    0. Quit

_EOF_

  read -p " Enter selection [0-4] > "

  if [[ $REPLY =~ ^[0-4]$ ]]; then
    case $REPLY in
      1)
        do_menu_edit
        continue
        ;;
      2)
        do_menu_edit
        continue
        ;;
      3)
        do_menu_edit
        continue
        ;;
      4)
        do_about
        continue
        ;;
      0)
        break
        ;;
    esac
  else
    echo $ROJO
    echo 'Invalid entry' | boxes -d stone -p a19v0
    echo $AMARILLO
    sleep $DELAY
  fi
done
clear
echo $VERDE
echo "Program terminated."
echo $BLANCO