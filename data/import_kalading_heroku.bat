#!/bin/bash
collections=(autos auto_brands auto_models auto_submodels cities discounts history_trackers maintains motoroil_groups orders part_brands part_types partbatches parts sequences service_types storehouses suppliers system.indexes urlinfos tool_records tool_types user_types users videos)
for i in ${collections[@]}; do mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection ${i} --file ${i}.tar.gz; done;
