CREATE OR REPLACE FUNCTION cbor.next_item(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH
data_item_header(major_type,additional_type) AS (
  SELECT
    (get_byte(cbor,0) >> 5) &   '111'::bit(3)::integer,
     get_byte(cbor,0)       & '11111'::bit(5)::integer
),
calc_length_bytes(length_bytes) AS (
  SELECT
    NULLIF(LEAST(floor(2 ^ (additional_type - 24))::integer,16),16)
  FROM data_item_header
),
calc_data_value(data_value) AS (
  SELECT
    CASE
      WHEN additional_type <= 23 THEN
        additional_type::numeric
      WHEN additional_type BETWEEN 24 AND 27 THEN (
        SELECT
          floor(SUM(get_byte(cbor,byte_pos) * 2::numeric^(8*(length_bytes-byte_pos))))
        FROM calc_length_bytes
        CROSS JOIN generate_series(1,length_bytes) AS byte_pos
      )
    END
  FROM data_item_header
)
SELECT
  CASE
    WHEN major_type = 0 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 1 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(-1-data_value))::cbor.next_state
    WHEN major_type = 2 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(encode(substring(cbor,2+length_bytes,data_value::integer),encode_binary_format)))::cbor.next_state
    WHEN major_type = 2 AND additional_type  = 31 THEN cbor.next_indefinite_byte_string(substring(cbor,2), encode_binary_format)
    WHEN major_type = 3 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(convert_from(substring(cbor,2+length_bytes,data_value::integer),'utf8')))::cbor.next_state
    WHEN major_type = 3 AND additional_type  = 31 THEN cbor.next_indefinite_text_string(substring(cbor,2), encode_binary_format)
    WHEN major_type = 4 AND additional_type <= 27 THEN cbor.next_array(substring(cbor,2+length_bytes), data_value::integer, encode_binary_format)
    WHEN major_type = 4 AND additional_type  = 31 THEN cbor.next_indefinite_array(substring(cbor,2), encode_binary_format)
    WHEN major_type = 5 AND additional_type <= 27 THEN cbor.next_map(substring(cbor,2+length_bytes), data_value::integer, encode_binary_format)
    WHEN major_type = 5 AND additional_type  = 31 THEN cbor.next_indefinite_map(substring(cbor,2), encode_binary_format)
    WHEN major_type = 6 AND additional_type  = 2  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2), encode_binary_format) AS tag_item)
    WHEN major_type = 6 AND additional_type  = 3  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(-1-cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2), encode_binary_format) AS tag_item)
    WHEN major_type = 7 AND additional_type <= 19 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 20 THEN ROW(substring(cbor,2), pg_catalog.to_jsonb(false))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 21 THEN ROW(substring(cbor,2), pg_catalog.to_jsonb(true))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 22 THEN ROW(substring(cbor,2), 'null'::jsonb)::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 23 THEN cbor.raise('Decoding of Undefined not possible since since not part of JSON',NULL,NULL::cbor.next_state)
    WHEN major_type = 7 AND additional_type  = 24 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 25 THEN cbor.next_float_half(substring(cbor,2))
    WHEN major_type = 7 AND additional_type  = 26 THEN cbor.next_float_single(substring(cbor,2))
    WHEN major_type = 7 AND additional_type  = 27 THEN cbor.next_float_double(substring(cbor,2))
    ELSE cbor.raise('Decoding of CBOR type not implemented',json_build_object('major_type',major_type,'additional_type',additional_type),NULL::cbor.next_state)
  END::cbor.next_state
FROM data_item_header
CROSS JOIN calc_length_bytes
CROSS JOIN calc_data_value
$$;
