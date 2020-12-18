CREATE OR REPLACE FUNCTION cbor.next_indefinite_text_string(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_indefinite_text_string.cbor AS remainder,
    ''::text AS text_string
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    x.text_string || CASE
      WHEN (get_byte(x.remainder,0)>>5)&'111'::bit(3)::integer = 3
      THEN (next_item.item#>>'{}')
      ELSE cbor.raise('Next CBOR item is not a text string',NULL,NULL::text)
    END
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE get_byte(x.remainder,0) <> 255
)
SELECT ROW(substring(x.remainder,2), to_jsonb(x.text_string)) FROM x ORDER BY i DESC LIMIT 1
$$;
