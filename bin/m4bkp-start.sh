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

# Variables Globales

CONFIG_PATH=$HOME/.M4-BACKUP
CONFIG_FILE=$CONFIG_PATH/etc/m4backup.cfg
LOG_FILE=$CONFIG_PATH/temp/m4backup.log

# Funciones del programa

do_log() {
	fecha=`date '+%Y-%m-%d %H:%M'`
	echo "[$fecha]:$1" |& tee -a "$LOG_FILE"
}

# Comprobamos si existe el fichero de propiedades

if [ ! -e "$CONFIG_FILE" ] ; then
    do_log "[ERROR] El archivo de configuraciones no existe en la ruta $CONFIG_FILE"
    exit 1
else
    source $CONFIG_FILE
    do_log "[INFO ] Cargamos configuraciones $CONFIG_FILE"
fi

# Arrancamos Mega

pkill -f "mega-cmd-server" # Matamos el servidor de MEGA por si estubiera bloqueando
mega-login $USER $PASSWORD
exitstatus=$?
if [ $exitstatus = 0 ]; then
    do_log "[INFO ] Servicio MEGA arrancado."
    sleep 1
    mega-sync $LOCALPATH $REMOTEPATH 
    RET=$?
    if [ $RET = 0 ]; then
        do_log "[INFO ] Sincronización MEGA arrancada."
        mega-sync | tee -a "$LOG_FILE"
    else
        do_log "[ERROR] $exitstatus al arrancar la sincronización."
        exit 1
    fi
else
    do_log "[ERROR] $exitstatus al arrancar el servicio MEGA."
    exit 1
fi