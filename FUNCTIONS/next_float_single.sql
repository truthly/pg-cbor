CREATE OR REPLACE FUNCTION cbor.next_float_single(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
DECLARE
single bit(32) := get_byte(cbor,0)::bit(8) ||
                  get_byte(cbor,1)::bit(8) ||
                  get_byte(cbor,2)::bit(8) ||
                  get_byte(cbor,3)::bit(8);
/*
00000000011111111112222222222333
12345678901234567890123456789012
seeeeeeeefffffffffffffffffffffff
^-sign (1 bit)
 ^-exponent (8 bits)
         ^-fraction (23 bits)
*/
sign boolean := get_bit(single, 0)::integer::boolean;
exponent integer := substring(single from 2 for 8)::integer;
fraction integer := substring(single from 10 for 23)::integer;
frac float8 := (fraction | (1::integer << 23))::float8 / (2::integer << 23)::float8;
value float8;
BEGIN
IF exponent = b'11111111'::integer THEN
  IF fraction = b'00000000000000000000000'::integer THEN
    RETURN ROW(substring(cbor,5), cbor.infinity_value(sign))::cbor.next_state;
  ELSE
    RETURN ROW(substring(cbor,5), cbor.nan_value())::cbor.next_state;
  END IF;
END IF;
value := frac * 2::float8^(exponent-126);
IF sign THEN
  value := -value;
END IF;
RETURN ROW(substring(cbor,5), pg_catalog.to_jsonb(value))::cbor.next_state;
END;
$$;
