import 'dart:io';

import 'package:dbart/src/database/database.dart';
import 'package:dbart/src/database/type_converter.dart';

Future<void> main() async {
  try {
    Directory("tmp").deleteSync(recursive: true);
  } catch (_) {}
  Directory("tmp").createSync(recursive: true);

  final databaseBuilder = DatabaseBuilder("tmp");
  databaseBuilder.collection<int, User>((collection) {
    collection.name = "users";
    collection.typeConverter = const UserConverter();
    collection.index<String>(name: "users_user_name", fields: {"name"});
  });

  final db = await databaseBuilder.open();
  print(db.name);

  final collection = db.collection<int, User>("users");
  await collection.insert(0, User(id: 0, name: "Tomas"));
  await collection.insert(1, User(id: 1, name: "Matias"));
  await collection.insert(2, User(id: 2, name: "Alex"));

  final value = await collection.get(1);
  print(value);

  final find = await collection.find("name", "Matias");
  print(find);
}

final class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  @override
  String toString() => "User(id: $id, name: $name)";
}

final class UserConverter implements TypeConverter<User> {
  const UserConverter();

  @override
  User fromDatabase(Map<String, dynamic> data) {
    return User(
      id: data["id"],
      name: data["name"],
    );
  }

  @override
  Map<String, dynamic> toDatabase(User value) => {
        "id": value.id,
        "name": value.name,
      };
}
