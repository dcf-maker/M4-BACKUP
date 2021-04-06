#!/bin/bash
new_path="/the/new/path"
sed -i "s%WLS_Home=.*%WLS_Home=$new_path%g" /home/amstrad/.M4-BACKUP/config2.cfg