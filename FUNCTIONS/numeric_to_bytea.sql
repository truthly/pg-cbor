CREATE OR REPLACE FUNCTION cbor.numeric_to_bytea(n numeric)
RETURNS bytea
IMMUTABLE STRICT
LANGUAGE plpgsql
AS $$
DECLARE
b BYTEA := '\x';
v INTEGER;
BEGIN
WHILE n > 0 LOOP
  v := n % 256;
  b := set_byte(('\x00' || b),0,v);
  n := (n-v)/256;
END LOOP;
RETURN b;
END;
$$;
