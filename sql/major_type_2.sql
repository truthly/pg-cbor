BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

\set iterations 3
\set indefinite_items 3
\set max_bytes 100000

--
-- Byte strings from 0 to 23 bytes
-- major_type = 2 AND additional_type <= 23
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || additional_type::bit(5))::bit(8)::integer),2,'0')
      || byte_string
    ,'hex')
  ))
  =
  jsonb_agg(byte_string)
FROM (
  SELECT floor(random()*24)::integer AS additional_type
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::integer),2,'0'),additional_type /* data length */)
)) AS q2(byte_string) ON TRUE;

--
-- Byte strings from 0 to 255 bytes
-- major_type = 2 AND additional_type = 24
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || 24::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(8)::integer),2,'0')
      || byte_string
    ,'hex')
  ))
  =
  jsonb_agg(byte_string)
FROM (
  SELECT floor(random()*256)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::integer),2,'0'),data_length)
)) AS q2(byte_string) ON TRUE;

--
-- Byte strings from 0 to 65535 bytes
-- major_type = 2 AND additional_type = 25
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || 25::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(16)::integer),4,'0')
      || byte_string
    ,'hex')
  ))
  =
  jsonb_agg(byte_string)
FROM (
  SELECT floor(random()*65536)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::integer),2,'0'),data_length)
)) AS q2(byte_string) ON TRUE;

--
-- Byte strings up to :max_bytes bytes
-- major_type = 2 AND additional_type = 26
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || 26::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(32)::bigint),8,'0')
      || byte_string
    ,'hex')
  ))
  =
  jsonb_agg(byte_string)
FROM (
  SELECT floor(random()*:max_bytes)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::int),2,'0'),data_length)
)) AS q2(byte_string) ON TRUE;

--
-- Byte strings up to :max_bytes bytes
-- major_type = 2 AND additional_type = 27
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || 27::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(64)::bigint),16,'0')
      || byte_string
    ,'hex')
  ))
  =
  jsonb_agg(byte_string)
FROM (
  SELECT floor(random()*:max_bytes)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::int),2,'0'),data_length)
)) AS q2(byte_string) ON TRUE;

--
-- Indefinite Byte strings up to :max_bytes bytes
-- major_type = 2 AND additional_type = 31
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((2::bit(3) || 31::bit(5))::bit(8)::integer),2,'0')
      || repeat(lpad(to_hex((2::bit(3) || 27::bit(5))::bit(8)::integer),2,'0')
                || lpad(to_hex(data_length::bit(64)::bigint),16,'0')
                || byte_string, :indefinite_items)
      || 'ff' /* Break Code */
    ,'hex')
  ))
  =
  jsonb_agg(repeat(byte_string,:indefinite_items))
FROM (
  SELECT floor(random()*:max_bytes)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q
JOIN LATERAL (VALUES(
  repeat(lpad(to_hex(floor(random()*256)::int),2,'0'),data_length)
)) AS q2(byte_string) ON TRUE;

ROLLBACK;
