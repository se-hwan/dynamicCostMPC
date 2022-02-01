"""LCM type definitions
This file automatically generated by lcm.
DO NOT MODIFY BY HAND!!!!
"""

try:
    import cStringIO.StringIO as BytesIO
except ImportError:
    from io import BytesIO
import struct

class dcmpc_parametrization_lcmt(object):
    __slots__ = ["Q_diag"]

    __typenames__ = ["float"]

    __dimensions__ = [[12]]

    def __init__(self):
        self.Q_diag = [ 0.0 for dim0 in range(12) ]

    def encode(self):
        buf = BytesIO()
        buf.write(dcmpc_parametrization_lcmt._get_packed_fingerprint())
        self._encode_one(buf)
        return buf.getvalue()

    def _encode_one(self, buf):
        buf.write(struct.pack('>12f', *self.Q_diag[:12]))

    def decode(data):
        if hasattr(data, 'read'):
            buf = data
        else:
            buf = BytesIO(data)
        if buf.read(8) != dcmpc_parametrization_lcmt._get_packed_fingerprint():
            raise ValueError("Decode error")
        return dcmpc_parametrization_lcmt._decode_one(buf)
    decode = staticmethod(decode)

    def _decode_one(buf):
        self = dcmpc_parametrization_lcmt()
        self.Q_diag = struct.unpack('>12f', buf.read(48))
        return self
    _decode_one = staticmethod(_decode_one)

    _hash = None
    def _get_hash_recursive(parents):
        if dcmpc_parametrization_lcmt in parents: return 0
        tmphash = (0x2e2a7093d8134a50) & 0xffffffffffffffff
        tmphash  = (((tmphash<<1)&0xffffffffffffffff) + (tmphash>>63)) & 0xffffffffffffffff
        return tmphash
    _get_hash_recursive = staticmethod(_get_hash_recursive)
    _packed_fingerprint = None

    def _get_packed_fingerprint():
        if dcmpc_parametrization_lcmt._packed_fingerprint is None:
            dcmpc_parametrization_lcmt._packed_fingerprint = struct.pack(">Q", dcmpc_parametrization_lcmt._get_hash_recursive([]))
        return dcmpc_parametrization_lcmt._packed_fingerprint
    _get_packed_fingerprint = staticmethod(_get_packed_fingerprint)

