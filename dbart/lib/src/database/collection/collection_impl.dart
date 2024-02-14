part of '../database.dart';

final class CollectionImpl<K extends Comparable, V> implements Collection<K, V> {
  late final StorageManager storage;
  late final TypeConverter<V> typeConverter;
  late final DataBucket dataBucket;

  void init({
    required StorageManager storage,
    required TypeConverter<V> typeConverter,
    required DataBucket dataBucket,
  }) {
    this.storage = storage;
    this.typeConverter = typeConverter;
    this.dataBucket = dataBucket;
  }

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

  @override
  Future<List<V>> find(String key, value) async {
    final index = dataBucket.indexWhere(key);
    final positions = index.valuesFromKey(value);
    final results = <V>[];
    for (final pos in positions) {
      final entry = await dataBucket.getEntryAt(pos);
      if (entry == null) continue;

      results.add(typeConverter.fromDatabase(entry));
      break;
    }

    return results;
  }
}
