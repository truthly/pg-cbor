CREATE OR REPLACE FUNCTION cbor.raise(message text, debug json, dummy_return_value anyelement)
RETURNS anyelement
LANGUAGE plpgsql
AS $$
BEGIN
RAISE '% %', message, debug;
END;
$$;
