abstract interface class Collection<K extends Comparable, V> {
  Future<V?> get(K key);
  Future<void> insert(K key, V value);
  Future<void> insertAll(Map<K, V> values);
  Future<void> delete(K key);
  Future<void> deleteAll(List<K> keys);
  Future<void> clear();
}
