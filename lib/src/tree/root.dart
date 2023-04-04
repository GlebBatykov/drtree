part of drtree;

class Root extends Node with NodeMixin<ShapeNode> implements PointFinder {
  final List<Point> _points = [];

  Root({
    required super.minChildCount,
    required super.maxChildCount,
  });

  @override
  void addShape(Shape shape) {
    if (shape is Point) {
      _addPoint(shape);
    }
  }

  void _addPoint(Point point) {
    if (!_tryAddPoint(point)) {
      _buildNodes();

      _points.add(point);
    }
  }

  bool _tryAddPoint(Point point) =>
      _tryAddPointToNodes(point) || _tryAddPointToPoints(point);

  bool _tryAddPointToNodes(Point point) {
    for (var i = 0; i < _nodes.length; i++) {
      if (point.enters(_nodes[i].shape)) {
        _nodes[i].addShape(point);

        return true;
      }
    }

    return false;
  }

  bool _tryAddPointToPoints(Point point) {
    if (_points.length < maxChildCount) {
      _points.add(point);

      return true;
    } else {
      return false;
    }
  }

  void _buildNodes() {
    final buffer = Node._getBuffer(minChildCount);

    var iterator = 0;

    while (_points.length >= minChildCount) {
      if (_points.length == minChildCount) {
        final node = RectangleNode(
          rectangle: Rectangle.fromPoints(List.from(_points)),
          parent: this,
          minChildCount: minChildCount,
          maxChildCount: maxChildCount,
        );

        _addNode(node);
        _points.removeAll(node.shape.points);

        break;
      }

      Rectangle? rectangle;

      for (var start = 0;
          start + minChildCount < _points.length;
          start += minChildCount) {
        for (var i = start; i < start + minChildCount - 1; i++) {
          buffer[iterator++] = _points[i];
        }

        for (var i = start + minChildCount - 1; i < _points.length; i++) {
          buffer[iterator] = _points[i];

          if (rectangle == null) {
            rectangle = Rectangle.fromPoints(List<Point>.from(buffer));

            continue;
          }

          final analysis = PointsAnalyzer.analyzeBuffer(buffer);

          final info = RectangleInfo.fromAnalysis(analysis);

          if (rectangle.square > info.square) {
            rectangle = Rectangle(
              points: List<Point>.from(buffer),
              info: info,
              analysis: analysis,
            );
          }
        }

        iterator = 0;
      }

      final node = RectangleNode(
        rectangle: rectangle!,
        parent: this,
        minChildCount: minChildCount,
        maxChildCount: maxChildCount,
      );

      _addNode(node);
      _points.removeAll(node.shape.points);
    }
  }

  void _addNode(ShapeNode node) {
    if (_tryAddNodeToExisting(node)) {
      return;
    }

    for (var i = 0; i < _nodes.length; i++) {
      if (_nodes[i].shape.enters(node.shape)) {
        _nodes[i].mount(node);

        node.addNode(_nodes[i]);
      }
    }

    for (var i = 0; i < node.nodes.length; i++) {
      _nodes.remove(node.nodes[i]);
    }

    _nodes.add(node);
  }

  bool _tryAddNodeToExisting(ShapeNode node) {
    for (var i = 0; i < nodes.length; i++) {
      if (node.shape.enters(nodes[i].shape)) {
        node.mount(nodes[i]);

        nodes[i].addNode(node);

        return true;
      }
    }

    return false;
  }

  @override
  void removeShape(Shape shape) {
    if (shape is Point) {
      _removePoint(shape);
    }
  }

  void _removePoint(Point point) {}

  @override
  void addNode(ShapeNode node) {
    _nodes.add(node);
  }

  @override
  void removeNode(ShapeNode node) {
    _nodes.remove(node);
  }

  @override
  List<Point> getPointsInShape(ShapeContainer shape) => [
        for (final node in _nodes)
          if (node.shape.enters(shape))
            ...node.getPoints()
          else if (shape.intersects(node.shape) || node.shape.intersects(shape))
            ...node.getPointsInShape(shape),
        for (final point in _points)
          if (point.enters(shape)) point,
      ];

  @override
  List<Point> getPoints() => [
        for (final node in _nodes) ...node.getPoints(),
        ..._points,
      ];
}
