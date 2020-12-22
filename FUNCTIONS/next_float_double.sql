CREATE OR REPLACE FUNCTION cbor.next_float_double(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
DECLARE
double bit(64) := get_byte(cbor,0)::bit(8) ||
                  get_byte(cbor,1)::bit(8) ||
                  get_byte(cbor,2)::bit(8) ||
                  get_byte(cbor,3)::bit(8) ||
                  get_byte(cbor,4)::bit(8) ||
                  get_byte(cbor,5)::bit(8) ||
                  get_byte(cbor,6)::bit(8) ||
                  get_byte(cbor,7)::bit(8);
/*
0000000001111111111222222222233333333334444444444555555555566666
1234567890123456789012345678901234567890123456789012345678901234
seeeeeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffffffff
^-sign (1 bit)
 ^-exponent (11 bits)
            ^-fraction (52 bits)
*/
sign boolean := get_bit(double, 0)::integer::boolean;
exponent integer := substring(double from 2 for 11)::integer;
fraction bigint := substring(double from 13 for 52)::bigint;
frac float8 := (fraction | (1::bigint << 52))::float8 / (2::bigint << 52)::float8;
value float8;
BEGIN
IF exponent = b'11111111111'::integer THEN
  IF fraction = b'0000000000000000000000000000000000000000000000000000'::bigint THEN
    RETURN ROW(substring(cbor,9), cbor.infinity_value(sign))::cbor.next_state;
  ELSE
    RETURN ROW(substring(cbor,9), cbor.nan_value())::cbor.next_state;
  END IF;
END IF;
value := frac * 2::float8^(exponent-1022);
IF sign THEN
  value := -value;
END IF;
RETURN ROW(substring(cbor,9), pg_catalog.to_jsonb(value))::cbor.next_state;
END;
$$;
