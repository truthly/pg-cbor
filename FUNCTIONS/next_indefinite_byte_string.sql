CREATE OR REPLACE FUNCTION cbor.next_indefinite_byte_string(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_indefinite_byte_string.cbor AS remainder,
    '\x'::bytea AS bytes
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    x.bytes || CASE
      WHEN (get_byte(x.remainder,0)>>5)&'111'::bit(3)::integer = 2
      THEN decode((next_item.item#>>'{}'),encode_binary_format)
      ELSE cbor.raise('Next CBOR item is not a byte string',NULL,NULL::bytea)
    END
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder, encode_binary_format) ON TRUE
  WHERE get_byte(x.remainder,0) <> 255
)
SELECT ROW(substring(x.remainder,2), to_jsonb(encode(x.bytes,encode_binary_format))) FROM x ORDER BY i DESC LIMIT 1
$$;
