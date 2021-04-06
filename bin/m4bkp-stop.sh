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

# Variable Globales

CONFIG_PATH=$HOME/.M4-BACKUP
CONFIG_FILE=$CONFIG_PATH/etc/m4backup.cfg
LOG_FILE=$CONFIG_PATH/temp/m4backup.log

# Funciones del programa

do_log() {
	fecha=`date '+%Y-%m-%d %H:%M'`
	echo "[$fecha]:$1" |& tee -a "$LOG_FILE"
}

# Paramos MEGA

mega-logout | tee -a "$LOG_FILE"
exitstatus=$?
if [ $exitstatus = 0 ]; then
    do_log "[INFO ] Servicio MEGA parado."
else
    do_log "[ERROR] $exitstatus al parar el servicio MEGA."
    exit 1
fi