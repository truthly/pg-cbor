--
-- https://tools.ietf.org/html/rfc7049#appendix-A
--
BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

--   +------------------------------+------------------------------------+
--   | Diagnostic                   | Encoded                            |
--   +------------------------------+------------------------------------+
--   | 0                            | 0x00                               |
SELECT cbor.to_jsonb('\x00');
--   |                              |                                    |
--   | 1                            | 0x01                               |
SELECT cbor.to_jsonb('\x01');
--   |                              |                                    |
--   | 10                           | 0x0a                               |
SELECT cbor.to_jsonb('\x0a');
--   |                              |                                    |
--   | 23                           | 0x17                               |
SELECT cbor.to_jsonb('\x17');
--   |                              |                                    |
--   | 24                           | 0x1818                             |
SELECT cbor.to_jsonb('\x1818');
--   |                              |                                    |
--   | 25                           | 0x1819                             |
SELECT cbor.to_jsonb('\x1819');
--   |                              |                                    |
--   | 100                          | 0x1864                             |
SELECT cbor.to_jsonb('\x1864');
--   |                              |                                    |
--   | 1000                         | 0x1903e8                           |
SELECT cbor.to_jsonb('\x1903e8');
--   |                              |                                    |
--   | 1000000                      | 0x1a000f4240                       |
SELECT cbor.to_jsonb('\x1a000f4240');
--   |                              |                                    |
--   | 1000000000000                | 0x1b000000e8d4a51000               |
SELECT cbor.to_jsonb('\x1b000000e8d4a51000');
--   |                              |                                    |
--   | 18446744073709551615         | 0x1bffffffffffffffff               |
SELECT cbor.to_jsonb('\x1bffffffffffffffff');
--   |                              |                                    |
--   | 18446744073709551616         | 0xc249010000000000000000           |
SELECT cbor.to_jsonb('\xc249010000000000000000');
--   |                              |                                    |
--   | -18446744073709551616        | 0x3bffffffffffffffff               |
SELECT cbor.to_jsonb('\x3bffffffffffffffff');
--   |                              |                                    |
--   | -18446744073709551617        | 0xc349010000000000000000           |
SELECT cbor.to_jsonb('\xc349010000000000000000');
--   |                              |                                    |
--   | -1                           | 0x20                               |
SELECT cbor.to_jsonb('\x20');
--   |                              |                                    |
--   | -10                          | 0x29                               |
SELECT cbor.to_jsonb('\x29');
--   |                              |                                    |
--   | -100                         | 0x3863                             |
SELECT cbor.to_jsonb('\x3863');
--   |                              |                                    |
--   | -1000                        | 0x3903e7                           |
SELECT cbor.to_jsonb('\x3903e7');
--   |                              |                                    |
--   | 0.0                          | 0xf90000                           |
SELECT cbor.to_jsonb('\xf90000');
--   |                              |                                    |
--   | -0.0                         | 0xf98000                           |
SELECT cbor.to_jsonb('\xf98000');
--   |                              |                                    |
--   | 1.0                          | 0xf93c00                           |
SELECT cbor.to_jsonb('\xf93c00');
--   |                              |                                    |
--   | 1.1                          | 0xfb3ff199999999999a               |
SELECT cbor.to_jsonb('\xfb3ff199999999999a');
--   |                              |                                    |
--   | 1.5                          | 0xf93e00                           |
SELECT cbor.to_jsonb('\xf93e00');
--   |                              |                                    |
--   | 65504.0                      | 0xf97bff                           |
SELECT cbor.to_jsonb('\xf97bff');
--   |                              |                                    |
--   | 100000.0                     | 0xfa47c35000                       |
SELECT cbor.to_jsonb('\xfa47c35000');
--   |                              |                                    |
--   | 3.4028234663852886e+38       | 0xfa7f7fffff                       |
SELECT cbor.to_jsonb('\xfa7f7fffff');
--   |                              |                                    |
--   | 1.0e+300                     | 0xfb7e37e43c8800759c               |
SELECT cbor.to_jsonb('\xfb7e37e43c8800759c');
--   |                              |                                    |
--   | 5.960464477539063e-8         | 0xf90001                           |
SELECT cbor.to_jsonb('\xf90001');
--   |                              |                                    |
--   | 0.00006103515625             | 0xf90400                           |
SELECT cbor.to_jsonb('\xf90400');
--   |                              |                                    |
--   | -4.0                         | 0xf9c400                           |
SELECT cbor.to_jsonb('\xf9c400');
--   |                              |                                    |
--   | -4.1                         | 0xfbc010666666666666               |
SELECT cbor.to_jsonb('\xfbc010666666666666');
--   |                              |                                    |
--   | Infinity                     | 0xf97c00                           |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xf97c00');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | NaN                          | 0xf97e00                           |
SAVEPOINT nan;
SELECT cbor.to_jsonb('\xf97e00');
ROLLBACK TO nan;
--   |                              |                                    |
--   | -Infinity                    | 0xf9fc00                           |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xf9fc00');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | Infinity                     | 0xfa7f800000                       |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfa7f800000');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | NaN                          | 0xfa7fc00000                       |
SAVEPOINT nan;
SELECT cbor.to_jsonb('\xfa7fc00000');
ROLLBACK TO nan;
--   |                              |                                    |
--   | -Infinity                    | 0xfaff800000                       |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfaff800000');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | Infinity                     | 0xfb7ff0000000000000               |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfb7ff0000000000000');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | NaN                          | 0xfb7ff8000000000000               |
SAVEPOINT nan;
SELECT cbor.to_jsonb('\xfb7ff8000000000000');
ROLLBACK TO nan;
--   |                              |                                    |
--   | -Infinity                    | 0xfbfff0000000000000               |
SAVEPOINT infinity;
SELECT cbor.to_jsonb('\xfbfff0000000000000');
ROLLBACK TO infinity;
--   |                              |                                    |
--   | false                        | 0xf4                               |
SELECT cbor.to_jsonb('\xf4');
--   |                              |                                    |
--   | true                         | 0xf5                               |
SELECT cbor.to_jsonb('\xf5');
--   |                              |                                    |
--   | null                         | 0xf6                               |
SELECT cbor.to_jsonb('\xf6');
--   |                              |                                    |
--   | undefined                    | 0xf7                               |
SAVEPOINT undefined;
SELECT cbor.to_jsonb('\xf7');
ROLLBACK TO undefined;
--   |                              |                                    |
--   | simple(16)                   | 0xf0                               |
SELECT cbor.to_jsonb('\xf0');
--   |                              |                                    |
--   | simple(24)                   | 0xf818                             |
SAVEPOINT incorrect_simple;
SELECT cbor.to_jsonb('\xf818');
ROLLBACK TO incorrect_simple;
--   |                              |                                    |
--   | simple(255)                  | 0xf8ff                             |
SELECT cbor.to_jsonb('\xf8ff');
--   |                              |                                    |
--   | 0("2013-03-21T20:04:00Z")    | 0xc074323031332d30332d32315432303a |
--   |                              | 30343a30305a                       |
SELECT cbor.to_jsonb('\xc074323031332d30332d32315432303a30343a30305a');
--   |                              |                                    |
--   | 1(1363896240)                | 0xc11a514b67b0                     |
SELECT cbor.to_jsonb('\xc11a514b67b0');
--   |                              |                                    |
--   | 1(1363896240.5)              | 0xc1fb41d452d9ec200000             |
SELECT cbor.to_jsonb('\xc1fb41d452d9ec200000');
--   |                              |                                    |
--   | 23(h'01020304')              | 0xd74401020304                     |
SELECT cbor.to_jsonb('\xd74401020304');
--   |                              |                                    |
--   | 24(h'6449455446')            | 0xd818456449455446                 |
SELECT cbor.to_jsonb('\xd818456449455446');
--   |                              |                                    |
--   | 32("http://www.example.com") | 0xd82076687474703a2f2f7777772e6578 |
--   |                              | 616d706c652e636f6d                 |
SELECT cbor.to_jsonb('\xd82076687474703a2f2f7777772e6578616d706c652e636f6d');
--   |                              |                                    |
--   | h''                          | 0x40                               |
SELECT cbor.to_jsonb('\x40');
--   |                              |                                    |
--   | h'01020304'                  | 0x4401020304                       |
SELECT cbor.to_jsonb('\x4401020304');
--   |                              |                                    |
--   | ""                           | 0x60                               |
SELECT cbor.to_jsonb('\x60');
--   |                              |                                    |
--   | "a"                          | 0x6161                             |
SELECT cbor.to_jsonb('\x6161');
--   |                              |                                    |
--   | "IETF"                       | 0x6449455446                       |
SELECT cbor.to_jsonb('\x6449455446');
--   |                              |                                    |
--   | "\"\\"                       | 0x62225c                           |
SELECT cbor.to_jsonb('\x62225c');
--   |                              |                                    |
--   | "\u00fc"                     | 0x62c3bc                           |
SELECT cbor.to_jsonb('\x62c3bc');
--   |                              |                                    |
--   | "\u6c34"                     | 0x63e6b0b4                         |
SELECT cbor.to_jsonb('\x63e6b0b4');
--   |                              |                                    |
--   | "\ud800\udd51"               | 0x64f0908591                       |
SELECT cbor.to_jsonb('\x64f0908591');
--   |                              |                                    |
--   | []                           | 0x80                               |
SELECT cbor.to_jsonb('\x80');
--   |                              |                                    |
--   | [1, 2, 3]                    | 0x83010203                         |
SELECT cbor.to_jsonb('\x83010203');
--   |                              |                                    |
--   | [1, [2, 3], [4, 5]]          | 0x8301820203820405                 |
SELECT cbor.to_jsonb('\x8301820203820405');
--   |                              |                                    |
--   | [1, 2, 3, 4, 5, 6, 7, 8, 9,  | 0x98190102030405060708090a0b0c0d0e |
--   | 10, 11, 12, 13, 14, 15, 16,  | 0f101112131415161718181819         |
--   | 17, 18, 19, 20, 21, 22, 23,  |                                    |
--   | 24, 25]                      |                                    |
SELECT cbor.to_jsonb('\x98190102030405060708090a0b0c0d0e0f101112131415161718181819');
--   |                              |                                    |
--   | {}                           | 0xa0                               |
SELECT cbor.to_jsonb('\xa0');
--   |                              |                                    |
--   | {1: 2, 3: 4}                 | 0xa201020304                       |
SELECT cbor.to_jsonb('\xa201020304');
--   |                              |                                    |
--   | {"a": 1, "b": [2, 3]}        | 0xa26161016162820203               |
SELECT cbor.to_jsonb('\xa26161016162820203');
--   |                              |                                    |
--   | ["a", {"b": "c"}]            | 0x826161a161626163                 |
SELECT cbor.to_jsonb('\x826161a161626163');
--   |                              |                                    |
--   | {"a": "A", "b": "B", "c":    | 0xa5616161416162614261636143616461 |
--   | "C", "d": "D", "e": "E"}     | 4461656145                         |
SELECT cbor.to_jsonb('\xa56161614161626142616361436164614461656145');
--   |                              |                                    |
--   | (_ h'0102', h'030405')       | 0x5f42010243030405ff               |
SELECT cbor.to_jsonb('\x5f42010243030405ff');
--   |                              |                                    |
--   | (_ "strea", "ming")          | 0x7f657374726561646d696e67ff       |
SELECT cbor.to_jsonb('\x7f657374726561646d696e67ff');
--   |                              |                                    |
--   | [_ ]                         | 0x9fff                             |
SELECT cbor.to_jsonb('\x9fff');
--   |                              |                                    |
--   | [_ 1, [2, 3], [_ 4, 5]]      | 0x9f018202039f0405ffff             |
SELECT cbor.to_jsonb('\x9f018202039f0405ffff');
--   |                              |                                    |
--   | [_ 1, [2, 3], [4, 5]]        | 0x9f01820203820405ff               |
SELECT cbor.to_jsonb('\x9f01820203820405ff');
--   |                              |                                    |
--   | [1, [2, 3], [_ 4, 5]]        | 0x83018202039f0405ff               |
SELECT cbor.to_jsonb('\x83018202039f0405ff');
--   |                              |                                    |
--   | [1, [_ 2, 3], [4, 5]]        | 0x83019f0203ff820405               |
SELECT cbor.to_jsonb('\x83019f0203ff820405');
--   |                              |                                    |
--   | [_ 1, 2, 3, 4, 5, 6, 7, 8,   | 0x9f0102030405060708090a0b0c0d0e0f |
--   | 9, 10, 11, 12, 13, 14, 15,   | 101112131415161718181819ff         |
--   | 16, 17, 18, 19, 20, 21, 22,  |                                    |
--   | 23, 24, 25]                  |                                    |
SELECT cbor.to_jsonb('\x9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff');
--   |                              |                                    |
--   | {_ "a": 1, "b": [_ 2, 3]}    | 0xbf61610161629f0203ffff           |
SELECT cbor.to_jsonb('\xbf61610161629f0203ffff');
--   |                              |                                    |
--   | ["a", {_ "b": "c"}]          | 0x826161bf61626163ff               |
SELECT cbor.to_jsonb('\x826161bf61626163ff');
--   |                              |                                    |
--   | {_ "Fun": true, "Amt": -2}   | 0xbf6346756ef563416d7421ff         |
SELECT cbor.to_jsonb('\xbf6346756ef563416d7421ff');
--   +------------------------------+------------------------------------+

ROLLBACK;
