import 'dart:typed_data';

import 'package:dbart/src/binary/binary_writer.dart';

/// An entry contains information about an entity written to a file
class Entry {
  final dynamic key;
  final Uint8List data;
  final bool deleted;

  Entry({
    required this.key,
    required this.data,
    required this.deleted,
  }) : assert(key is String || key is int, "key must be of type String or int.");

  Uint8List toBuffer() {
    final writer = BinaryWriter();
    writer.writeEntry(this);
    return writer.takeBytes();
  }
}
