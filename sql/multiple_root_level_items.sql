--
-- Test dealing with multiple root level CBOR items
--
BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

-- A single CBOR item becomes a scalar JSON value
SELECT cbor.to_jsonb('\x01'::bytea);

-- A single CBOR item becomes a JSON array with a single element
SELECT cbor.to_jsonb_array('\x01'::bytea);

--
-- CBOR containing multiple root level items
-- can only be decoded using cbor.to_jsonb_array().
--
-- Trying to use cbor.to_jsonb() will throw an error
-- and advise the user to perhaps use cbor.to_jsonb_array()
-- instead, if multiple root level items is expected.
--

SAVEPOINT multiple_root_level_cbor_items;
SELECT cbor.to_jsonb('\x010203'::bytea);
ROLLBACK TO multiple_root_level_cbor_items;

-- Empty byte array gives empty json array
SELECT cbor.to_jsonb_array('\x'::bytea);

-- NULL input returns SQL NULL
SELECT cbor.to_jsonb_array(NULL::bytea);
SELECT cbor.to_jsonb(NULL::bytea);

-- The multiple CBOR items becomes a single JSON array with multiple elements.
SELECT cbor.to_jsonb_array('\x010203'::bytea);

--
-- If in control of how the CBOR is created,
-- it is perhaps better to pack the multiple CBOR items
-- as major type 4 (Array of data items),
-- so that cbor.to_jsonb() can be used.
--
SELECT cbor.to_jsonb('\x83010203'::bytea);

--
-- Trying to decode a single CBOR "Array of data items" item
-- is nothing special, and will simply produce
-- a two-dimensional JSON array where the first element is a JSON array.
--
SELECT cbor.to_jsonb_array('\x83010203'::bytea);

--
-- We could go crazy and decode two CBOR "Array of data items" items.
-- This will produce a two-dimensional array, with two JSON array elements.
--
SELECT cbor.to_jsonb_array('\x8301020383010203'::bytea);

ROLLBACK;
