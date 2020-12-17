CREATE OR REPLACE FUNCTION cbor.next_array(cbor bytea, item_count integer)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    next_array.cbor AS remainder,
    next_array.item_count,
    jsonb_build_array() AS jsonb_array
  UNION ALL
  SELECT
    next_item.remainder,
    x.item_count-1,
    x.jsonb_array || next_item.item
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE x.item_count > 0
)
SELECT ROW(x.remainder, x.jsonb_array) FROM x WHERE x.item_count = 0
$$;
