import 'dart:typed_data';

import 'package:dbart/src/binary/binary_reader.dart';
import 'package:dbart/src/binary/binary_writer.dart';
import 'package:dbart/src/database/collection/collection_def.dart';
import 'package:dbart/src/struct/indexable_skip_list.dart';
import 'package:dbart/src/utils/utils.dart';

// typedef Position = int;

/// Contains the data from an index file
final class Index<K extends Comparable> {
  final IndexableSkipList<K, int> _skipList;
  final CollectionIndex indexDefinition;

  Index({
    required this.indexDefinition,
    Comparator<K>? comparator,
  }) : _skipList = IndexableSkipList<K, int>(comparator ?? Comparable.compare);

  /// Retrieves the position of an entity in the storage
  @preferInline
  int? getPosition(K key) {
    return _skipList.get(key);
  }

  @preferInline
  void insert(K key, int position) {
    _skipList.insert(key, position);
  }

  void mergeBuffer(Uint8List buffer) {
    final reader = BinaryReader(buffer);
    final totalEntries = reader.readUint32();
    dynamic Function() readKey = switch (K) {
      const (String) => reader.readString,
      const (int) => reader.readInt32,
      const (double) => reader.readDouble,
      const (bool) => reader.readBool,
      const (Uint8List) => reader.readUint8List,
      _ => throw "Unable to read key of type $K"
    };

    for (int i = 0; i < totalEntries; i++) {
      final key = readKey();
      final value = reader.readUint32();
      _skipList.insert(key, value);
    }
  }

  Uint8List toBuffer() {
    final writer = BinaryWriter(4 * _skipList.length);
    writer.writeUint32(_skipList.length);
    for (final (key, value) in _skipList.entries) {
      writer.write(key);
      writer.writeUint32(value);
    }

    return writer.takeBytes();
  }
}
