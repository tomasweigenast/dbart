import 'package:dbart/src/database/collection/collection.dart';
import 'package:dbart/src/database/type_converter.dart';
import 'package:dbart/src/storage_manager/data_bucket.dart';
import 'package:dbart/src/storage_manager/storage_manager.dart';

final class CollectionImpl<K extends Comparable, V> implements Collection<K, V> {
  final StorageManager storage;
  final TypeConverter<V> typeConverter;
  final DataBucket dataBucket;

  CollectionImpl({
    required this.storage,
    required this.typeConverter,
    required this.dataBucket,
  });

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> delete(K key) => dataBucket.deleteAll([key]);

  @override
  Future<void> deleteAll(List<K> keys) => dataBucket.deleteAll(keys);

  @override
  Future<V?> get(K key) async {
    final value = await dataBucket.getEntry(key);
    if (value == null) return null;

    return typeConverter.fromDatabase(value);
  }

  @override
  Future<void> insert(K key, V value) => dataBucket.insertAll(
        {key: typeConverter.toDatabase(value)},
      );

  @override
  Future<void> insertAll(Map<K, V> values) =>
      dataBucket.insertAll(values.map((key, value) => MapEntry(key, typeConverter.toDatabase(value))));
}
