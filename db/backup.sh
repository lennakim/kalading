#!/bin/bash
cd /mnt/kalading/db/data
./export_kalading.bat
cd ..
tar zcf $(date +%Y%m%d).tar.gz data/ 
