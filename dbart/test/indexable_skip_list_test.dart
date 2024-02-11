import 'package:dbart/src/struct/indexable_skip_list.dart';

void main() {
  final list = IndexableSkipList<int, String>(Comparable.compare);
  list.insert(1, "hello");
  list.insert(2, "world");
  list.insert(65, "again2");
  list.insert(3, "halo");
  list.insert(12, "tomas");
  list.insert(65, "again");
  print(list.values.toList());

  final newList = IndexableSkipList<int, String>(Comparable.compare);
  newList.deserialize(list.serialize());
  print(list.serialize());

  print(newList.values.toList());
}
