import 'package:dbart/src/database/collection/collection_def.dart';
import 'package:dbart/src/database/database.dart';
import 'package:dbart/src/database/type_converter.dart';

void main() {
  final db = DBart();
  db.initialize(
    databaseName: "db",
    collections: [
      CollectionDefinition<User>(
        converter: const UserConverter(),
        indexes: [
          CollectionIndex(
            name: "user_name",
            fields: {"name"},
          ),
        ],
      )
    ],
  );
  final collection = db.collection<int, User>();
}

final class User {
  final int id;
  final String name;

  User({required this.id, required this.name});
}

final class UserConverter implements TypeConverter<User> {
  const UserConverter();

  @override
  User fromDatabase(Map<String, dynamic> data) {
    // TODO: implement fromDatabase
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toDatabase(User value) {
    // TODO: implement toDatabase
    throw UnimplementedError();
  }
}
