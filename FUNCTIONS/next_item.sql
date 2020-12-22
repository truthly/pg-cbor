CREATE OR REPLACE FUNCTION cbor.next_item(cbor bytea, encode_binary_format text)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
DECLARE
major_type constant integer := (get_byte(cbor,0) >> 5) & '111'::bit(3)::integer;
additional_type constant integer :=  get_byte(cbor,0) & '11111'::bit(5)::integer;
length_bytes constant integer := NULLIF(LEAST(floor(2 ^ (additional_type - 24))::integer,16),16);
data_value numeric := 0;
BEGIN
IF additional_type <= 23 THEN
  data_value := additional_type::numeric;
ELSIF additional_type BETWEEN 24 AND 27 THEN
/*
  FOR byte_pos IN 1..length_bytes LOOP
    data_value := data_value + get_byte(cbor,byte_pos) * 2::numeric^(8*(length_bytes-byte_pos));
  END LOOP;
  data_value := floor(data_value);
*/
  SELECT
    floor(SUM(get_byte(cbor,byte_pos) * 2::numeric^(8*(length_bytes-byte_pos))))
  INTO data_value
  FROM generate_series(1,length_bytes) AS byte_pos;
END IF;
--
-- Sorted by observed frequency from real-life WebAuthn examples
-- to hit the matching case as early as possible.
--
IF    major_type = 3 THEN RETURN cbor.major_type_3(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 5 THEN RETURN cbor.major_type_5(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 1 THEN RETURN cbor.major_type_1(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 2 THEN RETURN cbor.major_type_2(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 4 THEN RETURN cbor.major_type_4(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 0 THEN RETURN cbor.major_type_0(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 6 THEN RETURN cbor.major_type_6(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSIF major_type = 7 THEN RETURN cbor.major_type_7(cbor,encode_binary_format,additional_type,length_bytes,data_value);
ELSE
  RAISE EXCEPTION 'not implemented, major_type %, additional_type %', major_type, additional_type;
END IF;
END;
$$;
