import 'package:dbart/src/backend/io/io_backend.dart';
import 'package:dbart/src/database/collection/collection.dart';
import 'package:dbart/src/database/type_converter.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/storage_manager/data_bucket.dart';
import 'package:dbart/src/storage_manager/storage_manager.dart';

part 'collection/collection_impl.dart';
part 'collection/collection_def.dart';
part 'database_builder.dart';

final class DBart {
  final Map<String?, CollectionDefinition> _collections;
  final Map<String, Collection> _openedCollections = {};
  StorageManager? _storage;
  String? _name;

  String get name => _name!;

  DBart._internal(this._collections);

  Future<void> _create(String databaseName) async {
    if (_storage != null) return;
    _name = databaseName;

    _storage = StorageManager(databaseName, IOBackend());
    for (final collection in _collections.values) {
      final dataBucket = await _storage!.openCollection(collection);
      (collection.collection as CollectionImpl).init(
        dataBucket: dataBucket,
        storage: _storage!,
        typeConverter: collection.converter,
      );
      _openedCollections[collection.name] = collection.collection;
    }
  }

  /// Retrieves a collection.
  Collection<K, V> collection<K extends Comparable, V>([String? name]) {
    final collection = _openedCollections[name];
    if (collection == null) throw Exception("Collection${name == null ? ' ' : ' "$name"'} does not exist.");

    return collection as Collection<K, V>;
  }
}
