#!/bin/bash


CONFIG_PATH=$HOME/.M4-BACKUP                # Path folder application
CONFIG_FILE=$CONFIG_PATH/etc/m4b.cfg        # Path Config File
LOG_FILE=$CONFIG_PATH/temp/m4b.log          # Path Log file
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=15
WIDTH=50

####################
# functions script #
####################

do_log() {
	fecha=`date '+%Y-%m-%d %H:%M'`
	#echo "[$fecha]:$1" |& tee -a "$LOG_FILE"
  echo "[$fecha]:$1" >> "$LOG_FILE"
}

get_center(){
    COLS=$(tput cols)
    printf "%*s\n" "$(((${#1}+${COLS})/2))" "$1"
}

function do_about() {
    dialog --title "About" \
  --no-collapse \
  --msgbox "\
Esta aplicación permite configurar un backup en la nube
para la M4 Motherboar. Para ello lo unico que necesita
es una cuenta MEGA.

M4-BACKUP v$VERSION
Copyright (C) 2021  Destroyer  dcf.maker@gmail.com
\
" 0 0
}

do_setProperty(){
    sed -i "s%$1=.*%$1=$2%g" $CONFIG_FILE
}

function do_user() {
  USER=$(\
    dialog --title "User MEGA" \
          --inputbox "Enter the user Mega:" 8 60 $USER \
    3>&1 1>&2 2>&3 3>&- \
  )
  do_setProperty "USER" "$USER"
}

function do_pass() {
  PASSWORD=$(\
    dialog --title "Password MEGA" \
    --insecure \
    --passwordbox "Enter the password Mega:" 8 60 $PASSWORD \
    3>&1 1>&2 2>&3 3>&- \
  )
  do_setProperty "USER" "$PASSWORD"
}

function do_localpath() {
  LOCALPATH=$(\
    dialog --title "Local Path" \
    --inputbox "Enter the local path:" 8 60 $LOCALPATH \
    3>&1 1>&2 2>&3 3>&- \
  )
  do_setProperty "LOCALPATH" "$LOCALPATH"
}

function do_remotepath() {
  REMOTEPATH=$(\
    dialog --title "Remote Path" \
    --inputbox "Enter the remote path (MEGA):" 8 60 $REMOTEPATH \
    3>&1 1>&2 2>&3 3>&- \
  )
  do_setProperty "REMOTEPATH" "$REMOTEPATH"
}

function do_systemboot() {
  dialog --title "Boot System" \
  --yesno "Start M4-Backup at system boot?" 8 60
  response=$?
  case $response in
    0) do_setProperty "STARTBOOT" "yes";;
    1) do_setProperty "STARTBOOT" "no";;
  esac
}

display_result() {
  dialog --title "$1" \
  --no-collapse \
  --msgbox "$2" 0 0
}

do_display_configurations(){
  SALIDA=$(cat $CONFIG_FILE | sed "s/PASSWORD=$PASSWORD/PASSWORD=******/gi")
  dialog --title " Configurations " \
  --no-collapse \
  --msgbox "$SALIDA" 15 30
}

do_menu_principal(){
  while true; do
    exec 3>&1
    selection=$(dialog \
    --backtitle "M4-Backup v$VERSION - Backup Online M4 Motherboard" \
    --title "  M4-BACKUP Application  " \
    --clear \
    --cancel-label "Exit" \
    --menu "" $HEIGHT $WIDTH 6 \
    "1" "Display Information" \
    "2" "Configurations" \
    "3" "Start M4-Backup" \
    "4" "Stop M4-Backup" \
    "5" "About" 2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
        clear
        exit;;
      $DIALOG_ESC)
        clear
        exit 1
      ;;
    esac
    case $selection in
      0 )clear;;
      1 )display_result "System Information";;
      2 )do_menu_configurations;;
      3 )do_menu_configurations;;
      4 )do_menu_configurations;;
      5 )
        do_about;;
    esac
  done
}

do_menu_configurations(){
  while true; do
    exec 3>&1
    selection=$(dialog \
    --backtitle "M4-Backup v$VERSION - Backup Online M4 Motherboard" \
    --title "  Configurations  " \
    --clear \
    --cancel-label "Exit" \
    --menu "" $HEIGHT $WIDTH 6 \
    "1" "Display Configurations" \
    "2" "User MEGA" \
    "3" "Password MEGA" \
    "4" "Local Path" \
    "5" "Remote Path (MEGA)" \
    "6" "System Reboot" 2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
        break;;
      $DIALOG_ESC)
        break;;
    esac
    case $selection in
      0 )clear;;
      1 )do_display_configurations "ddfdf";;
      2 )do_user;;
      3 )do_pass;;
      4 )do_localpath;;
      5 )do_remotepath;;
      6 )
        do_systemboot;;
    esac
  done
}


#####################################################
#           MENU PRINCIPAL APLICACION               #
#####################################################

# Cargamos fichero de propiedades y version

if [ -f "${CONFIG_FILE}" ]; then
	source "${CONFIG_FILE}"
else
	do_log "[ERROR] El archivo de configuraciones no existe. Vuelva a reinstalar la aplicación"
	exit 1
fi

if [ -f "${CONFIG_PATH}/var/version" ]; then
	source "${CONFIG_PATH}/var/version"
else
	VERSION="0.0"
fi


do_menu_principal

clear
