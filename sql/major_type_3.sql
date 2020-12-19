BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

\set iterations 3
\set indefinite_items 3
\set max_chars 25000

--
-- Helper-functions to generate random UTF-8 encoded Unicode characters
--

CREATE OR REPLACE FUNCTION r(from_byte bit(8), to_byte bit(8))
RETURNS text
LANGUAGE sql AS $$
SELECT lpad(to_hex(from_byte::integer + floor(random() * (to_byte::integer - from_byte::integer + 1))::integer),2,'0')
$$;

CREATE OR REPLACE FUNCTION rand_char()
RETURNS char
LANGUAGE sql
AS $$
-- Valid UTF-8 byte ranges copied from:
-- https://lemire.me/blog/2018/05/09/how-quickly-can-you-check-that-a-string-is-valid-unicode-utf-8/
SELECT convert_from(decode(CASE floor(random()*9)::integer
WHEN 0 THEN r(x'01',x'7f')
WHEN 1 THEN r(x'c2',x'df')||r(x'80',x'bf')
WHEN 2 THEN r(x'e0',x'e0')||r(x'a0',x'bf')||r(x'80',x'bf')
WHEN 3 THEN r(x'e1',x'ec')||r(x'80',x'bf')||r(x'80',x'bf')
WHEN 4 THEN r(x'ed',x'ed')||r(x'80',x'9f')||r(x'80',x'bf')
WHEN 5 THEN r(x'ee',x'ef')||r(x'80',x'bf')||r(x'80',x'bf')
WHEN 6 THEN r(x'f0',x'f0')||r(x'90',x'bf')||r(x'80',x'bf')||r(x'80',x'bf')
WHEN 7 THEN r(x'f1',x'f3')||r(x'80',x'bf')||r(x'80',x'bf')||r(x'80',x'bf')
WHEN 8 THEN r(x'f4',x'f4')||r(x'80',x'8f')||r(x'80',x'bf')||r(x'80',x'bf')
END,'hex'),'utf8')
$$;

--
-- Since UTF-8 is at most 4 bytes per character,
-- the data_length boundaries for the tests
-- are like Byte strings (major type 2)
-- but divided by 4 and then floor()ed,
-- to ensure the randomly generated strings will fit.
--

--
-- Text strings up to 5 characters (<=23 bytes)
-- major_type = 3 AND additional_type <= 23
--
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((3::bit(3) || additional_type::bit(5))::bit(8)::integer),2,'0')
    ,'hex') || convert_to(text_string,'utf8')
  ))
  =
  jsonb_agg(text_string)
FROM (
  SELECT floor(random()*6)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(additional_type) ON TRUE;

--
-- Text strings up to 63 characters (<=255 bytes)
-- major_type = 3 AND additional_type = 24
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((3::bit(3) || 24::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(8)::integer),2,'0')
    ,'hex') || convert_to(text_string,'utf8')
  ))
  =
  jsonb_agg(text_string)
FROM (
  SELECT floor(random()*64)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(data_length) ON TRUE;

--
-- Text strings up to 16383 characters (<=65535 bytes)
-- major_type = 3 AND additional_type = 25
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((3::bit(3) || 25::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(16)::integer),4,'0')
    ,'hex') || convert_to(text_string,'utf8')
  ))
  =
  jsonb_agg(text_string)
FROM (
  SELECT floor(random()*16384)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(data_length) ON TRUE;

--
-- Text strings up to :max_chars
-- major_type = 3 AND additional_type = 26
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((3::bit(3) || 26::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(32)::bigint),8,'0')
    ,'hex') || convert_to(text_string,'utf8')
  ))
  =
  jsonb_agg(text_string)
FROM (
  SELECT floor(random()*:max_chars)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(data_length) ON TRUE;

--
-- Text strings up to :max_chars
-- major_type = 3 AND additional_type = 27
--
SELECT
  jsonb_agg(cbor.to_jsonb(
    decode(
      lpad(to_hex((3::bit(3) || 27::bit(5))::bit(8)::integer),2,'0')
      || lpad(to_hex(data_length::bit(64)::bigint),16,'0')
    ,'hex') || convert_to(text_string,'utf8')
  ))
  =
  jsonb_agg(text_string)
FROM (
  SELECT floor(random()*:max_chars)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(data_length) ON TRUE;

--
-- Indefinite Text string up to :max_chars
-- major_type = 3 AND additional_type = 31
--
SELECT
  jsonb_agg(cbor.to_jsonb(decode(
    lpad(to_hex((3::bit(3) || 31::bit(5))::bit(8)::integer),2,'0')
    || repeat(lpad(to_hex((3::bit(3) || 27::bit(5))::bit(8)::integer),2,'0')
              || lpad(to_hex(data_length::bit(64)::bigint),16,'0')
              || encode(convert_to(text_string,'utf8'),'hex'), :indefinite_items)
    || 'ff' /* Break Code */
  ,'hex')))
  =
  jsonb_agg(repeat(text_string,:indefinite_items))
FROM (
  SELECT floor(random()*:max_chars)::integer AS num_chars
  FROM generate_series(1,:iterations)
) AS q1
JOIN LATERAL (VALUES(
  repeat(rand_char(),num_chars)
)) AS q2(text_string) ON TRUE
JOIN LATERAL (VALUES(
  length(convert_to(text_string,'utf8'))
)) AS q3(data_length) ON TRUE;

ROLLBACK;
