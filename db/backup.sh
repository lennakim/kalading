#!/bin/bash
cd /home/ubuntu/kalading/db/data
./export_kalading.bat
cd ..
tar zcf $(date +%Y%m%d).tar.gz data/ 
