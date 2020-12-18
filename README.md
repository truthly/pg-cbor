<h1 id="top">🧬🐘<code>cbor</code></h1>

1. [About](#about)
1. [Dependencies](#dependencies)
1. [Installation](#installation)
1. [Usage](#usage)
1. [API](#api)
    1. [cbor.to_jsonb()]
    1. [cbor.to_jsonb_array()]
1. [Internal types](#internal-types)
    1. [next_state]
1. [Internal functions](#internal-functions)
    1. [cbor.next_item()]
    1. [cbor.next_array()]
    1. [cbor.next_map()]
    1. [cbor.next_indefinite_array()]
    1. [cbor.next_indefinite_map()]
    1. [cbor.next_indefinite_byte_string()]
    1. [cbor.next_indefinite_text_string()]
    1. [cbor.next_float_half()]
    1. [cbor.next_float_single()]
    1. [cbor.next_float_double()]

[cbor.to_jsonb()]: #to-jsonb
[cbor.to_jsonb_array()]: #to-jsonb-array
[next_state]: #next-state
[cbor.next_item()]: #next-item
[cbor.next_array()]: #next-array
[cbor.next_map()]: #next-map
[cbor.next_indefinite_array()]: #next-indefinite-array
[cbor.next_indefinite_map()]: #next-indefinite-map
[cbor.next_indefinite_byte_string()]: #next-indefinite-byte-string
[cbor.next_indefinite_text_string()]: #next-indefinite-text-string
[cbor.next_float_half()]: #next-float-half
[cbor.next_float_single()]: #next-float-single
[cbor.next_float_double()]: #next-float-double

<h2 id="about">1. About</h2>

`cbor` is a pure SQL [PostgreSQL] extension decoding the The Concise Binary Object Representation ([CBOR]) data format ([RFC 7049]) into [JSON].

[PostgreSQL]: https://www.postgresql.org/
[CBOR]: https://en.wikipedia.org/wiki/CBOR
[RFC 7049]: https://tools.ietf.org/html/rfc7049
[JSON]: https://en.wikipedia.org/wiki/JSON

<h2 id="dependencies">2. Dependencies</h2>

None.

<h2 id="installation">3. Installation</h2>

Install the `cbor` extension with:

    $ git clone https://github.com/truthly/pg-cbor.git
    $ cd pg-cbor
    $ make
    $ make install
    $ make installcheck

<h2 id="usage">4. Usage</h2>

Use with:

    $ psql
    # CREATE EXTENSION cbor;
    CREATE EXTENSION;

<h2 id="api">5. API</h2>

<h3 id="to-jsonb"><code>cbor.to_jsonb(cbor bytea, encode_binary_format text DEFAULT 'hex') → jsonb</code></h3>

  Input Parameter     | Type  | Default
--------------------- | ----- | -----------
 cbor                 | bytea |
 encode_binary_format | text  | 'hex'

Converts *cbor* to [JSON] from [CBOR] [bytea] value.

Expects a single CBOR item on the root level.
This single CBOR item may contain multiple CBOR items, e.g. if it's a CBOR *Array of items* (major type 4) or *Map of pairs of data items* (major type 5).
However, there MUST NOT be multiple CBOR items on the *root level*. If there is, an error will be thrown, with a message informing the user about the other function [cbor.to_jsonb_array()] which is useful if multiple items on the root level is to be expected.

**Note:** Since JSON doesn't have any data type for *Byte strings* (CBOR major type 2),
if there are any such items in the CBOR, they will be represented as text.
The textual representation for such items can be controlled via the *encode_binary_format* input parameter.

[bytea]: https://www.postgresql.org/docs/current/datatype-binary.html

Source code: [FUNCTIONS/to_jsonb.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/to_jsonb.sql#L1)

Example:

```sql
SELECT cbor.to_jsonb('\xa26161016162820203'::bytea);
```

```json
{"a": 1, "b": [2, 3]}
```

<h3 id="to-jsonb-array"><code>cbor.to_jsonb_array(cbor bytea, encode_binary_format text DEFAULT 'hex') → jsonb</code></h3>

  Input Parameter     | Type  | Default
--------------------- | ----- | -----------
 cbor                 | bytea |
 encode_binary_format | text  | 'hex'

Converts *cbor* to [JSON] from [CBOR] [bytea] value.

Returns a json array of all the decoded CBOR items.

**Note:** Since JSON doesn't have any data type for *Byte strings* (CBOR major type 2),
if there are any such items in the CBOR, they will be represented as text.
The textual representation for such items can be controlled via the *encode_binary_format* input parameter.

[bytea]: https://www.postgresql.org/docs/current/datatype-binary.html

Source code: [FUNCTIONS/to_jsonb.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/to_jsonb.sql#L1)

Example:

```sql
SELECT cbor.to_jsonb_array('\xa26161016162820203a26161016162820203'::bytea);
```

```json
[{"a": 1, "b": [2, 3]}, {"a": 1, "b": [2, 3]}]
```

<h2 id="internal-types">6. Internal types</h2>

<h3 id="next-state"><code>cbor.next_state</code></h3>

Used by [cbor.next_item()], [cbor.next_array()], [cbor.next_map()], etc
to return the next decoded CBOR *item* and the *remainder*.

For each decoded CBOR item, the *remainder* is reduced,
until empty, when all CBOR items have been decoded.

  Field    | Type  | Description
---------- | ----- | -----------
 remainder | bytea | The remainder after decoding a CBOR item
 item      | jsonb | A single decoded CBOR item

[Source code:](https://github.com/truthly/pg-cbor/blob/master/TYPES/next_state.sql#L1)

```sql
CREATE TYPE cbor.next_state AS (remainder bytea, item jsonb);
```

<h2 id="internal-functions">7. Internal functions</h2>

<h3 id="next-item"><code>cbor.next_item(cbor bytea) → cbor.next_state</code></h3>

Decodes a single CBOR item from the beginning of the *cbor* [bytea] value.

If the item is an *array*, [cbor.next_array()] is called to decode *data_value* number of items that follows.

If the item is an *map*, [cbor.next_map()] is called to decode *data_value* number of key/value item pairs that follows.

If the item is an *indefinite array*, [cbor.next_indefinite_array()] is called to decode all items that follows, till next corresponding [Break Code].

If the item is an *indefinite map*, [cbor.next_indefinite_map()] is called to decode all key/value item pairs that follows, till next corresponding [Break Code].

If the item is an *indefinite byte string*, [cbor.next_indefinite_byte_string()] is called to decode all byte strings that follows, till next corresponding [Break Code]. The returned item will be a single byte string created by concatenating all the decoded byte strings.

If the item is an *indefinite text string*, [cbor.next_indefinite_text_string()] is called to decode all text strings that follows, till next corresponding [Break Code]. The returned item will be a single text string created by concatenating all the decoded text strings.

If the item is a *IEEE 754 half-precision float*, [cbor.next_float_half()] is called to decode the value.

If the item is a *IEEE 754 single-precision float*, [cbor.next_float_single()] is called to decode the value.

If the item is a *IEEE 754 double-precision float*, [cbor.next_float_double()] is called to decode the value.

[Break Code]: https://en.wikipedia.org/wiki/CBOR#Break_control_code_(Additional_type_value_=_31)

Source code: [FUNCTIONS/next_item.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_item.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_item('\x0a0b0c'::bytea);
 remainder | item
-----------+------
 \x0b0c    | 10
(1 row)
```

<h3 id="next-array"><code>cbor.next_array(cbor bytea, item_count integer) → cbor.next_state</code></h3>

Decodes *item_count* CBOR items from the beginning of the *cbor* [bytea] value.

The returned *item* will be a *jsonb array*, and the *remainder* will contain the CBOR data left to process,
after having processed all the CBOR items for the array.

Source code: [FUNCTIONS/next_array.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_array.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_array('\x0203'::bytea,2);
 remainder |  item
-----------+--------
 \x        | [2, 3]
(1 row)
```

<h3 id="next-map"><code>cbor.next_map(cbor bytea, item_count integer) → cbor.next_state</code></h3>

Decodes *item_count* pair of key/value CBOR items from the beginning of the *cbor* [bytea] value.

The returned *item* will be a *jsonb object*, and the *remainder* will contain the CBOR data left to process,
after having processed all the CBOR items for the map.

Source code: [FUNCTIONS/next_map.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_map.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_map('\x6161016162820203'::bytea,2);
 remainder |         item
-----------+-----------------------
 \x        | {"a": 1, "b": [2, 3]}
(1 row)
```

<h3 id="next-indefinite-array"><code>cbor.next_indefinite_array(cbor bytea, encode_binary_format text) → cbor.next_state</code></h3>

Decodes CBOR items from the beginning of the *cbor* [bytea] value, until reaching a [Break Code].

The returned *item* field is a jsonb array of all the decoded items.

Similar to [cbor.next_array()], but doesn't have the *item_count* input parameter to specify how many items to expect, instead the [Break Code] determines the end.

Source code: [FUNCTIONS/next_indefinite_array.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_indefinite_array.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_indefinite_array('\x010203ff'::bytea,'hex');
 remainder |   item
-----------+-----------
 \x        | [1, 2, 3]
(1 row)
```

<h3 id="next-indefinite-map"><code>cbor.next_indefinite_map(cbor bytea, encode_binary_format text) → cbor.next_state</code></h3>

Decodes CBOR key/value item pairs from the beginning of the *cbor* [bytea] value, until reaching a [Break Code].

The returned *item* field is a jsonb object of all the decoded key/value item pairs.

Similar to [cbor.next_map()], but doesn't have the *item_count* input parameter to specify how many items to expect, instead the [Break Code] determines the end.

Source code: [FUNCTIONS/next_indefinite_map.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_indefinite_map.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_indefinite_map('\x61610a616214ff'::bytea,'hex');
 remainder |        item
-----------+--------------------
 \x        | {"a": 10, "b": 20}
(1 row)
```

<h3 id="next-indefinite-byte-string"><code>cbor.next_indefinite_byte_string(cbor bytea, encode_binary_format text) → cbor.next_state</code></h3>

Decodes CBOR *Byte string* items from the beginning of the *cbor* [bytea] value, until reaching a [Break Code].

If encountering a CBOR item that is not a *Byte string* (major type 2), an error will be thrown.

The returned *item* field is a textual representation of the concatenated byte strings,
in the format specified using the *encode_binary_format* input parameter.

Source code: [FUNCTIONS/next_indefinite_byte_string.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_indefinite_byte_string.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_indefinite_byte_string('\x42010243030405ff'::bytea,'hex');
 remainder |     item
-----------+--------------
 \x        | "0102030405"
(1 row)
```

<h3 id="next-indefinite-text-string"><code>cbor.next_indefinite_text_string(cbor bytea, encode_binary_format text) → cbor.next_state</code></h3>

Decodes CBOR *Text string* items from the beginning of the *cbor* [bytea] value, until reaching a [Break Code].

If encountering a CBOR item that is not a *Text string* (major type 3), an error will be thrown.

The returned *item* field is the concatenation of all decoded text strings.

Source code: [FUNCTIONS/next_indefinite_text_string.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_indefinite_text_string.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_indefinite_text_string('\x657374726561646d696e67ff'::bytea,'hex');
 remainder |    item
-----------+-------------
 \x        | "streaming"
(1 row)
```

<h3 id="next-float-half"><code>cbor.next_float_half(cbor bytea) → cbor.next_state</code></h3>

Decodes a *IEEE 754 half-precision float* CBOR item from the beginning of the *cbor* [bytea] value.

**Note:** Since the special float values `Infinity` and `NaN` are not part of the [JSON] specification, there is no unambiguous way of representing them in JSON. Per design, an error will be thrown if encountering such values.

The returned *item* field is of JSON type *number*.

Source code: [FUNCTIONS/next_float_half.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_float_half.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_float_half('\x3e00'::bytea);
 remainder | item
-----------+------
 \x        | 1.5
(1 row)
```

<h3 id="next-float-single"><code>cbor.next_float_single(cbor bytea) → cbor.next_state</code></h3>

Decodes a *IEEE 754 single-precision float* CBOR item from the beginning of the *cbor* [bytea] value.

**Note:** Since the special float values `Infinity` and `NaN` are not part of the [JSON] specification, there is no unambiguous way of representing them in JSON. Per design, an error will be thrown if encountering such values.

The returned *item* field is of JSON type *number*.

Source code: [FUNCTIONS/next_float_single.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_float_single.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_float_single('\x47c35000'::bytea);
 remainder |  item
-----------+--------
 \x        | 100000
(1 row)
```

<h3 id="next-float-double"><code>cbor.next_float_double(cbor bytea) → cbor.next_state</code></h3>

Decodes a *IEEE 754 double-precision float* CBOR item from the beginning of the *cbor* [bytea] value.

**Note:** Since the special float values `Infinity` and `NaN` are not part of the [JSON] specification, there is no unambiguous way of representing them in JSON. Per design, an error will be thrown if encountering such values.

The returned *item* field is of JSON type *number*.

Source code: [FUNCTIONS/next_float_double.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_float_double.sql#L1)

Example:

```sql
SELECT * FROM cbor.next_float_double('\xc010666666666666'::bytea);
 remainder | item
-----------+------
 \x        | -4.1
(1 row)
```
