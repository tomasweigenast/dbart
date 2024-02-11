import 'package:dbart/src/binary/binary_reader.dart';
import 'package:dbart/src/binary/spec.dart';

/// Contains information about a data page
final class DataHeaderPage {
  /// The database version
  final int version;

  /// The key type of the entries
  final KeyType keyType;

  DataHeaderPage({
    required this.version,
    required this.keyType,
  });

  factory DataHeaderPage.fromBuffer(BinaryReader reader) {
    return DataHeaderPage(
      version: reader.readByte(),
      keyType: KeyType.values[reader.readByte()],
    );
  }
}
