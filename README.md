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
1. [Examples](#examples)
    1. [Positive/Unsigned integer (major type 0)](#positive-unsigned-integer)
        1. [Additional information 0..23](#positive-unsigned-integer-0-23)
        1. [Additional information 24](#positive-unsigned-integer-24)
        1. [Additional information 25](#positive-unsigned-integer-25)
        1. [Additional information 26](#positive-unsigned-integer-26)
        1. [Additional information 27](#positive-unsigned-integer-27)
    1. [Negative integer (major type 1)](#negative-integer)
        1. [Additional information 0..23](#negative-integer-0-23)
        1. [Additional information 24](#negative-integer-24)
        1. [Additional information 25](#negative-integer-25)
        1. [Additional information 26](#negative-integer-26)
        1. [Additional information 27](#negative-integer-27)
    1. [Byte string (major type 2)](#byte-string)
        1. [Additional information 0..23](#byte-string-0-23)
        1. [Additional information 24](#byte-string-24)
        1. [Additional information 25](#byte-string-25)
        1. [Additional information 26](#byte-string-26)
        1. [Additional information 27](#byte-string-27)
        1. [Additional information 31](#byte-string-31)
    1. [Text string (major type 3)](#text-string)
        1. [Additional information 0..23](#text-string-0-23)
        1. [Additional information 24](#text-string-24)
        1. [Additional information 25](#text-string-25)
        1. [Additional information 26](#text-string-26)
        1. [Additional information 27](#text-string-27)
        1. [Additional information 31](#text-string-31)
    1. [Array of data items (major type 4)](#array-of-data-items)
        1. [Additional information 0..23](#array-of-data-items-0-23)
        1. [Additional information 24](#array-of-data-items-24)
        1. [Additional information 25](#array-of-data-items-25)
        1. [Additional information 26](#array-of-data-items-26)
        1. [Additional information 27](#array-of-data-items-27)
        1. [Additional information 31](#array-of-data-items-31)
    1. [Map of pairs of data items (major type 5)](#map-of-pairs-of-data-items)
        1. [Additional information 0..23](#map-of-pairs-of-data-items-0-23)
        1. [Additional information 24](#map-of-pairs-of-data-items-24)
        1. [Additional information 25](#map-of-pairs-of-data-items-25)
        1. [Additional information 26](#map-of-pairs-of-data-items-26)
        1. [Additional information 27](#map-of-pairs-of-data-items-27)
        1. [Additional information 31](#map-of-pairs-of-data-items-31)
    1. [Semantic tag (major type 6)](#semantic-tag)
    1. [Primitives (major type 7)](#primitives)
        1. [False](#false)
        1. [True](#true)
        1. [Null](#null)
        1. [Undefined](#undefined)
        1. [Simple value](#simple-value)
        1. [IEEE 754 half-precision float](#half-float)
        1. [IEEE 754 single-precision float](#single-float)
        1. [IEEE 754 double-precision float](#double-float)
        1. [IEEE 754 Infinity float](#float-infinity)
        1. [IEEE 754 NaN float](#float-nan)
        1. [Break control code](#break-control-code)

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

Since CBOR is loosely based on JSON, most CBOR data item types can be unambiguously translated to JSON.

The arguably most important feature of CBOR is it's ability to **R**epresent **B**inary **O**bjects in a **C**oncise way, as indicated by its name.
The CBOR type for binary objects is *Byte string* (*major type 2*). Since JSON doesn't have any binary type, such objects are represented either `hex`, `base64` or `base64url` encoded JSON *text*, controlled via the *encode_binary_format* input parameter.

Binary objects is the only special case which are converted even not being part of JSON.
If any other CBOR items of types not part of JSON are encountered, the default is to raise an exception.

[Undefined]: https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/undefined_value.sql#L1
[Infinity]: https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/infinity_value.sql#L1
[NaN]: https://github.com/truthly/pg-cbor/blob/master/FUNCTIONS/nan_value.sql#L1
[major,additional]: https://en.wikipedia.org/wiki/CBOR#Major_type_and_additional_type_handling_in_each_data_item
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
which can take any value accepted by the built-in `encode()` function, such as `'hex'`, `'base64'`, and also `base64url`.

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

By default, binary strings are encoded as `hex`. If you rather want `base64` or `base64url`, use the *encode_binary_format* parameter:

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

<h2 id="examples">8. Examples</h2>

<h3 id="positive-unsigned-integer">Positive/Unsigned integer (major type 0)</h3>

<h4 id="positive-unsigned-integer-0-23">Additional information 0..23</h3>

Tiny Field Encoding.
Additional information is the integer itself.

```sql
SELECT cbor.to_jsonb('\x00');
 to_jsonb
----------
 0
(1 row)

SELECT cbor.to_jsonb('\x17');
 to_jsonb
----------
 23
(1 row)
```

<h4 id="positive-unsigned-integer-24">Additional information 24</h3>

Short Field Encoding.
Next byte is uint8_t in data value section.

```sql
SELECT cbor.to_jsonb('\x182f');
 to_jsonb
----------
 47
(1 row)
```

<h4 id="positive-unsigned-integer-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes uint16_t in data value section.

```sql
SELECT cbor.to_jsonb('\x197a69');
 to_jsonb
----------
 31337
(1 row)
```

<h4 id="positive-unsigned-integer-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes is uint32_t in data value section.

```sql
SELECT cbor.to_jsonb('\x1a3b9aca00');
  to_jsonb
------------
 1000000000
(1 row)
```

<h4 id="positive-unsigned-integer-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes is uint64_t in data value section.
```sql
SELECT cbor.to_jsonb('\x1b8ac7230489e80000');
       to_jsonb
----------------------
 10000000000000000000
(1 row)
```

<h3 id="negative-integer">Negative integer (major type 1)</h3>

<h4 id="negative-integer-0-23">Additional information 0..23</h3>

Tiny Field Encoding.
Additional information - 1 is the integer itself.

```sql
SELECT cbor.to_jsonb('\x20');
 to_jsonb
----------
 -1
(1 row)

SELECT cbor.to_jsonb('\x37');
 to_jsonb
----------
 -24
(1 row)
```

<h4 id="negative-integer-24">Additional information 24</h3>

Short Field Encoding.
Next byte - 1 is uint8_t in data value section.

```sql
SELECT cbor.to_jsonb('\x382e');
 to_jsonb
----------
 -47
(1 row)
```

<h4 id="negative-integer-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes - 1 uint16_t in data value section.

```sql
SELECT cbor.to_jsonb('\x397a68');
 to_jsonb
----------
 -31337
(1 row)
```

<h4 id="negative-integer-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes - 1 is uint32_t in data value section.

```sql
SELECT cbor.to_jsonb('\x3a3b9ac9ff');
  to_jsonb
-------------
 -1000000000
(1 row)
```

<h4 id="negative-integer-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes - 1 is uint64_t in data value section.

```sql
SELECT cbor.to_jsonb('\x3b8ac7230489e7ffff');
       to_jsonb
-----------------------
 -10000000000000000000
(1 row)
```

<h3 id="byte-string">Byte string (major type 2)</h3>

In the examples below, the same 12 bytes string `f09fa7acf09f909863626f72`, will be used.

Since the string is the same, the data length specifier will
also be constant, `12` bytes. It's only the data item header
that varies, where the additional information indicates
how many bytes to read for the data length specifier.

<h4 id="byte-string-0-23">Additional information 0..23</h3>

Short Field Encoding.
The additional information is the data length specifier.

```sql
SELECT cbor.to_jsonb('\x4cf09fa7acf09f909863626f72');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

<h4 id="byte-string-24">Additional information 24</h3>

Long Field Encoding.
Next byte is uint8_t in data length specifier.

```sql
SELECT cbor.to_jsonb('\x580cf09fa7acf09f909863626f72');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

<h4 id="byte-string-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes uint16_t in data value section.

```sql
SELECT cbor.to_jsonb('\x59000cf09fa7acf09f909863626f72');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

<h4 id="byte-string-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes is uint32_t in data value section.

```sql
SELECT cbor.to_jsonb('\x5a0000000cf09fa7acf09f909863626f72');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

<h4 id="byte-string-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes is uint64_t in data value section.

```sql
SELECT cbor.to_jsonb('\x5b000000000000000cf09fa7acf09f909863626f72');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

<h4 id="byte-string-31">Additional information 31</h3>

Indefinite Byte String.

Concatenation of the two definite-length byte strings `"f09fa7acf09f9098"` and `"63626f72"`.

Ends with a Break control code, i.e. a `ff` byte.

```sql
SELECT cbor.to_jsonb('\x5f48f09fa7acf09f90984463626f72ff');
          to_jsonb
----------------------------
 "f09fa7acf09f909863626f72"
(1 row)
```

Concatenation of the two definite-length byte strings `"ff00ff"` and `"00ff00"`.

Both byte strings are 3 bytes, hence the data item header will be hex `43`,
since hex `43` in binary is `01000011` where `010` is the major type (decimal 2),
and `00011` is the additional type (3) meaning 3 bytes.

Ends with a Break control code, i.e. a `ff` byte.

```sql
SELECT cbor.to_jsonb('\x5f43ff00ff4300ff00ff');
          to_jsonb
----------------------------
 "ff00ff00ff00"
(1 row)
```


<h3 id="text-string">Text string (major type 3)</h3>

UTF-8 encoded text string of Unicode characters.

In the examples below, the same text string `"🧬🐘cbor"` will be used.
These 6 Unicode characters occupy `12` bytes when encoded in UTF-8.

Since the string is the same, the data length specifier will
also be constant, `12` bytes. It's only the data item header
that varies, where the additional information indicates
how many bytes to read for the data length specifier.

<h4 id="text-string-0-23">Additional information 0..23</h3>

Short Field Encoding.
The additional information is the data length specifier.

```sql
SELECT cbor.to_jsonb('\x6cf09fa7acf09f909863626f72');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h4 id="text-string-24">Additional information 24</h3>

Long Field Encoding.
Next byte is uint8_t in data length specifier.

```sql
SELECT cbor.to_jsonb('\x780cf09fa7acf09f909863626f72');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h4 id="text-string-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes uint16_t in data value section.

```sql
SELECT cbor.to_jsonb('\x79000cf09fa7acf09f909863626f72');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h4 id="text-string-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes is uint32_t in data value section.

```sql
SELECT cbor.to_jsonb('\x7a0000000cf09fa7acf09f909863626f72');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h4 id="text-string-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes is uint64_t in data value section.

```sql
SELECT cbor.to_jsonb('\x7b000000000000000cf09fa7acf09f909863626f72');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h4 id="text-string-31">Additional information 31</h3>

Indefinite Text String.

Concatenation of the two definite-length text strings `"🧬🐘"` and `"cbor"`.

Ends with a Break control code, i.e. a `ff` byte.

```sql
SELECT cbor.to_jsonb('\x7f68f09fa7acf09f90986463626f72ff');
 to_jsonb
----------
 "🧬🐘cbor"
(1 row)
```

<h3 id="array-of-data-items">Array of data items (major type 4)</h3>

In the examples below, all arrays contain the two text strings `"🧬🐘"` and `"cbor"`.
The *item count specifier* (the number of data items) is therefore 2 in all array examples.
It's only the data item header and how the *item count specifier* is encoded that differs.

<h4 id="array-of-data-items-0-23">Additional information 0..23</h3>

Short Field Encoding.
The additional information is the number of data items in the array.

```sql
SELECT cbor.to_jsonb('\x8268f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h4 id="array-of-data-items-24">Additional information 24</h3>

Long Field Encoding.
Next byte is uint8_t for the number of data items in the array.

```sql
SELECT cbor.to_jsonb('\x980268f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h4 id="array-of-data-items-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes uint16_t for the number of data items in the array.

```sql
SELECT cbor.to_jsonb('\x99000268f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h4 id="array-of-data-items-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes is uint32_t for the number of data items in the array.

```sql
SELECT cbor.to_jsonb('\x9a0000000268f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h4 id="array-of-data-items-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes is uint64_t for the number of data items in the array.

```sql
SELECT cbor.to_jsonb('\x9b000000000000000268f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h4 id="array-of-data-items-31">Additional information 31</h3>

Indefinite Array.

Array of the two definite-length text strings `"🧬🐘"` and `"cbor"`.

Ends with a Break control code, i.e. a `ff` byte.

```sql
SELECT cbor.to_jsonb('\x9f68f09fa7acf09f90986463626f72ff');
    to_jsonb
----------------
 ["🧬🐘", "cbor"]
(1 row)
```

<h3 id="map-of-pairs-of-data-items">Map of pairs of data items (major type 5)</h3>

In the examples below, all maps contain exactly one key `"🧬🐘"` with the value `"cbor"`.
The *item count specifier* (the number of pairs of data items) is therefore 1 in all map examples.
It's only the data item header and how the *item count specifier* is encoded that differs.

<h4 id="map-of-pairs-of-data-items-0-23">Additional information 0..23</h3>

Short Field Encoding.
The additional information is the number of pairs of data items in the map.

```sql
SELECT cbor.to_jsonb('\xa168f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```

<h4 id="map-of-pairs-of-data-items-24">Additional information 24</h3>

Long Field Encoding.
Next byte is uint8_t for the number of pairs of data items in the map.

```sql
SELECT cbor.to_jsonb('\xb80168f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```

<h4 id="map-of-pairs-of-data-items-25">Additional information 25</h3>

Short Field Encoding.
Next 2 bytes uint16_t for the number of pairs of data items in the map.

```sql
SELECT cbor.to_jsonb('\xb9000168f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```

<h4 id="map-of-pairs-of-data-items-26">Additional information 26</h3>

Short Field Encoding.
Next 4 bytes is uint32_t for the number of pairs of data items in the map.

```sql
SELECT cbor.to_jsonb('\xba0000000168f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```

<h4 id="map-of-pairs-of-data-items-27">Additional information 27</h3>

Short Field Encoding.
Next 8 bytes is uint64_t for the number of pairs of data items in the map.

```sql
SELECT cbor.to_jsonb('\xbb000000000000000168f09fa7acf09f90986463626f72');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```

<h4 id="map-of-pairs-of-data-items-31">Additional information 31</h3>

Indefinite Map.

Map of the two definite-length text strings `"🧬🐘"` as key and `"cbor"` as value.

Ends with a Break control code, i.e. a `ff` byte.

```sql
SELECT cbor.to_jsonb('\xbf68f09fa7acf09f90986463626f72ff');
    to_jsonb
----------------
 {"🧬🐘": "cbor"}
(1 row)
```
<h3 id="semantic-tag">Semantic tag (major type 6)</h3>

```sql
SELECT cbor.to_jsonb('\xc074323031332d30332d32315432303a30343a30305a');
        to_jsonb
------------------------
 "2013-03-21T20:04:00Z"
(1 row)
```

```sql
SELECT cbor.to_jsonb('\xc2430a0b0c');
 to_jsonb
----------
 658188
(1 row)
```

```sql
SELECT cbor.to_jsonb('\xc3430a0b0c');
 to_jsonb
----------
 -658189
(1 row)
```

<h3 id="primitives">Primitives (major type 7)</h3>

<h4 id="false">False</h4>

```sql
SELECT cbor.to_jsonb('\xf4');
 to_jsonb
----------
 false
(1 row)
```

<h4 id="true">True</h4>

```sql
SELECT cbor.to_jsonb('\xf5');
 to_jsonb
----------
 true
(1 row)
```

<h4 id="null">Null</h4>

```sql
SELECT cbor.to_jsonb('\xf6');
 to_jsonb
----------
 null
(1 row)
```

<h4 id="undefined">Undefined</h4>

❌ Not part of JSON, see [Undefined].

```sql
SELECT cbor.to_jsonb('\xf7');
ERROR:  Undefined value has no direct analog in JSON.
```

<h4 id="simple-value">Simple value</h4>

```sql
SELECT cbor.to_jsonb('\xf0');
 to_jsonb
----------
 16
(1 row)
```

<h4 id="half-float">IEEE 754 half-precision float</h4>

```sql
SELECT cbor.to_jsonb('\xf93e00');
 to_jsonb
----------
 1.5
(1 row)
```

<h4 id="single-float">IEEE 754 single-precision float</h4>

```sql
SELECT cbor.to_jsonb('\xfa47c35000');
 to_jsonb
----------
 100000
(1 row)
```

<h4 id="double-float">IEEE 754 double-precision float</h4>

```sql
SELECT cbor.to_jsonb('\xfbc010666666666666');
 to_jsonb
----------
 -4.1
(1 row)
```

<h4 id="float-infinity">IEEE 754 Infinity float</h4>

❌ Not part of JSON, see [Infinity].


```sql
SELECT cbor.to_jsonb('\xf97c00');
ERROR:  Infinity value has no direct analog in JSON.
```

<h4 id="float-nan">IEEE 754 NaN float</h4>

❌ Not part of JSON, see [NaN].

```sql
SELECT cbor.to_jsonb('\xf97e00');
ERROR:  NaN value has no direct analog in JSON.
```

<h4 id="break-control-code">Break control code</h4>

❌ Cannot appear when a CBOR item is expected.

```sql
SELECT cbor.to_jsonb('\xff');
ERROR:  "break" stop code appeared where a data item is expected, the enclosing item is not well-formed
```
