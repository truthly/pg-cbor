CREATE OR REPLACE FUNCTION cbor.next_map(cbor bytea, item_count integer)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    next_map.cbor AS remainder,
    next_map.item_count,
    jsonb_build_object() AS map
  UNION ALL
  SELECT
    map_value.remainder,
    x.item_count-1,
    x.map || jsonb_build_object(map_key.item#>>'{}', map_value.item)
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) AS map_key ON TRUE
  JOIN LATERAL cbor.next_item(map_key.remainder) AS map_value ON TRUE
  WHERE x.item_count > 0
)
SELECT ROW(x.remainder, x.map) FROM x WHERE x.item_count = 0
$$;
