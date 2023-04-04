part of drtree;

abstract class Node extends TreeEntity {
  final int minChildCount;

  final int maxChildCount;

  static List<Point?>? _buffer;

  Node({
    required this.minChildCount,
    required this.maxChildCount,
  });

  static List<Point?> _getBuffer(int size) {
    var buffer = _buffer;

    if (buffer == null || buffer.length != size) {
      buffer = List<Point?>.filled(size, null);
    }

    _buffer = buffer;

    return buffer;
  }

  void addShape(Shape shape);

  void removeShape(Shape shape);

  void addNode(ShapeNode node);

  void removeNode(ShapeNode node);

  List<Point> getPoints();
}
