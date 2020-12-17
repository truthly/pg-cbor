#!/bin/sh
#
# This script concatenated documentation text
# together with inlined source code from files
# and writes the output to README.md.
#
# Updates of the documentation are made in this file,
# the Makefile builds the README.md file.
#
cat << 'EOF' > README.md
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
SELECT jsonb_pretty(cbor.to_jsonb('\xa26161016162820203'::bytea));
```

```json
[{"a": 1, "b": [2, 3]}]
```

Source code:

```sql
EOF

cat FUNCTIONS/to_jsonb.sql >> README.md

cat << 'EOF' >> README.md
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
EOF

cat TYPES/next_state.sql >> README.md

cat << 'EOF' >> README.md
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
EOF

cat FUNCTIONS/next_item.sql >> README.md

cat << 'EOF' >> README.md
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
EOF

cat FUNCTIONS/next_array.sql >> README.md

cat << 'EOF' >> README.md
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
EOF

cat FUNCTIONS/next_map.sql >> README.md

cat << 'EOF' >> README.md
```
EOF
