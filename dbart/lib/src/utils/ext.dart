import 'dart:typed_data';

extension Uint8ListX on Uint8List {
  int uint32([int start = 0]) {
    int offset = start;
    int uint32Value = (this[offset++] << 24) | (this[offset++] << 16) | (this[offset++] << 8) | this[offset++];
    return uint32Value;
  }

  void setUint32(int value, [int start = 0]) {
    int offset = start;
    this[offset++] = (value >> 24) & 0xFF;
    this[offset++] = (value >> 16) & 0xFF;
    this[offset++] = (value >> 8) & 0xFF;
    this[offset++] = value & 0xFF;
  }
}
