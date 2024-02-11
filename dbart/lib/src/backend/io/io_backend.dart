import 'dart:typed_data';

import 'package:dbart/src/backend/backend_base.dart';
import 'package:dbart/src/backend/io/file_handle_pool.dart';
import 'package:dbart/src/binary/binary_reader.dart';
import 'package:dbart/src/binary/spec.dart';
import 'package:dbart/src/entry/entry.dart';
import 'package:dbart/src/index/data_index.dart';
import 'package:dbart/src/utils/ext.dart';

const _kDataSuffix = ".dbart";
const _kIndexSuffix = ".idx$_kDataSuffix";

final class IOBackend implements BackendBase {
  final FileHandlePool pool;

  IOBackend({FileHandlePool? pool}) : pool = pool ?? FileHandlePool();

  @override
  Future<Index?> getIndex(String name) async {
    final handle = pool.getHandle("$name$_kIndexSuffix");
    handle.setPositionSync(0);
    final indexSize = (await handle.read(4)).uint32();
    final buffer = Uint8List(indexSize);
    int read = await handle.readInto(buffer);
    if (read + 4 < indexSize) {
      // this index may be corrupted
      throw StateError("Index $name may be corrupted.");
    }

    return Index(buffer: buffer);
  }

  @override
  Future<void> writeIndex(String name, Index index) async {
    final indexSize = index.buffer.length;
    final handle = pool.getHandle("$name$_kIndexSuffix");
    final buffer = Uint8List(4 + indexSize);
    buffer.setUint32(indexSize);
    buffer.setRange(4, 4 + indexSize, index.buffer);
    await handle.writeFrom(buffer);
    await handle.flush();
  }

  @override
  Future<void> setEntryAt(String name, int position, Entry entry) async {
    final handle = pool.getHandle("$name$_kDataSuffix");
    handle.setPositionSync(position);
    final buffer = entry.toBuffer();
    await handle.writeFrom(buffer);
    await handle.flush();
  }

  @override
  Future<int> appendEntry(String name, Entry entry) async {
    final handle = pool.getHandle("$name$_kDataSuffix");
    final pos = handle.lengthSync();
    handle.setPositionSync(pos);
    final buffer = entry.toBuffer();
    await handle.writeFrom(buffer);
    await handle.flush();
    return pos;
  }

  @override
  Future<Entry?> getEntryAt(String name, int position, KeyType keyType) async {
    final handle = pool.getHandle("$name.dbart");
    handle.setPositionSync(position);
    final entrySize = (await handle.read(4)).uint32();
    final buffer = Uint8List(entrySize);
    await handle.readInto(buffer);
    return BinaryReader(buffer).readEntry(keyType);
  }
}
