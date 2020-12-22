CREATE OR REPLACE FUNCTION cbor.major_type_4(
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
  RETURN cbor.next_array(substring(cbor,2+length_bytes), data_value::integer, encode_binary_format);
ELSIF additional_type = 31 THEN
  RETURN cbor.next_indefinite_array(substring(cbor,2), encode_binary_format);
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 4, additional_type;
END IF;
END;
$$;
