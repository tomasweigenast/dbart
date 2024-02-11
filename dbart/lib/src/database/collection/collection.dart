abstract interface class Collection<K extends Comparable, V> {
  V? get(K key);
  void insert(K key, V value);
  void insertAll(Map<K, V> values);
  void delete(K key);
  void deleteAll(List<K> keys);
  void clear();
}
