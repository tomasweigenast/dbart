import 'package:dbart/src/database/type_converter.dart';

final class CollectionDefinition<T> {
  final String? name;
  final List<CollectionIndex<T>> indexes;
  final TypeConverter<T> converter;

  const CollectionDefinition({
    required this.converter,
    this.name,
    this.indexes = const [],
  });
}

final class CollectionIndex<T> {
  final String name;
  final Set<String> fields;
  final bool descending;
  final Comparator? comparator;

  const CollectionIndex({
    required this.name,
    required this.fields,
    this.descending = false,
    this.comparator,
  });
}
