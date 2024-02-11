import 'dart:convert';
import 'dart:typed_data';

import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/utils/utils.dart';

import 'spec.dart';

final class BinaryReader {
  final Uint8List _buffer;
  final ByteData _view;
  int _offset = 0;

  BinaryReader(Uint8List buffer)
      : _buffer = buffer,
        _view = ByteData.view(buffer.buffer, buffer.offsetInBytes);

  @preferInline
  String readString() {
    final buffer = readUint8List();
    return utf8.decode(buffer);
  }

  @preferInline
  int readByte() => _buffer[_offset++];

  int readInt32() {
    final value = _view.getInt32(_offset);
    _offset += 4;
    return value;
  }

  int readUint32() {
    final value = _view.getUint32(_offset);
    _offset += 4;
    return value;
  }

  @preferInline
  bool readBool() => readByte() == 1;

  /// Reads a [Uint8List]. It returns a view to the underlying buffer,
  /// so modifying this buffer may modify other data.
  Uint8List readUint8List() {
    int length = _view.getUint32(_offset);
    _offset += 4;

    final buffer = Uint8List.sublistView(_buffer, _offset, _offset + length);
    _offset += length;
    return buffer;
  }

  Entry readEntry(KeyType keyType) {
    dynamic key;
    switch (keyType) {
      case KeyType.string:
        key = readString();
        break;

      case KeyType.int:
        key = readInt32();
        break;
    }

    bool deleted = readBool();
    final data = readUint8List();
    return Entry(
      key: key,
      deleted: deleted,
      data: data,
    );
  }
}
