BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

SELECT cbor.to_jsonb('\x4cf09fa7acf09f909863626f72');

SAVEPOINT too_little_data;
SELECT cbor.to_jsonb('\x4cf09fa7acf09f909863626f');
ROLLBACK TO too_little_data;

SELECT cbor.to_jsonb('\x6cf09fa7acf09f909863626f72');

SAVEPOINT too_little_data;
SELECT cbor.to_jsonb('\x6cf09fa7acf09f909863626f');
ROLLBACK TO too_little_data;

ROLLBACK;
