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

  Entry.deleted(this.key)
      : data = Uint8List(0),
        deleted = true;

  factory Entry.fromData(dynamic key, Map<String, dynamic> data) {
    final writer = BinaryWriter();
    writer.encodeEntry(data);

    return Entry(
      key: key,
      data: writer.takeBytes(),
      deleted: false,
    );
  }

  Uint8List toBuffer() {
    final writer = BinaryWriter();
    writer.writeEntry(this);
    return writer.takeBytes();
  }
}
