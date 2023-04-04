part of drtree;

class RectangleNode extends ShapeNode<Rectangle> {
  Rectangle _rectangle;

  @override
  Rectangle get shape => _rectangle;

  RectangleNode({
    required Rectangle rectangle,
    required super.parent,
    required super.minChildCount,
    required super.maxChildCount,
  }) : _rectangle = rectangle;

  @override
  void addShape(Shape shape) {
    if (shape is Point) {
      _addPoint(shape);
    }
  }

  void _addPoint(Point point) {
    if (!_tryAddPoint(point)) {
      _split();

      parent.addShape(point);
    }
  }

  bool _tryAddPoint(Point point) =>
      _tryAddPointToNodes(point) || _tryAddPointToRectangle(point);

  bool _tryAddPointToRectangle(Point point) {
    if (_rectangle.points.length < maxChildCount) {
      _rectangle = Rectangle.fromPoints([
        ..._rectangle.points,
        point,
      ]);

      return true;
    } else {
      return false;
    }
  }

  bool _tryAddPointToNodes(Point point) {
    for (var i = 0; i < _nodes.length; i++) {
      if (point.enters(_nodes[i].shape)) {
        _nodes[i].addShape(point);

        return true;
      }
    }

    return false;
  }

  void _split() {
    parent.removeNode(this);

    final buffer = Node._getBuffer(minChildCount);

    var iterator = 0;

    final points = List<Point>.from(_rectangle.points);

    while (points.length >= minChildCount) {
      if (points.length == minChildCount) {
        final node = RectangleNode(
          rectangle: Rectangle.fromPoints(List.from(points)),
          parent: parent,
          minChildCount: minChildCount,
          maxChildCount: maxChildCount,
        );

        parent.addNode(node);
        points.removeAll(node.shape.points);

        break;
      }

      Rectangle? rectangle;

      for (var start = 0;
          start + minChildCount < points.length;
          start += minChildCount) {
        for (var i = start; i < start + minChildCount - 1; i++) {
          buffer[iterator++] = points[i];
        }

        for (var i = start + minChildCount - 1; i < points.length; i++) {
          buffer[iterator] = points[i];

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
        parent: parent,
        minChildCount: minChildCount,
        maxChildCount: maxChildCount,
      );

      parent.addNode(node);
      points.removeAll(node.shape.points);
    }

    for (final point in points) {
      parent.addShape(point);
    }

    for (var i = 0; i < _nodes.length; i++) {
      final points = _nodes[i].getPoints();

      for (var j = 0; j < points.length; j++) {
        parent.addShape(points[j]);
      }
    }
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
  List<Point> getPoints() => [
        for (final node in _nodes) ...node.getPoints(),
        ..._rectangle.points,
      ];

  @override
  List<Point> getPointsInShape(ShapeContainer shape) => [
        for (final node in _nodes)
          if (node.shape.enters(shape))
            ...node.getPoints()
          else if (shape.intersects(node.shape) || node.shape.intersects(shape))
            ...node.getPointsInShape(shape),
        for (final point in _rectangle.points)
          if (point.enters(shape)) point,
      ];
}
