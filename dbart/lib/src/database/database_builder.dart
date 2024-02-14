part of 'database.dart';

final class DatabaseBuilder {
  final Map<String, CollectionDefinition> _collections = {};
  final String _databaseName;

  DatabaseBuilder(String databaseName) : _databaseName = databaseName;

  DatabaseBuilder collection<K extends Comparable, V extends Object>(void Function(CollectionBuilder<K, V> collection) builder) {
    assert(switch (K) { const (String) => true, const (int) => true, _ => false },
        "Collection primary keys must be of type string or int.");

    final colBuilder = CollectionBuilder<K, V>._();
    builder(colBuilder);

    // add the default __id index
    colBuilder._indexes[kIdIndexName] = Index<int>(CollectionIndex<int>(
      name: kIdIndexName,
      fields: {kIdIndexName},
    ));
    _collections[colBuilder.name] = CollectionDefinition<K, V>(
      converter: colBuilder.typeConverter!,
      name: colBuilder.name,
      indexes: colBuilder._indexes.values.toList(growable: false),
      collection: CollectionImpl(),
    );
    return this;
  }

  Future<DBart> open() async {
    final db = DBart._internal(Map<String, CollectionDefinition>.from(_collections));
    await db._create(_databaseName);
    return db;
  }
}

final class CollectionBuilder<K extends Comparable, V extends Object> {
  /// The name of the collection
  late final String name;

  /// The [TypeConverter] to convert [V]
  TypeConverter<V>? typeConverter;

  final Map<String, Index> _indexes = {};
  CollectionBuilder._();

  /// Registers a new index named [name] on [fields]
  CollectionBuilder<K, V> index<TK extends Comparable>({
    required String name,
    required Set<String> fields,
    bool descending = false,
    Comparator<TK>? comparator,
  }) {
    assert(!_indexes.containsKey(name), "Index named $name already exists.");

    assert(
        switch (TK) {
          const (String) => true,
          const (int) => true,
          const (bool) => true,
          const (double) => true,
          _ => false,
        },
        "You can only index on fields of type String, int, bool or double. Maybe you forget to pass the type argument to the method.");

    final def = CollectionIndex<TK>(
      name: name,
      fields: fields,
      comparator: comparator,
      descending: descending,
    );
    _indexes[name] = Index<TK>(def);
    return this;
  }
}
