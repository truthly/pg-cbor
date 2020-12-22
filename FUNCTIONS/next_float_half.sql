CREATE OR REPLACE FUNCTION cbor.next_float_half(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
-- https://tools.ietf.org/html/rfc7049#appendix-D
DECLARE
sign boolean;
half int := (get_byte(cbor,0) << 8) + get_byte(cbor,1);
exp int := (half >> 10) & x'1f'::int;
mant int := half & x'3ff'::int;
val float8;
BEGIN
sign := (half & x'8000'::int) != 0;
IF exp = 0 THEN
  val := mant * 2^(-24);
ELSIF exp != 31 THEN
  val := (mant + 1024) * 2^(exp-25);
ELSIF mant = 0 THEN
    RETURN ROW(substring(cbor,3), cbor.infinity_value(sign))::cbor.next_state;
ELSE
    RETURN ROW(substring(cbor,3), cbor.nan_value())::cbor.next_state;
END IF;
IF sign THEN
  val := -val;
END IF;
RETURN ROW(substring(cbor,3), pg_catalog.to_jsonb(val))::cbor.next_state;
END;
$$;
