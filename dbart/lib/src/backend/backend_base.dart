import 'dart:typed_data';

import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/index/data_index.dart';

/// Provides an interface that must implement every platform
/// to provide low level access to data.
abstract interface class BackendBase {
  /// Retrieves a index buffer by [name].
  Future<Uint8List> getIndex(String name);

  /// Writes an index named [name].
  Future<void> writeIndex(String name, Index index);

  /// Retrieves an entry at the specified [position] from the [name] database.
  Future<Entry?> getEntryAt(String name, int position, KeyType keyType);

  /// Inserts an [entry] at the specified [position] in the [name] database.
  Future<void> setEntryAt(String name, int position, Entry entry);

  /// Adds an [entry] at the end of the database.
  ///
  /// Returns the start position where the [entry] was written.
  Future<int> appendEntry(String name, Entry entry);
}
