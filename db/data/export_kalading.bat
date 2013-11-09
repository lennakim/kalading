#!/bin/bash
mongoexport --db kalading_development --collection auto_brands --out auto_brands.json
mongoexport --db kalading_development --collection auto_models --out auto_models.json
mongoexport --db kalading_development --collection auto_submodels --out auto_submodels.json
mongoexport --db kalading_development --collection autos --out autos.json
mongoexport --db kalading_development --collection discounts --out discounts.json
mongoexport --db kalading_development --collection history_trackers --out history_trackers.json
mongoexport --db kalading_development --collection orders --out orders.json
mongoexport --db kalading_development --collection part_brands --out part_brands.json
mongoexport --db kalading_development --collection part_types --out part_types.json
mongoexport --db kalading_development --collection partbatches --out partbatches.json
mongoexport --db kalading_development --collection parts --out parts.json
mongoexport --db kalading_development --collection sequences --out sequences.json
mongoexport --db kalading_development --collection service_types --out service_types.json
mongoexport --db kalading_development --collection storehouses --out storehouses.json
mongoexport --db kalading_development --collection suppliers --out suppliers.json
mongoexport --db kalading_development --collection system.indexes --out system.indexes.json
mongoexport --db kalading_development --collection urlinfos --out urlinfos.json
mongoexport --db kalading_development --collection users --out users.json

