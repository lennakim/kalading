#!/bin/bash
cd /mnt/kalading/db/data
./export_kalading.bat
cd ..
tar zcf $(date +%Y%m%d).tar.gz data/ 
scp $(date +%Y%m%d).tar.gz root@115.28.132.220:/root/dbbackup/kalading_db.tar.gz