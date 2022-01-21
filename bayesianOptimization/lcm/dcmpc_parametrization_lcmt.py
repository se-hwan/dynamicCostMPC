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
    __slots__ = ["Q_diag", "Q_rbf", "Q_alpha", "Q_PN", "test"]

    __typenames__ = ["float", "float", "float", "float", "float"]

    __dimensions__ = [[12], [12], [45], [15], None]

    def __init__(self):
        self.Q_diag = [ 0.0 for dim0 in range(12) ]
        self.Q_rbf = [ 0.0 for dim0 in range(12) ]
        self.Q_alpha = [ 0.0 for dim0 in range(45) ]
        self.Q_PN = [ 0.0 for dim0 in range(15) ]
        self.test = 0.0

    def encode(self):
        buf = BytesIO()
        buf.write(dcmpc_parametrization_lcmt._get_packed_fingerprint())
        self._encode_one(buf)
        return buf.getvalue()

    def _encode_one(self, buf):
        buf.write(struct.pack('>12f', *self.Q_diag[:12]))
        buf.write(struct.pack('>12f', *self.Q_rbf[:12]))
        buf.write(struct.pack('>45f', *self.Q_alpha[:45]))
        buf.write(struct.pack('>15f', *self.Q_PN[:15]))
        buf.write(struct.pack(">f", self.test))

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
        self.Q_rbf = struct.unpack('>12f', buf.read(48))
        self.Q_alpha = struct.unpack('>45f', buf.read(180))
        self.Q_PN = struct.unpack('>15f', buf.read(60))
        self.test = struct.unpack(">f", buf.read(4))[0]
        return self
    _decode_one = staticmethod(_decode_one)

    _hash = None
    def _get_hash_recursive(parents):
        if dcmpc_parametrization_lcmt in parents: return 0
        tmphash = (0xd85190ba4600426d) & 0xffffffffffffffff
        tmphash  = (((tmphash<<1)&0xffffffffffffffff) + (tmphash>>63)) & 0xffffffffffffffff
        return tmphash
    _get_hash_recursive = staticmethod(_get_hash_recursive)
    _packed_fingerprint = None

    def _get_packed_fingerprint():
        if dcmpc_parametrization_lcmt._packed_fingerprint is None:
            dcmpc_parametrization_lcmt._packed_fingerprint = struct.pack(">Q", dcmpc_parametrization_lcmt._get_hash_recursive([]))
        return dcmpc_parametrization_lcmt._packed_fingerprint
    _get_packed_fingerprint = staticmethod(_get_packed_fingerprint)
