CREATE OR REPLACE FUNCTION cbor.bytea_to_numeric(val bytea)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
n numeric := 0;
BEGIN
FOR i IN 0 .. length(val)-1 LOOP
  n := n*256 + get_byte(val,i);
END LOOP;
RETURN n;
END;
$$;
