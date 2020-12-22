CREATE OR REPLACE FUNCTION cbor.encode(bytea,text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
-- Wrapper-function to add base64url support to encode()
SELECT
CASE $1
  WHEN 'base64url' THEN translate(trim(trailing '=' from replace(pg_catalog.encode($1,'base64'),E'\n','')),'+/','-_')
  ELSE pg_catalog.encode($1,$2)
END
$$;
