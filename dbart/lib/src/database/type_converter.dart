/// Used to convert type [T] to a Map<String, dynamic> and vice-versa
abstract interface class TypeConverter<T> {
  Map<String, dynamic> toDatabase(T value);
  T fromDatabase(Map<String, dynamic> data);
}
