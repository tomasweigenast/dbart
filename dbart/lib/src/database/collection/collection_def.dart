final class CollectionDefinition {
  final String? name;
  final List<CollectionIndex> indexes;

  const CollectionDefinition({
    this.name,
    this.indexes = const [],
  });
}

final class CollectionIndex {
  final String name;
  final Set<String> fields;
  final bool descending;

  const CollectionIndex({
    required this.name,
    required this.fields,
    this.descending = false,
  });
}
