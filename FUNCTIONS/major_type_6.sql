CREATE OR REPLACE FUNCTION cbor.major_type_6(
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
IF additional_type = 2 THEN
  RETURN (
    SELECT
      ROW(tag_item.remainder, pg_catalog.to_jsonb(cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))
    FROM cbor.next_item(substring(cbor,2), encode_binary_format) AS tag_item
  );
ELSIF additional_type = 3 THEN
  RETURN (
    SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(-1-cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))
    FROM cbor.next_item(substring(cbor,2), encode_binary_format) AS tag_item
  );
ELSIF additional_type = 21 THEN
  RETURN cbor.next_item(substring(cbor,2), 'base64url');
ELSIF additional_type = 22 THEN
  RETURN cbor.next_item(substring(cbor,2), 'base64');
ELSIF additional_type = 23 THEN
  RETURN cbor.next_item(substring(cbor,2), 'hex');
ELSIF additional_type = ANY(ARRAY[0,1,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,25,26,27]) THEN
  RETURN cbor.next_tag(substring(cbor,2+length_bytes), data_value, encode_binary_format);
ELSIF additional_type >= 28 AND additional_type <= 30 THEN
  RAISE EXCEPTION 'a reserved value is used for additional information(%)', additional_type;
ELSIF additional_type = 31 THEN
  RAISE EXCEPTION 'additional information 31 used with major type 6';
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', 6, additional_type;
END IF;
END;
$$;
