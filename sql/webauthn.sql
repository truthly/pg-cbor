--
-- Test decode WebAuthn data
-- This example originates from https://github.com/truthly/pg-webauthn
--
BEGIN;

CREATE EXTENSION IF NOT EXISTS cbor;

\t
\a
SELECT jsonb_pretty(cbor.to_jsonb('\xa363666d74667061636b65646761747453746d74a363616c67266373696758473045022014cc1a5a5bd2d388ed1c653f4002ec49fb026b8ac8b7f7cd53aa776f14803d50022100a25a691226c8f23cc515c502874243faae4b1d0db0578bcb905337a2ee08883263783563815902c1308202bd308201a5a00302010202040a640d98300d06092a864886f70d01010b0500302e312c302a0603550403132359756269636f2055324620526f6f742043412053657269616c203435373230303633313020170d3134303830313030303030305a180f32303530303930343030303030305a306e310b300906035504061302534531123010060355040a0c0959756269636f20414231223020060355040b0c1941757468656e74696361746f72204174746573746174696f6e3127302506035504030c1e59756269636f205532462045452053657269616c203137343332393234303059301306072a8648ce3d020106082a8648ce3d03010703420004a116756eb4f0c7444aaf7d2ea10d11c8f02f492c57e36e050aa17f7c5a30760aa0ef9879203c09c90c96a7e538f607693dcf8f62f09386051bee175964fb631da36c306a302206092b0601040182c40a020415312e332e362e312e342e312e34313438322e312e373013060b2b0601040182e51c0201010404030202243021060b2b0601040182e51c01010404120410c5ef55ffad9a4b9fb580adebafe026d0300c0603551d130101ff04023000300d06092a864886f70d01010b050003820101002d4586276149cbf09483852a5f1db6b816faa0d238062ae78ba33bcaf5aafadbe1c2a79c9e7a5cb5f03e3ac8d6c09ae65968f077690bf0ea29283ab9f11bbc9467def8fa226bfa0893baaaa355b4c2f052d2c8deca598a17db0108f6aef014990a87d5d77971b5be8fd478e62cc0bb964e4b879c0a7b37fa07bc93512b12d0d007f85fa067b7a4173db45fae0bef1e86e234a1d7bd970be72dfed390af1e3703597af11edaeb2f157a99368a033d2517e0b58711386ee74a323c800beacc54e42b22a3b8868e775f48b2a3dedab0ce1ae8dc2b71df891e7832106b1a43f197e838e15a1b51e0f2a23da487c50b280506360bc1d827adf832fbf9a20e8e143a9068617574684461746158c449960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97634500000002c5ef55ffad9a4b9fb580adebafe026d000400f174cf2beb2b3ffd81efa7ea2638581f018ce5e76f634d845fb7346636107f1ea0deb27bdef98cbda24e33cc7cf8344bbb020c5248c985f3c5ba6e169aecb2ca5010203262001215820921c4f63a5df7ad59efb3e90293160885b3e5e30b3182dc85c017772d8fbb015225820503b48f47867d471b2cd73fa9a7214f8a876abdaa0187ac3bc3bd384987f40af'::bytea));

ROLLBACK;