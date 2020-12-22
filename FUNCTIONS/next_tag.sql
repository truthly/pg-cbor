CREATE OR REPLACE FUNCTION cbor.next_tag(cbor bytea, tag_number numeric, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
SELECT
CASE
WHEN tag_number = 0 AND (next_item.item#>>'{}')::timestamptz IS NOT NULL THEN next_item
ELSE next_item
END
FROM cbor.next_item(cbor, encode_binary_format)
$$;
