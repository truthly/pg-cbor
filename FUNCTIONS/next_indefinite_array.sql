CREATE OR REPLACE FUNCTION cbor.next_indefinite_array(cbor bytea)
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
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE get_byte(x.remainder,0) <> 255
)
SELECT ROW(substring(x.remainder,2), x.jsonb_array) FROM x ORDER BY i DESC LIMIT 1
$$;
