CREATE OR REPLACE FUNCTION cbor.bytea_to_numeric(val bytea)
RETURNS numeric
IMMUTABLE STRICT
LANGUAGE plpgsql
AS $$
-- Based on: https://stackoverflow.com/questions/37248518/sql-function-to-convert-numeric-to-bytea-and-bytea-to-numeric
DECLARE
n numeric := 0;
BEGIN
FOR i IN 0 .. length(val)-1 LOOP
  n := n*256 + get_byte(val,i);
END LOOP;
RETURN n;
END;
$$;
