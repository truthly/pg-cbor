CREATE OR REPLACE FUNCTION cbor.next_float_half(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
-- https://tools.ietf.org/html/rfc7049#appendix-D
DECLARE
half int := (get_byte(cbor,0) << 8) + get_byte(cbor,1);
exp int := (half >> 10) & x'1f'::int;
mant int := half & x'3ff'::int;
val float8;
BEGIN
IF exp = 0 THEN
  val := mant * 2^(-24);
ELSIF exp != 31 THEN
  val := (mant + 1024) * 2^(exp-25);
ELSIF mant = 0 THEN
  RAISE EXCEPTION 'Decoding of INFINITY value not possible since not part of JSON';
ELSE
  RAISE EXCEPTION 'Decoding of NAN value not possible since not part of JSON';
END IF;
IF (half & x'8000'::int) != 0 THEN
  val := -val;
END IF;
RETURN ROW(substring(cbor,3), pg_catalog.to_jsonb(val))::cbor.next_state;
END;
$$;
