import 'dart:convert';
import 'dart:io';

import 'package:dbart/src/backend/io/io_backend.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:test/test.dart';

void main() {
  group("IOBackend tests", () {
    setUpAll(() => Directory("tmp").createSync());
    tearDownAll(() => Directory("tmp").deleteSync(recursive: true));

    // test("write index", () async {
    //   final indexContent = utf8.encode("fake index content");
    //   final index = Index();
    //   final backend = IOBackend();
    //   await backend.writeIndex("tmp/test1", index);

    //   final content = await File("tmp/test1.idx.dbart").readAsBytes();
    //   // expect(content.uint32(), equals(indexContent.length));
    //   // expect(content.sublist(4), equals(indexContent));
    // });

    test("write data", () async {
      final backend = IOBackend();
      await backend.appendEntry(
        "tmp/test1",
        Entry.fromData(1, {"id": 1, "name": "Tomás"}),
      );

      final entry = Entry.fromData(2, {"id": 2, "name": "Alex"});
      int pos = await backend.appendEntry(
        "tmp/test1",
        entry,
      );

      await backend.appendEntry(
        "tmp/test1",
        Entry.fromData(3, {"id": 3, "name": "Matias"}),
      );

      var data = await backend.getEntryAt("tmp/test1", pos, KeyType.int);
      expect(data!.data, entry.data);

      pos = await backend.appendEntry(
          "tmp/test1",
          Entry(
            key: 4,
            data: utf8.encode("entry4"),
            deleted: true,
          ));

      data = await backend.getEntryAt("tmp/test1", pos, KeyType.int);
      expect(utf8.decode(data!.data), equals("entry4"));
    });
  });
}
