#!/bin/bash
mongoimport --db kalading_development --collection auto_brands --file auto_brands.json
mongoimport --db kalading_development --collection auto_models --file auto_models.json
mongoimport --db kalading_development --collection auto_submodels --file auto_submodels.json
mongoimport --db kalading_development --collection autos --file autos.json
mongoimport --db kalading_development --collection discounts --file discounts.json
mongoimport --db kalading_development --collection history_trackers --file history_trackers.json
mongoimport --db kalading_development --collection orders --file orders.json
mongoimport --db kalading_development --collection part_brands --file part_brands.json
mongoimport --db kalading_development --collection part_types --file part_types.json
mongoimport --db kalading_development --collection partbatches --file partbatches.json
mongoimport --db kalading_development --collection parts --file parts.json
mongoimport --db kalading_development --collection sequences --file sequences.json
mongoimport --db kalading_development --collection service_types --file service_types.json
mongoimport --db kalading_development --collection storehouses --file storehouses.json
mongoimport --db kalading_development --collection suppliers --file suppliers.json
mongoimport --db kalading_development --collection system.indexes --file system.indexes.json
mongoimport --db kalading_development --collection urlinfos --file urlinfos.json
mongoimport --db kalading_development --collection users --file users.json

