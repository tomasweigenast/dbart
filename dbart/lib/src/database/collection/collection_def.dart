part of '../database.dart';

final class CollectionDefinition<K extends Comparable, V> {
  final String name;
  final List<Index> indexes;
  final TypeConverter<V> converter;
  final Collection<K, V> collection;

  CollectionDefinition({
    required this.converter,
    required this.name,
    required this.collection,
    this.indexes = const [],
  });
}

final class CollectionIndex<K extends Comparable> {
  final String name;
  final Set<String> fields;
  final bool descending;
  final Comparator<K>? comparator;

  const CollectionIndex({
    required this.name,
    required this.fields,
    this.descending = false,
    this.comparator,
  });
}
