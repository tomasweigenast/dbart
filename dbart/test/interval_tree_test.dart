import 'package:dbart/src/struct/interval_tree.dart';

void main() {
  var tree = IntervalTree();
  tree.insert(5); // Inserting entities with IDs
  tree.insert(10);
  tree.insert(3);
  tree.insert(20);
  tree.insert(7);

  var entityIdToSearch = 8;
  var intervalsContainingEntityId = tree.findInterval(entityIdToSearch);

  print("Intervals containing entity $entityIdToSearch:");
  for (var interval in intervalsContainingEntityId) {
    print("[$interval, $interval]");
  }
}
