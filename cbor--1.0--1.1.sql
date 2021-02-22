-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cbor" to load this file. \quit

CREATE OR REPLACE FUNCTION cbor.major_type_2(
cbor bytea,
encode_binary_format text,
additional_type integer,
length_bytes integer,
data_value numeric
)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
BEGIN
IF additional_type <= 27 THEN
  IF length(cbor) - 1 - length_bytes < data_value THEN
    RAISE EXCEPTION 'too little data';
  END IF;
  RETURN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(cbor.encode(substring(cbor,2+length_bytes,data_value::integer),encode_binary_format)));
ELSIF additional_type = 31 THEN
  RETURN cbor.next_indefinite_byte_string(substring(cbor,2), encode_binary_format);
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 2, additional_type;
END IF;
END;
$$;

CREATE OR REPLACE FUNCTION cbor.major_type_3(
cbor bytea,
encode_binary_format text,
additional_type integer,
length_bytes integer,
data_value numeric
)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
BEGIN
IF additional_type <= 27 THEN
  IF length(cbor) - 1 - length_bytes < data_value THEN
    RAISE EXCEPTION 'too little data';
  END IF;
  RETURN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(convert_from(substring(cbor,2+length_bytes,data_value::integer),'utf8')));
ELSIF additional_type = 31 THEN
  RETURN cbor.next_indefinite_text_string(substring(cbor,2), encode_binary_format);
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 3, additional_type;
END IF;
END;
$$;

CREATE OR REPLACE FUNCTION cbor.next_item(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
DECLARE
major_type constant integer := (get_byte(cbor,0) >> 5) & '111'::bit(3)::integer;
additional_type constant integer :=  get_byte(cbor,0) & '11111'::bit(5)::integer;
length_bytes constant integer := 8 >> (27 - additional_type);
data_value numeric := 0;
BEGIN
IF additional_type <= 23 THEN
  data_value := additional_type::numeric;
ELSIF additional_type BETWEEN 24 AND 27 THEN
  SELECT
    floor(SUM(get_byte(cbor,byte_pos) * 2::numeric^(8*(length_bytes-byte_pos))))
  INTO data_value
  FROM generate_series(1,length_bytes) AS byte_pos;
END IF;
--
-- Sorted by observed frequency from real-life WebAuthn examples
-- to hit the matching case as early as possible.
--
IF    major_type = 3 THEN RETURN cbor.major_type_3(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 5 THEN RETURN cbor.major_type_5(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 1 THEN RETURN cbor.major_type_1(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 2 THEN RETURN cbor.major_type_2(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 4 THEN RETURN cbor.major_type_4(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 0 THEN RETURN cbor.major_type_0(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 6 THEN RETURN cbor.major_type_6(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 7 THEN RETURN cbor.major_type_7(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', major_type, additional_type;
END IF;
END;
$$;

