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
  Future<Uint8List> getIndex(String name) async {
    final handle = pool.getHandle("$name$_kIndexSuffix");
    handle.setPositionSync(0);
    int indexSize;
    try {
      indexSize = (await handle.read(4)).uint32();
    } catch (_) {
      return Uint8List(0);
    }
    final buffer = Uint8List(indexSize);
    int read = await handle.readInto(buffer);
    if (read + 4 < indexSize) {
      // this index may be corrupted
      throw StateError("Index $name may be corrupted.");
    }

    return buffer;
  }

  @override
  Future<void> writeIndex(String name, Index index) async {
    final indexBuffer = index.toBuffer();
    final handle = pool.getHandle("$name$_kIndexSuffix");
    handle.setPositionSync(0);
    final buffer = Uint8List(4 + indexBuffer.length);
    buffer.setUint32(indexBuffer.length);
    buffer.setRange(4, 4 + indexBuffer.length, indexBuffer);
    handle.truncateSync(4 + indexBuffer.length);
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
    final handleName = "$name$_kDataSuffix";
    final handle = pool.getHandle(handleName);
    final pos = handle.lengthSync();
    handle.setPositionSync(pos);
    final buffer = entry.toBuffer();
    await handle.writeFrom(buffer);
    await handle.flush();
    return pos;
  }

  @override
  Future<Entry?> getEntryAt(String name, int position, KeyType keyType) async {
    final handleName = "$name$_kDataSuffix";
    final handle = pool.getHandle(handleName);
    handle.setPositionSync(position);
    int entrySize;
    try {
      entrySize = (await handle.read(4)).uint32();
    } catch (_) {
      return null;
    }
    final buffer = Uint8List(entrySize);
    await handle.readInto(buffer);
    return BinaryReader(buffer).readEntry(keyType);
  }
}
