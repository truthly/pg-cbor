<h1 id="top">🧬🐘<code>cbor</code></h1>

1. [About](#about)
1. [Dependencies](#dependencies)
1. [Installation](#installation)
1. [Usage](#usage)
1. [API](#api)
    1. [cbor.to_jsonb()]
1. [Internal types](#internal-types)
    1. [next_state]
1. [Internal functions](#internal-functions)
    1. [cbor.next_item()]
    1. [cbor.next_array()]
    1. [cbor.next_map()]

[cbor.to_jsonb()]: #to-jsonb
[next_state]: #next-state
[cbor.next_item()]: #next-item
[cbor.next_array()]: #next-array
[cbor.next_map()]: #next-map

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

<h3 id="to-jsonb"><code>cbor.to_jsonb(cbor bytea) → jsonb</code></h3>

Converts *cbor* to [JSON] from [CBOR] [bytea] value.

[bytea]: https://www.postgresql.org/docs/current/datatype-binary.html

Example:

```sql
SELECT cbor.to_jsonb('\xa26161016162820203'::bytea);
```

```json
[{"a": 1, "b": [2, 3]}]
```

Source code:

```sql
CREATE OR REPLACE FUNCTION cbor.to_jsonb(cbor bytea)
RETURNS jsonb
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    0 AS i,
    next_item.remainder,
    jsonb_build_array(next_item.item) AS items
  FROM cbor.next_item(to_jsonb.cbor)
  UNION ALL
  SELECT
    x.i + 1,
    next_item.remainder,
    x.items || next_item.item
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE length(x.remainder) > 0
)
SELECT x.items FROM x ORDER BY i DESC LIMIT 1
$$;
```

<h2 id="internal-types">6. Internal types</h2>

<h3 id="next-state"><code>cbor.next_state</code></h3>

Used by [cbor.next_item()], [cbor.next_array()] and [cbor.next_map()]
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

Example:

```sql
SELECT * FROM cbor.next_item('\x0a0b0c'::bytea);
 remainder | item
-----------+------
 \x0b0c    | 10
(1 row)
```

[Source code:](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_item.sql#L1)

```sql
CREATE OR REPLACE FUNCTION cbor.next_item(cbor bytea)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
SELECT
  CASE
    WHEN major_type = 0 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 1 AND additional_type <= 27 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(-1-data_value))::cbor.next_state
    WHEN major_type = 2 AND additional_type <= 26 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(encode(substring(cbor,2+length_bytes,data_value::integer),'hex')))::cbor.next_state
    WHEN major_type = 2 AND additional_type  = 31 THEN cbor.next_indefinite_byte_string(substring(cbor,2))
    WHEN major_type = 3 AND additional_type <= 26 THEN ROW(substring(cbor,2+length_bytes+data_value::integer), pg_catalog.to_jsonb(convert_from(substring(cbor,2+length_bytes,data_value::integer),'utf8')))::cbor.next_state
    WHEN major_type = 3 AND additional_type  = 31 THEN cbor.next_indefinite_text_string(substring(cbor,2))
    WHEN major_type = 4 AND additional_type <= 26 THEN cbor.next_array(substring(cbor,2+length_bytes), data_value::integer)
    WHEN major_type = 4 AND additional_type  = 31 THEN cbor.next_indefinite_array(substring(cbor,2))
    WHEN major_type = 5 AND additional_type <= 26 THEN cbor.next_map(substring(cbor,2+length_bytes), data_value::integer)
    WHEN major_type = 5 AND additional_type  = 31 THEN cbor.next_indefinite_map(substring(cbor,2))
    WHEN major_type = 6 AND additional_type  = 2  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2)) AS tag_item)
    WHEN major_type = 6 AND additional_type  = 3  THEN (SELECT ROW(tag_item.remainder, pg_catalog.to_jsonb(-1-cbor.bytea_to_numeric(decode(tag_item.item#>>'{}','hex'))))::cbor.next_state FROM cbor.next_item(substring(cbor,2)) AS tag_item)
    WHEN major_type = 7 AND additional_type <= 19 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 20 THEN ROW(substring(cbor,2), pg_catalog.to_jsonb(false))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 21 THEN ROW(substring(cbor,2), pg_catalog.to_jsonb(true))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 22 THEN ROW(substring(cbor,2), 'null'::jsonb)::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 23 THEN cbor.raise('Decoding of Undefined not possible since since not part of JSON',NULL,NULL::cbor.next_state)
    WHEN major_type = 7 AND additional_type  = 24 THEN ROW(substring(cbor,2+length_bytes), pg_catalog.to_jsonb(data_value))::cbor.next_state
    WHEN major_type = 7 AND additional_type  = 25 THEN cbor.next_float_half(substring(cbor,2))
    WHEN major_type = 7 AND additional_type  = 26 THEN cbor.next_float_single(substring(cbor,2))
    WHEN major_type = 7 AND additional_type  = 27 THEN cbor.next_float_double(substring(cbor,2))
    ELSE cbor.raise('Decoding of CBOR type not implemented',json_build_object('major_type',major_type,'additional_type',additional_type),NULL::cbor.next_state)
  END
FROM (VALUES(
  -- major_type:
  (get_byte(cbor,0)>>5)&'111'::bit(3)::integer,
  -- additional_type:
  get_byte(cbor,0)&'11111'::bit(5)::integer
  )) AS data_item_header(major_type, additional_type)
JOIN LATERAL (VALUES(
  CASE WHEN additional_type <= 23 THEN 0
       WHEN additional_type  = 24 THEN 1
       WHEN additional_type  = 25 THEN 2
       WHEN additional_type  = 26 THEN 4
       WHEN additional_type  = 27 THEN 8
  END,
  CASE WHEN additional_type <= 23 THEN
         additional_type::numeric
       WHEN additional_type  = 24 THEN
         -- uint8_t:
         get_byte(cbor,1)::numeric
       WHEN additional_type  = 25 THEN
         -- uint16_t:
         ((get_byte(cbor,1)<<8) +
           get_byte(cbor,2))::numeric
       WHEN additional_type  = 26 THEN
         -- uint32_t:
         ((get_byte(cbor,1)::bigint<<24) +
          (get_byte(cbor,2)::bigint<<16) +
          (get_byte(cbor,3)::bigint<<8) +
           get_byte(cbor,4)::bigint)::numeric
       WHEN additional_type  = 27 THEN
         -- uint64_t:
         floor((get_byte(cbor,1)*2::numeric^56) +
               (get_byte(cbor,2)*2::numeric^48) +
               (get_byte(cbor,3)*2::numeric^40) +
               (get_byte(cbor,4)*2::numeric^32) +
               (get_byte(cbor,5)*2::numeric^24) +
               (get_byte(cbor,6)*2::numeric^16) +
               (get_byte(cbor,7)*2::numeric^8) +
                get_byte(cbor,8)::numeric)
  END
)) AS additional_type_meaning(length_bytes, data_value) ON TRUE
$$;
```

<h3 id="next-array"><code>cbor.next_array(cbor bytea, item_count integer) → cbor.next_state</code></h3>

Decodes *item_count* CBOR items from the beginning of the *cbor* [bytea] value.

The returned *item* will be a *jsonb array*, and the *remainder* will contain the CBOR data left to process,
after having processed all the CBOR items for the array.

Example:

```sql
SELECT * FROM cbor.next_array('\x0203'::bytea,2);
 remainder |  item
-----------+--------
 \x        | [2, 3]
(1 row)
```

[Source code:](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_array.sql#L1)

```sql
CREATE OR REPLACE FUNCTION cbor.next_array(cbor bytea, item_count integer)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    next_array.cbor AS remainder,
    next_array.item_count,
    jsonb_build_array() AS jsonb_array
  UNION ALL
  SELECT
    next_item.remainder,
    x.item_count-1,
    x.jsonb_array || jsonb_build_array(next_item.item)
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) ON TRUE
  WHERE x.item_count > 0
)
SELECT ROW(x.remainder, x.jsonb_array) FROM x WHERE x.item_count = 0
$$;
```

<h3 id="next-map"><code>cbor.next_map(cbor bytea, item_count integer) → cbor.next_state</code></h3>

Decodes *item_count* pair of key/value CBOR items from the beginning of the *cbor* [bytea] value.

The returned *item* will be a *jsonb object*, and the *remainder* will contain the CBOR data left to process,
after having processed all the CBOR items for the map.

Example:

```sql
SELECT * FROM cbor.next_map('\x6161016162820203'::bytea,2);
 remainder |         item
-----------+-----------------------
 \x        | {"a": 1, "b": [2, 3]}
(1 row)
```

[Source code:](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/next_map.sql#L1)


```sql
CREATE OR REPLACE FUNCTION cbor.next_map(cbor bytea, item_count integer)
RETURNS cbor.next_state
IMMUTABLE
LANGUAGE sql
AS $$
WITH RECURSIVE x AS (
  SELECT
    next_map.cbor AS remainder,
    next_map.item_count,
    jsonb_build_object() AS map
  UNION ALL
  SELECT
    map_value.remainder,
    x.item_count-1,
    x.map || jsonb_build_object(map_key.item#>>'{}', map_value.item)
  FROM x
  JOIN LATERAL cbor.next_item(x.remainder) AS map_key ON TRUE
  JOIN LATERAL cbor.next_item(map_key.remainder) AS map_value ON TRUE
  WHERE x.item_count > 0
)
SELECT ROW(x.remainder, x.map) FROM x WHERE x.item_count = 0
$$;
```
