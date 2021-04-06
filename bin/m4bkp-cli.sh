#! /bin/bash

# This program is just an example of how to make a whiptail menu and some basic commands.
# Copyright (C) 2021  Destroyer  dcf.maker@gmail.com

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


clear

# Variables Globales

CONFIG_PATH=$HOME/.M4-BACKUP
CONFIG_FILE=$CONFIG_PATH/etc/m4backup.cfg
LOG_FILE=$CONFIG_PATH/temp/m4backup.log

# Funciones del programa
do_log() {
	fecha=`date '+%Y-%m-%d %H:%M'`
	echo "[$fecha]:$1" |& tee -a "$LOG_FILE"
}

do_about() {
whiptail --msgbox "\
Esta aplicación permite configurar un backup en la nube
para la M4 Motherboar. Para ello lo unico que necesita
es una cuenta MEGA.

M4-BACKUP v$VERSION
Copyright (C) 2021  Destroyer  dcf.maker@gmail.com\
" 15 70 1
}

do_setProperty(){
  sed -i "s%$1=.*%$1=$2%g" $CONFIG_FILE
}

function do_user() {
	USER=$(whiptail --inputbox --title "Usuario" "Usuario Mega?" 8 78 $USER 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		do_setProperty "USER" "$USER"
		do_pass
	else
		echo "User selected Cancel."
	fi
}

function do_pass() {
	PASSWORD=$(whiptail --passwordbox "Password Account Mega?" 8 78 $PASSWORD --title "Password" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		do_setProperty "PASSWORD" "$PASSWORD"
	else
		echo "User selected Cancel."
	fi
}

get_config() {
whiptail --yesno "\
Esta seguro de que desea modificar las configuraciones?

Usuario: $USER
Password *********
---------------------------------------------------------------
LocalPath: $LOCALPATH
RemotePath: $REMOTEPATH


\
" 15 70 1
}

function do_config {
	whiptail --yesno "\
Esta seguro de que desea modificar las configuraciones?

Usuario: $USER
Password *********
---------------------------------------------------------------
LocalPath: $LOCALPATH
RemotePath: $REMOTEPATH


\
" 15 70 1
   RET=$?
	if [ $RET -eq 0 ]; then
		LOCALPATH=$(whiptail --inputbox --title "Local Paht" "Path Local del que desea hacer Backup" 8 78 $LOCALPATH 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
			do_setProperty "LOCALPATH" "$LOCALPATH"
			REMOTEPATH=$(whiptail --inputbox --title "Local Paht" "Path MEGA donde desea dejar el backup" 8 78 $REMOTEPATH 3>&1 1>&2 2>&3)
			RET=$?
			if [ $RET = 0 ]; then
				do_setProperty "REMOTEPATH" "$REMOTEPATH"
			fi
		else
			echo "User selected Cancel."
		fi
	elif [ $RET -eq 1 ]; then
        return
	fi
}

function config_backup {
	{
	ctxt1=$(grep ctxt /proc/stat | awk '{print $2}')
        echo 50
	sleep 1
        ctxt2=$(grep ctxt /proc/stat | awk '{print $2}')
        ctxt=$(($ctxt2 - $ctxt1))
        result="Number os context switches in the last secound: $ctxt"
	echo $result > result
	} | whiptail --gauge "Getting data ..." 6 60 0
}

function stop_backup {
	mega-logout > temp000 &
	{
			i="0"
			while (true)
			do
				proc=$(ps aux | grep -v grep | grep -e "mega-login")
				if [[ "$proc" == "" ]]; then break; fi
				sleep 1
				echo $i
				i=$(expr $i + 1)
			done
			echo 100
			sleep 2
	} | whiptail --title "CPC-M4-BACKUP" --gauge "Parando Backup..." 8 78 0
	whiptail --textbox temp000 12 80
	[ -s temp000 ]
	echo --> $?
	rm temp000
}

function get_startM4BKP {
	[ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err

	mega-login $USER $PASSWORD >$CONFIG_PATH/err
    case $? in
        6)  
            pkill -f "mega-cmd-server"
            whiptail --title "M4-BACKUP - ERROR" --textbox "$CONFIG_PATH/err" 8 78
            [ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err
            return
        ;;
        0)
            whiptail --msgbox "M4-BACKUP Arrancado Correctamente" 8 78 1
            return
        ;;
        *)
            whiptail --title "M4-BACKUP - ERROR" --textbox "$CONFIG_PATH/err" 8 78
            [ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err
            return
        ;;
    esac
}

function get_stopM4BKP {
	[ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err
	mega-logout >$CONFIG_PATH/err 
	if [ $? -ne 0 ]; then
		whiptail --title "M4-BACKUP" --msgbox "ERROR: Se ha producido un error durante la parada de M4-BACKUP" 8 78 1
	else
        whiptail --msgbox "M4-BACKUP Parado Correctamente" 8 78 1
	fi
}

function start_backup {
	[ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err
	mega-login $LOAD_USER $LOAD_PASS >$CONFIG_PATH/err &
	{
			i="0"
			while (true)
			do
				proc=$(ps aux | grep -v grep | grep -e "mega-login")
				if [[ "$proc" == "" ]]; then break; fi
				sleep 1
				echo $i
				i=$(expr $i + 1)
			done
			echo 100
			sleep 2
	} | whiptail --title "M4-BACKUP" --gauge "Arrancando aplicacion..." 8 78 0
	if [ -f "$CONFIG_PATH/err" ]; then
		whiptail --title "M4-BACKUP - ERROR" --textbox "$CONFIG_PATH/err" 8 78
		[ -f "$CONFIG_PATH/err" ] || rm $CONFIG_PATH/err
		return
	else
		whiptail --msgbox "M4-BACKUP Arrancada Correctamente" 15 70 1
	fi
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
	source "${CONFIG_FILE}"
else
	do_log "[ERROR] El archivo de configuraciones no existe. Vuelva a reinstalar la aplicación"
	exit 1
fi

while [ 1 ]
do
CHOICE=$(whiptail --title "M4-BACKUP" --backtitle "M4-BACKUP - Copias de Seguridad Automaticas para M4 Motherboard" --cancel-button Salir --ok-button Selecionar --menu "Seleccione Opción" 16 100 9 \
	"1 Preferencias"  "Configuraciones de M4-BACKUP" \
	"2 Configuracion"  "Configurar M4-BACKUP"\
	"3 Arrancar Servicio" "Arrancar Aplicacion M4-BACKUP"\
	"4 Parar Servicio"  "Parar Aplicacion M4-BACKUP"\
	"5 Update"  "Actualizar M4-BACKUP" \
	"6 About" "Información de esta aplicación"  3>&2 2>&1 1>&3)

exit_status=$?
exec 3>&-
case $exit_status in
	$DIALOG_CANCEL)
		#clear
		echo "Program terminated."
		exit
	;;
	$DIALOG_ESC)
		#clear
		echo "Program aborted." >&2
		exit 1
	;;
esac

result=$(whoami)
case $CHOICE in
	1\ *) do_user ;;
	2\ *) do_config ;;
	3\ *) get_startM4BKP ;;
	4\ *) get_stopM4BKP ;;
	5\ *) display_user ;;
	6\ *) do_about ;;
esac
#whiptail --msgbox "$result" 20 78
done
#clear
exit