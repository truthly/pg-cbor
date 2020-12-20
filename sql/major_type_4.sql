BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

\set iterations 3
\set max_array_test_items 100

--
-- Tiny random integers are used as array items in this test.
--

--
-- Array of up to 23 data items
-- major_type = 4 AND additional_type <= 23
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || additional_type::bit(5))::bit(8)::integer),2,'0')
      || cbor_hex
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*24)::integer AS additional_type
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,additional_type /* item count */)
  ) AS q3
) AS q2 ON TRUE;

--
-- Array of up to 255 data items
-- major_type = 4 AND additional_type = 24
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || 24::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(8)::integer),2,'0')
      || cbor_hex
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*256)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,data_length)
  ) AS q3
) AS q2 ON TRUE;

--
-- Array of up to :max_array_test_items data items
-- major_type = 4 AND additional_type = 25
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || 25::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(16)::integer),4,'0')
      || cbor_hex
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*:max_array_test_items)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,data_length)
  ) AS q3
) AS q2 ON TRUE;

--
-- Array of up to :max_array_test_items data items
-- major_type = 4 AND additional_type = 26
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || 26::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(32)::bigint),8,'0')
      || cbor_hex
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*:max_array_test_items)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,data_length)
  ) AS q3
) AS q2 ON TRUE;

--
-- Array of up to :max_array_test_items data items
-- major_type = 4 AND additional_type = 27
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || 27::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(64)::bigint),16,'0')
      || cbor_hex
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*:max_array_test_items)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,data_length)
  ) AS q3
) AS q2 ON TRUE;

--
-- Indefinite Array of up to :max_array_test_items data items
-- major_type = 4 AND additional_type = 31
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((4::bit(3) || 31::bit(5))::bit(8)::integer),2,'0')
      || cbor_hex
      || 'ff' /* Break Code */
    ,'hex')
  ))
  =
  jsonb_agg(expected_result)
FROM (
  SELECT floor(random()*:max_array_test_items)::integer AS data_length
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (
  SELECT
    string_agg(lpad(to_hex(tiny_integer),2,'0'),'' ORDER BY i) AS cbor_hex,
    jsonb_agg(tiny_integer ORDER BY i) AS expected_result
  FROM (
    SELECT
      ROW_NUMBER() OVER () AS i,
      floor(random()*24)::integer AS tiny_integer
    FROM generate_series(1,data_length)
  ) AS q3
) AS q2 ON TRUE;

ROLLBACK;
