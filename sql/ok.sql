--
-- https://tools.ietf.org/html/rfc7049#appendix-A
--
BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

SELECT cbor.to_jsonb('\x00');
SELECT cbor.to_jsonb('\x01');
SELECT cbor.to_jsonb('\x0a');
SELECT cbor.to_jsonb('\x17');
SELECT cbor.to_jsonb('\x1818');
SELECT cbor.to_jsonb('\x1819');
SELECT cbor.to_jsonb('\x1864');
SELECT cbor.to_jsonb('\x1903e8');
SELECT cbor.to_jsonb('\x1a000f4240');
SELECT cbor.to_jsonb('\x1b000000e8d4a51000');
SELECT cbor.to_jsonb('\x1bffffffffffffffff');
SELECT cbor.to_jsonb('\xc249010000000000000000');
SELECT cbor.to_jsonb('\x3bffffffffffffffff');
SELECT cbor.to_jsonb('\xc349010000000000000000');
SELECT cbor.to_jsonb('\x20');
SELECT cbor.to_jsonb('\x29');
SELECT cbor.to_jsonb('\x3863');
SELECT cbor.to_jsonb('\x3903e7');
SELECT cbor.to_jsonb('\xf90000');
SELECT cbor.to_jsonb('\xf98000');
SELECT cbor.to_jsonb('\xf93c00');
SELECT cbor.to_jsonb('\xfb3ff199999999999a');
SELECT cbor.to_jsonb('\xf93e00');
SELECT cbor.to_jsonb('\xf97bff');
SELECT cbor.to_jsonb('\xfa47c35000');
SELECT cbor.to_jsonb('\xfa7f7fffff');
SELECT cbor.to_jsonb('\xfb7e37e43c8800759c');
SELECT cbor.to_jsonb('\xf90001');
SELECT cbor.to_jsonb('\xf90400');
SELECT cbor.to_jsonb('\xf9c400');
SELECT cbor.to_jsonb('\xfbc010666666666666');

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xf97c00');
ROLLBACK TO infinity;

SAVEPOINT nan;
SELECT cbor.to_jsonb('\xf97e00');
ROLLBACK TO nan;

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xf9fc00');
ROLLBACK TO infinity;

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfa7f800000');
ROLLBACK TO infinity;

SAVEPOINT nan;
SELECT cbor.to_jsonb('\xfa7fc00000');
ROLLBACK TO nan;

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfaff800000');
ROLLBACK TO infinity;

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfb7ff0000000000000');
ROLLBACK TO infinity;

SAVEPOINT nan;
SELECT cbor.to_jsonb('\xfb7ff8000000000000');
ROLLBACK TO nan;

SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfbfff0000000000000');
ROLLBACK TO infinity;

SELECT cbor.to_jsonb('\xf4');
SELECT cbor.to_jsonb('\xf5');
SELECT cbor.to_jsonb('\xf6');

SAVEPOINT undefined;
SELECT cbor.to_jsonb('\xf7');
ROLLBACK TO undefined;

SELECT cbor.to_jsonb('\xf0');
SELECT cbor.to_jsonb('\xf818');
SELECT cbor.to_jsonb('\xf8ff');

SAVEPOINT not_part_of_json;
SELECT cbor.to_jsonb('\xc074323031332d30332d32315432303a30343a30305a');
ROLLBACK TO not_part_of_json;

SAVEPOINT not_part_of_json;
SELECT cbor.to_jsonb('\xc11a514b67b0');
ROLLBACK TO not_part_of_json;

SAVEPOINT not_part_of_json;
SELECT cbor.to_jsonb('\xc1fb41d452d9ec200000');
ROLLBACK TO not_part_of_json;

SAVEPOINT not_part_of_json;
SELECT cbor.to_jsonb('\xd74401020304');
ROLLBACK TO not_part_of_json;

SAVEPOINT not_implemented;
SELECT cbor.to_jsonb('\xd818456449455446');
ROLLBACK TO not_implemented;

SAVEPOINT not_part_of_json;
SELECT cbor.to_jsonb('\xd82076687474703a2f2f7777772e6578616d706c652e636f6d');
ROLLBACK TO not_part_of_json;

SELECT cbor.to_jsonb('\x40');
SELECT cbor.to_jsonb('\x4401020304');
SELECT cbor.to_jsonb('\x60');
SELECT cbor.to_jsonb('\x6161');
SELECT cbor.to_jsonb('\x6449455446');
SELECT cbor.to_jsonb('\x62225c');
SELECT cbor.to_jsonb('\x62c3bc');
SELECT cbor.to_jsonb('\x63e6b0b4');
SELECT cbor.to_jsonb('\x64f0908591');
SELECT cbor.to_jsonb('\x80');
SELECT cbor.to_jsonb('\x83010203');
SELECT cbor.to_jsonb('\x8301820203820405');
SELECT cbor.to_jsonb('\x98190102030405060708090a0b0c0d0e0f101112131415161718181819');
SELECT cbor.to_jsonb('\xa0');
SELECT cbor.to_jsonb('\xa201020304');
SELECT cbor.to_jsonb('\xa26161016162820203');
SELECT cbor.to_jsonb('\x826161a161626163');
SELECT cbor.to_jsonb('\xa56161614161626142616361436164614461656145');
SELECT cbor.to_jsonb('\x5f42010243030405ff');
SELECT cbor.to_jsonb('\x7f657374726561646d696e67ff');
SELECT cbor.to_jsonb('\x9fff');
SELECT cbor.to_jsonb('\x9f018202039f0405ffff');
SELECT cbor.to_jsonb('\x9f01820203820405ff');
SELECT cbor.to_jsonb('\x83018202039f0405ff');
SELECT cbor.to_jsonb('\x83019f0203ff820405');
SELECT cbor.to_jsonb('\x9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff');
SELECT cbor.to_jsonb('\xbf61610161629f0203ffff');
SELECT cbor.to_jsonb('\x826161bf61626163ff');
SELECT cbor.to_jsonb('\xbf6346756ef563416d7421ff');

ROLLBACK;
