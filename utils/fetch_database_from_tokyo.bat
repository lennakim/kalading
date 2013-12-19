cd ../db
ssh ubuntu@54.248.126.168 "cd /mnt/kalading/db/data; rm -f *.json; ./export_kalading.bat; cd ..; tar zcf data.tar.gz data"
scp -i ../tokyo_new.ppk ubuntu@54.248.126.168:/mnt/kalading/db/data.tar.gz ./
bsdtar zxf data.tar.gz && cd .. && rake db:reseed && cd db/data/ && import_kalading.bat
