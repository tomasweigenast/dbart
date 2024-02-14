import 'package:dbart/src/backend/backend_base.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/database/database.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/storage_manager/data_bucket.dart';
import 'package:path/path.dart' as p;

const kIdIndexName = "__id";

/// Serves as an intermediate between an storage backend and Database.
final class StorageManager {
  final BackendBase _backend;
  final String _dbName;

  StorageManager(this._dbName, this._backend);

  Future<DataBucket> openCollection<K extends Comparable, V>(CollectionDefinition<K, V> def) async {
    final Map<String, Index> indexes = {};

    // load database indexes
    for (final index in def.indexes) {
      final indexName = p.join(_dbName, "${def.name}_${index.indexDefinition.name}");
      final buffer = await _backend.getIndex(indexName);
      index.path = indexName;
      index.mergeBuffer(buffer);
      indexes[index.indexDefinition.name] = index;
    }

    return DataBucket(
      _backend,
      p.join(_dbName, def.name),
      K == String ? KeyType.string : KeyType.int,
      indexes,
    );
  }
}
