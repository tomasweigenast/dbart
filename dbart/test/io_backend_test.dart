import 'dart:convert';
import 'dart:io';

import 'package:dbart/src/backend/io/io_backend.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/utils/ext.dart';
import 'package:test/test.dart';

void main() {
  group("IOBackend tests", () {
    setUpAll(() => Directory("tmp").createSync());
    tearDownAll(() => Directory("tmp").deleteSync(recursive: true));

    test("write index", () async {
      final indexContent = utf8.encode("fake index content");
      final index = Index(buffer: indexContent);
      final backend = IOBackend();
      await backend.writeIndex("tmp/test1", index);

      final content = await File("tmp/test1.idx.dbart").readAsBytes();
      expect(content.uint32(), equals(indexContent.length));
      expect(content.sublist(4), equals(indexContent));
    });

    test("write data", () async {
      final backend = IOBackend();
      await backend.setEntryAt(
          "tmp/test1",
          0,
          Entry(
            key: "1",
            data: utf8.encode("entry1"),
            deleted: false,
          ));

      final data = await backend.getEntryAt("tmp/test1", 0, KeyType.string);
      print(utf8.decode(data!.data));
    });
  });
}
