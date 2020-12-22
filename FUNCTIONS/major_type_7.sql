CREATE OR REPLACE FUNCTION cbor.major_type_7(
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
IF additional_type = 20 THEN
  RETURN ROW(substring(cbor,2), pg_catalog.to_jsonb(false));
ELSIF additional_type = 21 THEN
  RETURN ROW(substring(cbor,2), pg_catalog.to_jsonb(true));
ELSIF additional_type = 22 THEN
  RETURN ROW(substring(cbor,2), 'null'::jsonb);
ELSIF additional_type = 25 THEN
  RETURN cbor.next_float_half(substring(cbor,2));
ELSIF additional_type = 26 THEN
  RETURN cbor.next_float_single(substring(cbor,2));
ELSIF additional_type = 27 THEN
  RETURN cbor.next_float_double(substring(cbor,2));
ELSIF additional_type = 23 THEN
  RETURN ROW(substring(cbor,2), cbor.undefined_value());
ELSIF additional_type = 24 AND data_value >= 32 THEN
  RETURN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value));
ELSIF additional_type <= 19 THEN
  RETURN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value));
ELSIF additional_type > 27 AND additional_type < 31 THEN
  RETURN ROW(substring(cbor,2), cbor.substitute_value(substring(cbor,2), 7, additional_type));
ELSIF additional_type = 31 THEN
  RAISE EXCEPTION '"break" stop code appeared where a data item is expected, the enclosing item is not well-formed';
ELSIF additional_type = 24 AND data_value < 32 THEN
  RAISE EXCEPTION 'major type 7, additional information 24, data_value(%) < 32 (incorrect)', data_value;
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 7, additional_type;
END IF;
END;
$$;
