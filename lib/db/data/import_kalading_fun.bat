#!/bin/bash
mongoimport --db kalading_fun --collection auto_brands --file auto_brands.json
mongoimport --db kalading_fun --collection auto_models --file auto_models.json
mongoimport --db kalading_fun --collection auto_submodels --file auto_submodels.json
mongoimport --db kalading_fun --collection autos --file autos.json
mongoimport --db kalading_fun --collection discounts --file discounts.json
mongoimport --db kalading_fun --collection history_trackers --file history_trackers.json
mongoimport --db kalading_fun --collection orders --file orders.json
mongoimport --db kalading_fun --collection part_brands --file part_brands.json
mongoimport --db kalading_fun --collection part_types --file part_types.json
mongoimport --db kalading_fun --collection partbatches --file partbatches.json
mongoimport --db kalading_fun --collection parts --file parts.json
mongoimport --db kalading_fun --collection sequences --file sequences.json
mongoimport --db kalading_fun --collection service_types --file service_types.json
mongoimport --db kalading_fun --collection storehouses --file storehouses.json
mongoimport --db kalading_fun --collection suppliers --file suppliers.json
mongoimport --db kalading_fun --collection system.indexes --file system.indexes.json
mongoimport --db kalading_fun --collection urlinfos --file urlinfos.json
mongoimport --db kalading_fun --collection users --file users.json

