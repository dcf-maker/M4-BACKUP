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
CONFIG_FILE=$CONFIG_PATH/etc/m4bs.cfg
LOG_FILE=$CONFIG_PATH/temp/m4bs.log

# Funciones del programa

function do_log() {
	fecha=`date '+%Y-%m-%d %H:%M'`
	echo "[$fecha]:$1" |& tee -a "$LOG_FILE"
}

function do_stop{
  mega-logout
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      do_log "[INFO ] Servicio MEGA parado."
  else
      do_log "[ERROR] $exitstatus al parar el servicio MEGA."
      exit 1
  fi
}

# Comprobamos si existe el fichero de propiedades

if [ ! -e "$CONFIG_FILE" ] ; then
    do_log "[ERROR] El archivo de configuraciones no existe en la ruta $CONFIG_FILE"
    exit 1
else
    source $CONFIG_FILE
    #do_log "[INFO ] Cargamos configuraciones $CONFIG_FILE"
fi

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

OPTS=`getopt -o thoi: --long start,stop,help,ip-m4: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then usage; fi

echo "$OPTS"
eval set -- "$OPTS"

while true; do
  case "$1" in
    -t | --start ) 
        echo "start"; shift ;;
    -h | --help )  
        usage; shift ;;
    -o | --stop ) 
        do_stop; shift ;;
    -i | --ip-m4 ) 
        echo "$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) echo "dddd"; break ;;
  esac
done

exit
