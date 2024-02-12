import 'package:dbart/src/backend/backend_base.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/database/collection/collection.dart';
import 'package:dbart/src/database/collection/collection_def.dart';
import 'package:dbart/src/database/collection/collection_impl.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/storage_manager/data_bucket.dart';

const kIdIndexName = "__id";

/// Serves as an intermediate between an storage backend and Database.
final class StorageManager {
  final BackendBase _backend;
  final String _dbName;

  StorageManager(this._dbName, this._backend);

  Future<Collection<K, V>> openCollection<K extends Comparable, V>(CollectionDefinition<V> def) async {
    // check duplicated index names
    assert(!def.indexes.every((index) => def.indexes.any((element) => index.name == element.name)),
        "Index names cannot be duplicated.");

    assert(K == String || K == int, "Collection primary keys must be of type string or int.");

    final collectionName = def.name ?? "$V".toLowerCase();
    final Map<String, Index> indexes = {};

    // add _id index
    def.indexes.add(CollectionIndex(
      name: kIdIndexName,
      fields: {kIdIndexName},
      descending: false,
      comparator: (a, b) => a.compareTo(b),
    ));

    // load database indexes
    for (final indexDef in def.indexes) {
      final indexName = "${collectionName}_${indexDef.name}";
      final buffer = await _backend.getIndex(indexName);
      final index = Index(indexDefinition: indexDef);
      indexes[indexDef.name] = index..mergeBuffer(buffer);
    }

    return CollectionImpl<K, V>(
      // indexes: indexes,
      storage: this,
      typeConverter: def.converter,
      dataBucket: DataBucket(
        _backend,
        _dbName,
        collectionName,
        K == String ? KeyType.string : KeyType.int,
        indexes,
      ),
    );
  }
}
