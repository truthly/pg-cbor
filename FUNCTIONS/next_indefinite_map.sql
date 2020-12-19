CREATE OR REPLACE FUNCTION cbor.next_indefinite_map(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_indefinite_map.cbor AS remainder,
    jsonb_build_object() AS map
  UNION ALL
  SELECT
    x.i + 1,
    map_value.remainder,
    x.map || jsonb_build_object(map_key.item#>>'{}', map_value.item)
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder, encode_binary_format) AS map_key ON TRUE
  JOIN LATERAL cbor.next_item(map_key.remainder, encode_binary_format) AS map_value ON TRUE
  WHERE get_byte(x.remainder,0) <> 255
)
SELECT ROW(substring(x.remainder,2), x.map)::cbor.next_state FROM x ORDER BY i DESC LIMIT 1
$$;
