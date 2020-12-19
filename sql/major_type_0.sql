BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

\set iterations 3

--
-- Positive/Unsigned integers from 0 to 23
-- major_type = 0 AND additional_type <= 23
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(lpad(to_hex((0::bit(3) || additional_type::bit(5))::bit(8)::integer),2,'0'),'hex')))
  =
  jsonb_agg(additional_type)
FROM (
  SELECT floor(random()*24)::integer AS additional_type
  FROM generate_series(1,:iterations)
) AS q;

--
-- Positive/Unsigned integers from 0 to 255 (2^8-1)
-- major_type = 0 AND additional_type = 24
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(lpad(to_hex((0::bit(3) || 24::bit(5) || data_value::bit(8))::bit(16)::integer),4,'0'),'hex')))
  =
  jsonb_agg(data_value)
FROM (
  SELECT floor(random()*256)::integer AS data_value
  FROM generate_series(1,:iterations)
) AS q;

--
-- Positive/Unsigned integers from 0 to 65535 (2^16-1)
-- major_type = 0 AND additional_type = 25
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(lpad(to_hex((0::bit(3) || 25::bit(5) || data_value::bit(16))::bit(24)::integer),6,'0'),'hex')))
  =
  jsonb_agg(data_value)
FROM (
  SELECT floor(random()*65536)::integer AS data_value
  FROM generate_series(1,:iterations)
) AS q;

--
-- Positive/Unsigned integers from 0 to 4294967295 (2^32-1)
-- major_type = 0 AND additional_type = 26
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(lpad(to_hex((0::bit(3) || 26::bit(5))::bit(8)::integer),2,'0') || lpad(to_hex(data_value::bit(32)::bigint),8,'0'),'hex')))
  =
  jsonb_agg(data_value)
FROM (
  SELECT floor(random()*4294967296)::bigint AS data_value
  FROM generate_series(1,:iterations)
) AS q;

--
-- Positive/Unsigned integers from 0 to 18446744073709551615 (2^64-1)
-- major_type = 0 AND additional_type = 27
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(lpad(to_hex((0::bit(3) || 27::bit(5))::bit(8)::integer),2,'0') || lpad(encode(cbor.numeric_to_bytea(data_value),'hex'),16,'0'),'hex')))
  =
  jsonb_agg(data_value)
FROM (
  SELECT (floor(random()*(2::numeric^64-1)))::numeric AS data_value
  FROM generate_series(1,:iterations)
) AS q;

ROLLBACK;
