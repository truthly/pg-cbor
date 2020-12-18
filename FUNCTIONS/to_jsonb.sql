CREATE OR REPLACE FUNCTION cbor.to_jsonb(
  cbor bytea,
  encode_binary_format text DEFAULT 'hex'
)
RETURNS jsonb
LANGUAGE sql
AS $$
SELECT
  CASE
    WHEN length(remainder) = 0
    THEN item
    ELSE cbor.raise('Multiple root level CBOR items. Use to_jsonb_array() instead if this is expected.',NULL,NULL::jsonb)
  END
FROM cbor.next_item(to_jsonb.cbor, encode_binary_format)
$$;
