class Interval {
  final int start;
  final int end;

  Interval(this.start, this.end);

  bool overlaps(Interval other) {
    return start <= other.end && other.start <= end;
  }

  bool contains(int point) {
    return start <= point && point <= end;
  }

  Interval merge(Interval other) {
    return Interval(
      start < other.start ? start : other.start,
      end > other.end ? end : other.end,
    );
  }
}

class IntervalTreeNode {
  Interval interval;
  IntervalTreeNode? left;
  IntervalTreeNode? right;
  int maxEnd;

  IntervalTreeNode(this.interval) : maxEnd = interval.end;
}

class IntervalTree {
  IntervalTreeNode? root;

  void insert(int entityId) {
    var interval = Interval(entityId, entityId);
    root = _insertHelper(root, interval);
  }

  IntervalTreeNode? _insertHelper(IntervalTreeNode? node, Interval interval) {
    if (node == null) {
      return IntervalTreeNode(interval);
    }

    if (interval.start <= node.interval.end && interval.end >= node.interval.start) {
      node.interval = node.interval.merge(interval);
    } else if (interval.start < node.interval.start) {
      node.left = _insertHelper(node.left, interval);
    } else {
      node.right = _insertHelper(node.right, interval);
    }

    if (node.maxEnd < interval.end) {
      node.maxEnd = interval.end;
    }

    return node;
  }

  List<int> findInterval(int entityId) {
    var result = <int>[];
    _findIntervalHelper(root, entityId, result);
    return result;
  }

  void _findIntervalHelper(IntervalTreeNode? node, int entityId, List<int> result) {
    if (node == null) {
      return;
    }

    if (node.interval.contains(entityId)) {
      result.add(node.interval.start);
    }

    if (node.left != null && entityId < node.interval.start) {
      _findIntervalHelper(node.left, entityId, result);
    }

    if (node.right != null && entityId > node.interval.start) {
      _findIntervalHelper(node.right, entityId, result);
    }
  }
}
