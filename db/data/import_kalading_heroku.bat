#!/bin/bash
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection auto_brands --file auto_brands.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection auto_models --file auto_models.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection auto_submodels --file auto_submodels.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection autos --file autos.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection discounts --file discounts.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection history_trackers --file history_trackers.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection orders --file orders.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection part_brands --file part_brands.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection part_types --file part_types.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection partbatches --file partbatches.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection parts --file parts.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection sequences --file sequences.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection service_types --file service_types.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection storehouses --file storehouses.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection suppliers --file suppliers.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection system.indexes --file system.indexes.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection urlinfos --file urlinfos.json
mongoimport --host paulo.mongohq.com:10015 -u nanami -pNetworkeasy1979 --db kalading --collection users --file users.json

