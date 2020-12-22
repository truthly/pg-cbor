--
-- This function is meant to be replaced by the user if necessary,
-- to allow user-defined handling of CBOR types with no direct analogs in JSON.
--
-- https://tools.ietf.org/html/rfc8949#section-6.1
--
CREATE OR REPLACE FUNCTION cbor.undefined_value()
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
RAISE EXCEPTION 'Undefined value has no direct analog in JSON.'
USING HINT = 'Replace cbor.undefined_value() with user-defined function returning a substitue value, e.g. JSON null, if Undefined values are expected and needs to be handled.',
      DETAIL = 'See: https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/undefined_value.sql for examples on such user-defined functions.';
END;
$$;

--
-- For inspiration, below are some alternative handlers for Undefined values.
--
-- WARNING:
-- Please understand that returning a substitute value will introduce
-- a new class of possible bugs due to ambiguity, which might be OK
-- or dangerous, depending on the situation.
--

/*
CREATE OR REPLACE FUNCTION cbor.undefined_value()
RETURNS jsonb
LANGUAGE sql
AS $$
SELECT 'null'::jsonb;
$$;
*/

/*
CREATE OR REPLACE FUNCTION cbor.undefined_value()
RETURNS jsonb
LANGUAGE sql
AS $$
SELECT '"Undefined"'::jsonb;
$$;
*/