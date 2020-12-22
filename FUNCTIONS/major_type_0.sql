CREATE OR REPLACE FUNCTION cbor.major_type_0(
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
  RETURN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value));
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSIF additional_type = 31 THEN
  RAISE EXCEPTION 'additional information 31 used with major type 0';
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 0, additional_type;
END IF;
END;
$$;
