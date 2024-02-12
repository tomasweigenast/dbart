import 'package:dbart/src/backend/io/io_backend.dart';
import 'package:dbart/src/database/collection/collection.dart';
import 'package:dbart/src/database/collection/collection_def.dart';
import 'package:dbart/src/storage_manager/storage_manager.dart';

final class DBart {
  final Map<String?, Collection> _collections = {};
  StorageManager? _storage;

  DBart();

  /// Initializes the database.
  ///
  /// [databaseName] is the path to the database if in Dart VM, otherwise just the name.
  /// [collections] are the collections of the database.
  ///
  /// Index migrations are automatically handled.
  Future<void> initialize({
    required String databaseName,
    required List<CollectionDefinition> collections,
  }) async {
    if (_storage != null) return;

    _storage = StorageManager(databaseName, IOBackend());
    for (final def in collections) {
      final collection = await _storage!.openCollection(def);
      _collections[def.name] = collection;
    }
  }

  /// Retrieves a collection.
  Collection<K, V> collection<K extends Comparable, V>([String? name]) {
    final collection = _collections[name];
    if (collection == null) throw Exception("Collection${name == null ? ' ' : ' "$name"'} does not exist.");

    return collection as Collection<K, V>;
  }
}
