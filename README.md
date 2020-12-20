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

This project was created as a spin-off from the [🔐🐘webauthn] project,
and is now [used by it](https://github.com/truthly/pg-webauthn/blob/master/FUNCTIONS/cose_ecdha_to_pkcs.sql#L9) to decode [WebAuthn] CBOR objects.

[PostgreSQL]: https://www.postgresql.org/
[CBOR]: https://en.wikipedia.org/wiki/CBOR
[RFC 7049]: https://tools.ietf.org/html/rfc7049
[JSON]: https://en.wikipedia.org/wiki/JSON
[WebAuthn]: https://en.wikipedia.org/wiki/WebAuthn
[🔐🐘webauthn]: https://github.com/truthly/pg-webauthn

<h2 id="dependencies">2. Dependencies</h2>

None.

<h2 id="installation">3. Installation</h2>

Install the `cbor` extension with:

    $ git clone https://github.com/truthly/pg-cbor.git
    $ cd pg-cbor
    $ make
    $ sudo make install
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

Expects exactly one CBOR item on the root level, throws an error otherwise.

If multiple items on the root level is to be expected, see [cbor.to_jsonb_array()] which is designed for this purpose.

This single CBOR item may contain multiple CBOR items, e.g. if it's a CBOR *Array of items* (major type 4) or *Map of pairs of data items* (major type 5).
However, there MUST NOT be multiple CBOR items on the *root level*. If there is, an error will be thrown

**Note:** Since JSON doesn't have any data type for *Byte strings* (CBOR major type 2),
if there are any such items in the CBOR, they will be represented as text.
The textual representation for such items can be controlled via the *encode_binary_format* input parameter,
which can take any value accepted by the built-in `encode()` function, such as `'hex'` and `'base64'`.

[bytea]: https://www.postgresql.org/docs/current/datatype-binary.html

Source code: [FUNCTIONS/to_jsonb.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/to_jsonb.sql#L1)

Basic example:

```sql
SELECT cbor.to_jsonb('\xa26161016162820203'::bytea);
```

```json
{"a": 1, "b": [2, 3]}
```

Real-life example with actual data for a [WebAuthn] CBOR encoded attestation object:

```sql
SELECT jsonb_pretty(cbor.to_jsonb('\xa363666d74667061636b65646761747453746d74a363616c67266373696758473045022014cc1a5a5bd2d388ed1c653f4002ec49fb026b8ac8b7f7cd53aa776f14803d50022100a25a691226c8f23cc515c502874243faae4b1d0db0578bcb905337a2ee08883263783563815902c1308202bd308201a5a00302010202040a640d98300d06092a864886f70d01010b0500302e312c302a0603550403132359756269636f2055324620526f6f742043412053657269616c203435373230303633313020170d3134303830313030303030305a180f32303530303930343030303030305a306e310b300906035504061302534531123010060355040a0c0959756269636f20414231223020060355040b0c1941757468656e74696361746f72204174746573746174696f6e3127302506035504030c1e59756269636f205532462045452053657269616c203137343332393234303059301306072a8648ce3d020106082a8648ce3d03010703420004a116756eb4f0c7444aaf7d2ea10d11c8f02f492c57e36e050aa17f7c5a30760aa0ef9879203c09c90c96a7e538f607693dcf8f62f09386051bee175964fb631da36c306a302206092b0601040182c40a020415312e332e362e312e342e312e34313438322e312e373013060b2b0601040182e51c0201010404030202243021060b2b0601040182e51c01010404120410c5ef55ffad9a4b9fb580adebafe026d0300c0603551d130101ff04023000300d06092a864886f70d01010b050003820101002d4586276149cbf09483852a5f1db6b816faa0d238062ae78ba33bcaf5aafadbe1c2a79c9e7a5cb5f03e3ac8d6c09ae65968f077690bf0ea29283ab9f11bbc9467def8fa226bfa0893baaaa355b4c2f052d2c8deca598a17db0108f6aef014990a87d5d77971b5be8fd478e62cc0bb964e4b879c0a7b37fa07bc93512b12d0d007f85fa067b7a4173db45fae0bef1e86e234a1d7bd970be72dfed390af1e3703597af11edaeb2f157a99368a033d2517e0b58711386ee74a323c800beacc54e42b22a3b8868e775f48b2a3dedab0ce1ae8dc2b71df891e7832106b1a43f197e838e15a1b51e0f2a23da487c50b280506360bc1d827adf832fbf9a20e8e143a9068617574684461746158c449960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97634500000002c5ef55ffad9a4b9fb580adebafe026d000400f174cf2beb2b3ffd81efa7ea2638581f018ce5e76f634d845fb7346636107f1ea0deb27bdef98cbda24e33cc7cf8344bbb020c5248c985f3c5ba6e169aecb2ca5010203262001215820921c4f63a5df7ad59efb3e90293160885b3e5e30b3182dc85c017772d8fbb015225820503b48f47867d471b2cd73fa9a7214f8a876abdaa0187ac3bc3bd384987f40af'::bytea));
```

```json
{
    "fmt": "packed",
    "attStmt": {
        "alg": -7,
        "sig": "3045022014cc1a5a5bd2d388ed1c653f4002ec49fb026b8ac8b7f7cd53aa776f14803d50022100a25a691226c8f23cc515c502874243faae4b1d0db0578bcb905337a2ee088832",
        "x5c": [
            "308202bd308201a5a00302010202040a640d98300d06092a864886f70d01010b0500302e312c302a0603550403132359756269636f2055324620526f6f742043412053657269616c203435373230303633313020170d3134303830313030303030305a180f32303530303930343030303030305a306e310b300906035504061302534531123010060355040a0c0959756269636f20414231223020060355040b0c1941757468656e74696361746f72204174746573746174696f6e3127302506035504030c1e59756269636f205532462045452053657269616c203137343332393234303059301306072a8648ce3d020106082a8648ce3d03010703420004a116756eb4f0c7444aaf7d2ea10d11c8f02f492c57e36e050aa17f7c5a30760aa0ef9879203c09c90c96a7e538f607693dcf8f62f09386051bee175964fb631da36c306a302206092b0601040182c40a020415312e332e362e312e342e312e34313438322e312e373013060b2b0601040182e51c0201010404030202243021060b2b0601040182e51c01010404120410c5ef55ffad9a4b9fb580adebafe026d0300c0603551d130101ff04023000300d06092a864886f70d01010b050003820101002d4586276149cbf09483852a5f1db6b816faa0d238062ae78ba33bcaf5aafadbe1c2a79c9e7a5cb5f03e3ac8d6c09ae65968f077690bf0ea29283ab9f11bbc9467def8fa226bfa0893baaaa355b4c2f052d2c8deca598a17db0108f6aef014990a87d5d77971b5be8fd478e62cc0bb964e4b879c0a7b37fa07bc93512b12d0d007f85fa067b7a4173db45fae0bef1e86e234a1d7bd970be72dfed390af1e3703597af11edaeb2f157a99368a033d2517e0b58711386ee74a323c800beacc54e42b22a3b8868e775f48b2a3dedab0ce1ae8dc2b71df891e7832106b1a43f197e838e15a1b51e0f2a23da487c50b280506360bc1d827adf832fbf9a20e8e143a90"
        ]
    },
    "authData": "49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97634500000002c5ef55ffad9a4b9fb580adebafe026d000400f174cf2beb2b3ffd81efa7ea2638581f018ce5e76f634d845fb7346636107f1ea0deb27bdef98cbda24e33cc7cf8344bbb020c5248c985f3c5ba6e169aecb2ca5010203262001215820921c4f63a5df7ad59efb3e90293160885b3e5e30b3182dc85c017772d8fbb015225820503b48f47867d471b2cd73fa9a7214f8a876abdaa0187ac3bc3bd384987f40af"
}
```

By default, binary strings are encoded as `hex`. If you rather want `base64`, use the *encode_binary_format* parameter:

```sql
SELECT jsonb_pretty(cbor.to_jsonb(
  cbor := '\xa363666d74667061636b65646761747453746d74a363616c67266373696758473045022014cc1a5a5bd2d388ed1c653f4002ec49fb026b8ac8b7f7cd53aa776f14803d50022100a25a691226c8f23cc515c502874243faae4b1d0db0578bcb905337a2ee08883263783563815902c1308202bd308201a5a00302010202040a640d98300d06092a864886f70d01010b0500302e312c302a0603550403132359756269636f2055324620526f6f742043412053657269616c203435373230303633313020170d3134303830313030303030305a180f32303530303930343030303030305a306e310b300906035504061302534531123010060355040a0c0959756269636f20414231223020060355040b0c1941757468656e74696361746f72204174746573746174696f6e3127302506035504030c1e59756269636f205532462045452053657269616c203137343332393234303059301306072a8648ce3d020106082a8648ce3d03010703420004a116756eb4f0c7444aaf7d2ea10d11c8f02f492c57e36e050aa17f7c5a30760aa0ef9879203c09c90c96a7e538f607693dcf8f62f09386051bee175964fb631da36c306a302206092b0601040182c40a020415312e332e362e312e342e312e34313438322e312e373013060b2b0601040182e51c0201010404030202243021060b2b0601040182e51c01010404120410c5ef55ffad9a4b9fb580adebafe026d0300c0603551d130101ff04023000300d06092a864886f70d01010b050003820101002d4586276149cbf09483852a5f1db6b816faa0d238062ae78ba33bcaf5aafadbe1c2a79c9e7a5cb5f03e3ac8d6c09ae65968f077690bf0ea29283ab9f11bbc9467def8fa226bfa0893baaaa355b4c2f052d2c8deca598a17db0108f6aef014990a87d5d77971b5be8fd478e62cc0bb964e4b879c0a7b37fa07bc93512b12d0d007f85fa067b7a4173db45fae0bef1e86e234a1d7bd970be72dfed390af1e3703597af11edaeb2f157a99368a033d2517e0b58711386ee74a323c800beacc54e42b22a3b8868e775f48b2a3dedab0ce1ae8dc2b71df891e7832106b1a43f197e838e15a1b51e0f2a23da487c50b280506360bc1d827adf832fbf9a20e8e143a9068617574684461746158c449960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97634500000002c5ef55ffad9a4b9fb580adebafe026d000400f174cf2beb2b3ffd81efa7ea2638581f018ce5e76f634d845fb7346636107f1ea0deb27bdef98cbda24e33cc7cf8344bbb020c5248c985f3c5ba6e169aecb2ca5010203262001215820921c4f63a5df7ad59efb3e90293160885b3e5e30b3182dc85c017772d8fbb015225820503b48f47867d471b2cd73fa9a7214f8a876abdaa0187ac3bc3bd384987f40af'::bytea,
  encode_binary_format := 'base64'
));
```

```json
{
    "fmt": "packed",
    "attStmt": {
        "alg": -7,
        "sig": "MEUCIBTMGlpb0tOI7RxlP0AC7En7AmuKyLf3zVOqd28UgD1QAiEAolppEibI8jzFFcUCh0JD+q5L\nHQ2wV4vLkFM3ou4IiDI=",
        "x5c": [
            "MIICvTCCAaWgAwIBAgIECmQNmDANBgkqhkiG9w0BAQsFADAuMSwwKgYDVQQDEyNZdWJpY28gVTJG\nIFJvb3QgQ0EgU2VyaWFsIDQ1NzIwMDYzMTAgFw0xNDA4MDEwMDAwMDBaGA8yMDUwMDkwNDAwMDAw\nMFowbjELMAkGA1UEBhMCU0UxEjAQBgNVBAoMCVl1YmljbyBBQjEiMCAGA1UECwwZQXV0aGVudGlj\nYXRvciBBdHRlc3RhdGlvbjEnMCUGA1UEAwweWXViaWNvIFUyRiBFRSBTZXJpYWwgMTc0MzI5MjQw\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoRZ1brTwx0RKr30uoQ0RyPAvSSxX424FCqF/fFow\ndgqg75h5IDwJyQyWp+U49gdpPc+PYvCThgUb7hdZZPtjHaNsMGowIgYJKwYBBAGCxAoCBBUxLjMu\nNi4xLjQuMS40MTQ4Mi4xLjcwEwYLKwYBBAGC5RwCAQEEBAMCAiQwIQYLKwYBBAGC5RwBAQQEEgQQ\nxe9V/62aS5+1gK3rr+Am0DAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQAtRYYnYUnL\n8JSDhSpfHba4Fvqg0jgGKueLozvK9ar62+HCp5yeely18D46yNbAmuZZaPB3aQvw6ikoOrnxG7yU\nZ974+iJr+giTuqqjVbTC8FLSyN7KWYoX2wEI9q7wFJkKh9XXeXG1vo/UeOYswLuWTkuHnAp7N/oH\nvJNRKxLQ0Af4X6Bnt6QXPbRfrgvvHobiNKHXvZcL5y3+05CvHjcDWXrxHtrrLxV6mTaKAz0lF+C1\nhxE4budKMjyAC+rMVOQrIqO4ho53X0iyo97asM4a6Nwrcd+JHngyEGsaQ/GX6DjhWhtR4PKiPaSH\nxQsoBQY2C8HYJ634Mvv5og6OFDqQ"
        ]
    },
    "authData": "SZYN5YgOjGh0NBcPZHZgW4/krrmihjLHmVzzuoMdl2NFAAAAAsXvVf+tmkuftYCt66/gJtAAQA8X\nTPK+srP/2B76fqJjhYHwGM5edvY02EX7c0ZjYQfx6g3rJ73vmMvaJOM8x8+DRLuwIMUkjJhfPFum\n4WmuyyylAQIDJiABIVggkhxPY6XfetWe+z6QKTFgiFs+XjCzGC3IXAF3ctj7sBUiWCBQO0j0eGfU\ncbLNc/qachT4qHar2qAYesO8O9OEmH9Arw=="
}
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

Source code: [FUNCTIONS/to_jsonb_array.sql](https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/to_jsonb_array.sql#L1)

Examples:

```sql
SELECT cbor.to_jsonb_array('\xa26161016162820203'::bytea);
```

```json
[{"a": 1, "b": [2, 3]}]
```

```sql
SELECT cbor.to_jsonb_array('\xa26161016162820203a26161016162820203'::bytea);
```

```json
[{"a": 1, "b": [2, 3]}, {"a": 1, "b": [2, 3]}]
```

```sql
SELECT cbor.to_jsonb_array('\x'::bytea);
```

```json
[]
```

```sql
-- Function returns a SQL NULL (not JSON null) if cbor bytea input is NULL
SELECT cbor.to_jsonb_array(NULL);
 to_jsonb_array
----------------

(1 row)
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
SELECT * FROM cbor.next_item('\x0a0b0c'::bytea,'hex');
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
SELECT * FROM cbor.next_array('\x0203'::bytea,2,'hex');
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
SELECT * FROM cbor.next_map('\x6161016162820203'::bytea,2,'hex');
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
