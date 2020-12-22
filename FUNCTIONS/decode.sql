CREATE OR REPLACE FUNCTION cbor.decode(text,text)
RETURNS bytea
IMMUTABLE
STRICT
LANGUAGE sql AS $$
-- Wrapper-function to add base64url support to decode()
SELECT
CASE $1
  WHEN 'base64url' THEN pg_catalog.decode(rpad(translate($1,'-_','+/'),length($1) + (4 - length($1) % 4) % 4, '='),'base64')
  ELSE pg_catalog.decode($1,$2)
END
$$;
