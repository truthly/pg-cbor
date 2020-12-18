CREATE OR REPLACE FUNCTION cbor.raise(message text, debug json, dummy_return_value anyelement)
RETURNS anyelement
LANGUAGE plpgsql
AS $$
BEGIN
IF debug IS NOT NULL THEN
  RAISE '% %', message, debug;
ELSE
  RAISE '%', message;
END IF;
END;
$$;
