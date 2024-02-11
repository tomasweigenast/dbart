import 'dart:io';

final class FileHandlePool {
  final Map<String, RandomAccessFile> _pool = {};

  /// Retrieves a [RandomAccessFile] from the pool or opens a new handle.
  ///
  /// It **does not** open a file per [mode].
  RandomAccessFile getHandle(String name, [FileMode mode = FileMode.append]) {
    var raf = _pool[name];
    if (raf == null) {
      raf = File(name).openSync(mode: mode);
      _pool[name] = raf;
    }

    return raf;
  }
}
