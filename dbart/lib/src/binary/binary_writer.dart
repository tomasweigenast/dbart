import 'dart:convert';
import 'dart:typed_data';

import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/utils/ext.dart';
import 'package:dbart/src/utils/utils.dart';

const defaultChunkSize = 2048;

final class BinaryWriter {
  final BytesBuilder _bytesBuilder = BytesBuilder(copy: false);
  final int _chunkSize;
  int _offset = 0;
  int _totalSize = 0;
  late Uint8List _buffer;
  late ByteData _bufferView;

  BinaryWriter([int chunkSize = defaultChunkSize]) : _chunkSize = chunkSize;
  @preferInline
  void writeByte(int value) => _bytesBuilder.addByte(value);

  @preferInline
  void writeBool(bool value) => _bytesBuilder.addByte(value ? 1 : 0);

  @preferInline
  void writeUint32(int value) {
    final buffer = Uint8List(4);
    buffer.setUint32(value);
    _bytesBuilder.add(buffer);
  }

  @preferInline
  void writeInt32(int value) {
    final buffer = Uint8List(4);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    data.setInt32(0, value);
    _bytesBuilder.add(buffer);
  }

  @preferInline
  void writeDouble(double value) {
    final buffer = Uint8List(8);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    data.setFloat64(0, value);
    _bytesBuilder.add(buffer);
  }

  @preferInline
  void writeString(String value) {
    final buf = utf8.encode(value);
    writeBytes(buf);
  }

  @preferInline
  void writeKey(dynamic key) {
    assert(key is String || key is int, "keys must be of type String or int.");
    if (key is String) {
      writeString(key);
    } else {
      writeInt32(key);
    }
  }

  void write(dynamic value) {
    switch (value) {
      case String _:
        writeString(value);
        break;

      case int _:
        writeInt32(value);
        break;

      case double _:
        writeDouble(value);
        break;

      case bool _:
        writeBool(value);
        break;

      case Uint8List _:
        writeBytes(value);
        break;

      default:
        throw "Unable to write value of type ${value.runtimeType}";
    }
  }

  void writeBytes(Uint8List value) {
    final len = value.length;
    final buffer = Uint8List(len + 4);
    buffer[0] = (len >> 24) & 0xFF;
    buffer[1] = (len >> 16) & 0xFF;
    buffer[2] = (len >> 8) & 0xFF;
    buffer[3] = len & 0xFF;
    buffer.setRange(4, 4 + len, value);
    _bytesBuilder.add(buffer);
  }

  void writeEntry(Entry entry) {
    final size = 5 + (entry.key is String ? (entry.key as String).length + 4 : 4) + entry.data.length;
    writeUint32(size);
    if (entry.key is String) {
      writeString(entry.key);
    } else {
      writeInt32(entry.key);
    }

    writeBool(entry.deleted);
    writeBytes(entry.data);
  }

  void encodeEntry(Map<String, dynamic> data) {
    data.forEach((key, value) {
      writeString(key);
      _writeValue(value);
    });
  }

  @preferInline
  Uint8List takeBytes() {
    return _bytesBuilder.takeBytes();
  }

  void _writeValue(dynamic value) {
    switch (value) {
      case String _:
        _bytesBuilder.addByte(ValueType.string.index);
        writeString(value);
        break;

      case int _:
        _bytesBuilder.addByte(ValueType.int.index);
        writeInt32(value);
        break;

      case double _:
        _bytesBuilder.addByte(ValueType.double.index);
        writeDouble(value);
        break;

      case bool _:
        _bytesBuilder.addByte(ValueType.bool.index);
        writeBool(value);
        break;

      default:
        if (value is List) {
          _bytesBuilder.addByte(ValueType.list.index);
          writeInt32(value.length);
          for (final element in value) {
            _writeValue(element);
          }
        } else if (value is Map) {
          _bytesBuilder.addByte(ValueType.map.index);
          writeInt32(value.length);
          for (final entry in value.entries) {
            writeString(entry.key);
            _writeValue(entry.value);
          }
        } else {
          throw "Unable to encode value of type ${value.runtimeType}";
        }
    }
  }

  @preferInline
  void _ensure(int size) {
    // if (_chunkSize - _offset < size) {
    //   _totalSize += _offset;
    //   _chunks.add(_buffer);
    //   _offset = 0;
    //   _newBuffer(size);
    // }
  }

  @preferInline
  void _newBuffer([int? newChunkSize]) {
    _buffer = Uint8List(newChunkSize ?? _chunkSize);
    _bufferView = ByteData.view(_buffer.buffer, _buffer.offsetInBytes);
  }
}
