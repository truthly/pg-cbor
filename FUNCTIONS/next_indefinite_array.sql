CREATE OR REPLACE FUNCTION cbor.next_indefinite_array(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_indefinite_array.cbor AS remainder,
    jsonb_build_array() AS jsonb_array
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    x.jsonb_array || jsonb_build_array(next_item.item)
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder, encode_binary_format) ON TRUE
  WHERE get_byte(x.remainder,0) <> 255
)
SELECT ROW(substring(x.remainder,2), x.jsonb_array)::cbor.next_state FROM x ORDER BY i DESC LIMIT 1
$$;
