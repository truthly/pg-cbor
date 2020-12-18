CREATE OR REPLACE FUNCTION cbor.next_item(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
SELECT
  CASE
    WHEN major_type = 0 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 1 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(-1-data_value))::cbor.next_state
    WHEN major_type = 2 AND additional_type <= 26 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(encode(substring(cbor,2+length_bytes,data_value::integer),'hex')))::cbor.next_state
    WHEN major_type = 2 AND additional_type  = 31 THEN cbor.next_indefinite_byte_string(substring(cbor,2))
    WHEN major_type = 3 AND additional_type <= 26 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(convert_from(substring(cbor,2+length_bytes,data_value::integer),'utf8')))::cbor.next_state
    WHEN major_type = 3 AND additional_type  = 31 THEN cbor.next_indefinite_text_string(substring(cbor,2))
    WHEN major_type = 4 AND additional_type <= 26 THEN cbor.next_array(substring(cbor,2+length_bytes), data_value::integer)
    WHEN major_type = 4 AND additional_type  = 31 THEN cbor.next_indefinite_array(substring(cbor,2))
    WHEN major_type = 5 AND additional_type <= 26 THEN cbor.next_map(substring(cbor,2+length_bytes), data_value::integer)
    WHEN major_type = 5 AND additional_type  = 31 THEN cbor.next_indefinite_map(substring(cbor,2))
    WHEN major_type = 6 AND additional_type  = 2  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2)) AS tag_item)
    WHEN major_type = 6 AND additional_type  = 3  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(-1-cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2)) AS tag_item)
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
  END
FROM (VALUES(
  -- major_type:
  (get_byte(cbor,0)>>5)&'111'::bit(3)::integer,
  -- additional_type:
  get_byte(cbor,0)&'11111'::bit(5)::integer
  )) AS data_item_header(major_type, additional_type)
JOIN LATERAL (VALUES(
  CASE WHEN additional_type <= 23 THEN 0
       WHEN additional_type  = 24 THEN 1
       WHEN additional_type  = 25 THEN 2
       WHEN additional_type  = 26 THEN 4
       WHEN additional_type  = 27 THEN 8
  END,
  CASE WHEN additional_type <= 23 THEN
         additional_type::numeric
       WHEN additional_type  = 24 THEN
         -- uint8_t:
         get_byte(cbor,1)::numeric
       WHEN additional_type  = 25 THEN
         -- uint16_t:
         ((get_byte(cbor,1)<<8) +
           get_byte(cbor,2))::numeric
       WHEN additional_type  = 26 THEN
         -- uint32_t:
         ((get_byte(cbor,1)::bigint<<24) +
          (get_byte(cbor,2)::bigint<<16) +
          (get_byte(cbor,3)::bigint<<8) +
           get_byte(cbor,4)::bigint)::numeric
       WHEN additional_type  = 27 THEN
         -- uint64_t:
         floor((get_byte(cbor,1)*2::numeric^56) +
               (get_byte(cbor,2)*2::numeric^48) +
               (get_byte(cbor,3)*2::numeric^40) +
               (get_byte(cbor,4)*2::numeric^32) +
               (get_byte(cbor,5)*2::numeric^24) +
               (get_byte(cbor,6)*2::numeric^16) +
               (get_byte(cbor,7)*2::numeric^8) +
                get_byte(cbor,8)::numeric)
  END
)) AS additional_type_meaning(length_bytes, data_value) ON TRUE
$$;
