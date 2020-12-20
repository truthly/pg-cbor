CREATE OR REPLACE FUNCTION cbor.to_jsonb_array(
  cbor bytea,
  encode_binary_format text DEFAULT 'hex'
)
RETURNS jsonb
STRICT
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_item.remainder,
    next_item.item
  FROM cbor.next_item(to_jsonb_array.cbor, encode_binary_format)
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    next_item.item
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder, encode_binary_format) ON TRUE
  WHERE length(x.remainder) > 0
)
SELECT
  CASE
    WHEN length(cbor) = 0
    THEN jsonb_build_array()
    ELSE (SELECT jsonb_agg(x.item ORDER BY i) FROM x)
  END
$$;
