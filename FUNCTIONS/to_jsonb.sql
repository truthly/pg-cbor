CREATE OR REPLACE FUNCTION cbor.to_jsonb(cbor bytea)
RETURNS jsonb
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_item.remainder,
    jsonb_build_array(next_item.item) AS items
  FROM cbor.next_item(to_jsonb.cbor)
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    x.items || next_item.item
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE length(x.remainder) > 0
)
SELECT x.items FROM x ORDER BY i DESC LIMIT 1
$$;
