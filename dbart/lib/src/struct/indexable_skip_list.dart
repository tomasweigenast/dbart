import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:dbart/src/utils/utils.dart';

class IndexableSkipList<K, V> {
  static const _maxHeight = 12;

  final _Node<K, V> _head = _Node(
    null,
    null,
    List.filled(_maxHeight, null),
    List.filled(_maxHeight, 0),
  );

  final Random _random;

  final Comparator<K> _comparator;

  int _height = 1;
  int _length = 0;

  IndexableSkipList(this._comparator, [Random? random]) : _random = random ?? Random();

  int get length => _length;

  Iterable<K> get keys => _KeyIterable(_head);

  Iterable<V> get values => _ValueIterable(_head);

  Iterable<(K, V)> get entries => _EntryIterable(_head);

  V? insert(K key, V? value) {
    // TODO: maybe insert values of same key in a list inside the same node
    // var existingNode = _getNode(key);
    // if (existingNode != null) {
    //   var oldValue = existingNode.value;
    //   existingNode.value = value;
    //   return oldValue;
    // }

    // calculate this new node's level
    var newLevel = 0;
    while (_random.nextBool() && newLevel < _maxHeight - 1) {
      newLevel++;
    }
    if (newLevel >= _height) {
      newLevel = _height++;
    }

    var newNode = _Node<K, V>(
      key,
      value,
      List.filled(newLevel + 1, null),
      List.filled(newLevel + 1, 0),
    );

    var current = _head;
    // Next & Down
    for (var level = _height - 1; level >= 0; level--) {
      while (true) {
        var next = current.next[level];
        if (next == null || _comparator(key, next.key as K) < 0) break;
        current = next;
      }

      // CHANGE 1 - Increase all the above node's width by 1
      if (level > newLevel) {
        var next = current.next[level];
        if (next != null) {
          next.width[level]++;
        }
        continue;
      }

      if (level == 0) {
        // CHANGE 2 - Nodes at level 0 always have a width of 1
        newNode.width[0] = 1;
      } else {
        // CHANGE 3 - Calculate the width of the level
        var width = 0;
        var node = current.next[level - 1];
        while (node != null && _comparator(key, node.key as K) >= 0) {
          width += node.width[level - 1];
          node = node.next[level - 1];
        }

        for (var j = level; j <= newLevel; j++) {
          newNode.width[j] += width;
        }
        newNode.width[level] += 1;
      }

      // Insert new node at the correct position in this level
      newNode.next[level] = current.next[level];
      current.next[level] = newNode;
    }

    // CHANGE 4 - Adjust the width of all next nodes
    for (var i = 1; i <= newLevel; i++) {
      var next = newNode.next[i];
      if (next != null) {
        next.width[i] -= newNode.width[i] - 1;
      }
    }

    _length++;
    return null;
  }

  V? deleteAt(int index) {
    var node = _getNodeAt(index);
    _deleteNode(node);
    return node.value;
  }

  V? delete(K key) {
    var node = _getNode(key);
    if (node == null) return null;

    _deleteNode(node, key);
    return node.value;
  }

  @preferInline
  @pragma('dart2js:tryInline')
  V? get(K key) => _getNode(key)?.value;

  @preferInline
  @pragma('dart2js:tryInline')
  Iterable<V> valuesFromKey(K key) {
    var node = _getNode(key);
    var virtualHead = _Node(null, null, [node], [0]);
    return _ValueIterable(virtualHead);
  }

  _Node<K, V>? _getNode(K key) {
    var prev = _head;
    _Node<K, V>? node;
    for (var i = _height - 1; i >= 0; i--) {
      node = prev.next[i];

      while (node != null && _comparator(key, node.key as K) > 0) {
        prev = node;
        node = node.next[i];
      }
    }

    if (node != null && _comparator(key, node.key as K) == 0) {
      return node;
    }
    return null;
  }

  @preferInline
  @pragma('dart2js:tryInline')
  V? getAt(int index) => _getNodeAt(index).value;

  @preferInline
  @pragma('dart2js:tryInline')
  K? getKeyAt(int index) => _getNodeAt(index).key;

  void _deleteNode(_Node<K, V> node, [K? key]) {
    var current = _head;
    // Next & Down
    for (var level = _height - 1; level >= 0; level--) {
      while (true) {
        var next = current.next[level];
        if (next == null || _comparator(key ?? node.key as K, next.key as K) <= 0) break;
        current = next;
      }

      if (level > node.level) {
        var next = current.next[level];
        if (next != null) {
          next.width[level]--;
        }
      } else {
        var next = node.next[level];
        current.next[level] = next;
        if (next != null) {
          next.width[level] += node.width[level] - 1;
        }
      }
    }

    if (node.level == _height - 1 && _height > 1 && _head.next[node.level] == null) {
      _height--;
    }

    _length--;
  }

  _Node<K, V> _getNodeAt(int index) {
    RangeError.checkValidIndex(index, this);

    var prev = _head;
    _Node<K, V>? node;
    for (var level = _height - 1; level >= 0; level--) {
      node = prev.next[level];

      while (node != null && index >= node.width[level]) {
        index -= node.width[level];
        prev = node;
        node = node.next[level];
      }
    }

    return node!;
  }

  void clear() {
    _height = 1;
    for (var i = 0; i < _maxHeight; i++) {
      _head.next[i] = null;
    }
    _height = 1;
    _length = 0;
  }

  String serialize() {
    List<Map<String, dynamic>> serializedNodes = [];
    var current = _head.next[0];
    while (current != null) {
      serializedNodes.add({
        'key': current.key,
        'value': current.value,
        'width': List<int>.from(current.width),
        'next': List.generate(current.next.length, (index) => current?.next[index]?.key),
      });
      current = current.next[0];
    }
    return jsonEncode(serializedNodes);
  }

  void deserialize(String serializedData) {
    clear(); // Clear existing data before deserialization
    List<dynamic> serializedNodes = json.decode(serializedData);
    for (var serializedNode in serializedNodes) {
      var key = serializedNode['key'] as K?;
      var value = serializedNode['value'] as V?;
      var width = List<int>.from(serializedNode['width']);
      var nextKeys = (serializedNode['next'] as List?)?.cast<K?>();
      var nextNodes = List<_Node<K, V>?>.filled(nextKeys!.length, null);
      for (var i = 0; i < nextKeys.length; i++) {
        if (nextKeys[i] != null) {
          nextNodes[i] = _Node<K, V>(nextKeys[i], null, [], []);
        }
      }
      _length++;
      var newNode = _Node<K, V>(key, value, nextNodes, width);
      // Reconstruct the connections between nodes
      for (var i = 0; i < nextNodes.length; i++) {
        newNode.next[i] = nextNodes[i];
      }
      _insertNode(newNode);
    }
  }

  // Helper method to insert a node without updating the length
  void _insertNode(_Node<K, V> newNode) {
    var current = _head;
    // Next & Down
    for (var level = _height - 1; level >= 0; level--) {
      while (true) {
        var next = current.next[level];
        if (next == null || _comparator(newNode.key as K, next.key as K) < 0) break;
        current = next;
      }
      // Insert new node at the correct position in this level
      newNode.next[level] = current.next[level];
      current.next[level] = newNode;
    }
  }
}

class _Node<K, V> {
  final K? key;

  V? value;

  final List<_Node<K, V>?> next;

  final List<int> width;

  int get level => next.length - 1;

  _Node(this.key, this.value, this.next, this.width);
}

abstract class _Iterator<K, V, E> implements Iterator<E> {
  _Node<K?, V?>? node;

  _Iterator(this.node);

  @override
  bool moveNext() => (node = node!.next[0]) != null;
}

class _KeyIterator<K, V> extends _Iterator<K, V, K> {
  _KeyIterator(_Node<K?, V?> node) : super(node);

  @override
  K get current => node!.key!;
}

class _KeyIterable<K, V> extends IterableBase<K> {
  final _Node<K?, V?> head;

  _KeyIterable(this.head);

  @override
  Iterator<K> get iterator => _KeyIterator(head);
}

class _ValueIterator<K, V> extends _Iterator<K, V, V> {
  _ValueIterator(_Node<K?, V?> node) : super(node);

  @override
  V get current => node!.value!;
}

class _ValueIterable<K, V> extends IterableBase<V> {
  final _Node<K?, V?> head;

  _ValueIterable(this.head);

  @override
  Iterator<V> get iterator => _ValueIterator(head);
}

class _EntryIterator<K, V> extends _Iterator<K, V, (K, V)> {
  _EntryIterator(_Node<K?, V?> node) : super(node);

  @override
  (K, V) get current => (node!.key!, node!.value!);
}

class _EntryIterable<K, V> extends IterableBase<(K, V)> {
  final _Node<K?, V?> head;

  _EntryIterable(this.head);

  @override
  Iterator<(K, V)> get iterator => _EntryIterator(head);
}
