import 'package:dbart/src/backend/backend_base.dart';
import 'package:dbart/src/binary/binary_reader.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/storage_manager/storage_manager.dart';

/// A [DataBucket] provides access to data files and entries.
/// Also it parses an entry back to a [Map<String, dynamic>].
final class DataBucket {
  final BackendBase backend;
  final String collectionName;
  final String dbName;
  final KeyType keyType;
  final Map<String, Index> indexes;

  DataBucket(this.backend, this.dbName, this.collectionName, this.keyType, this.indexes);

  /// Retrieves an entry at the specified [position] and then parses it.
  Future<Map<String, dynamic>?> getEntry(dynamic key) async {
    final position = indexes[kIdIndexName]!.getPosition(key);
    if (position == null) return null;

    final entry = await backend.getEntryAt(dbName, position, keyType);
    if (entry == null) return null;

    // Decode entry
    final reader = BinaryReader(entry.data);
    return reader.decodeEntry();
  }

  Future<void> deleteAll(List<dynamic> keys) async {
    // TODO: implement transaction
    for (var key in keys) {
      await backend.appendEntry(collectionName, Entry.deleted(key));
    }

    // TODO: remove data from indexes
  }

  Future<void> insertAll(Map<dynamic, Map<String, dynamic>> entries) async {
    // TODO: implement txn
    for (final entry in entries.entries) {
      entry.value[kIdIndexName] = entry.key;
      int position = await backend.appendEntry(collectionName, Entry.fromData(entry.key, entry.value));

      // update indexes
      for (final MapEntry(value: index) in indexes.entries) {
        // todo(tomas): joining with an underscore is a terrible idea for composite indexes, but fix later
        final indexValues = index.indexDefinition.fields.map((e) => entry.value[e]).toList(growable: false).join("_");
        index.insert(indexValues, position);
      }
    }

    // TODO: dump indexes to file
  }
}
