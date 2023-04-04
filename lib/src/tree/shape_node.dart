part of drtree;

abstract class ShapeNode<T extends ShapeContainer> extends Node
    with NodeMixin<ShapeNode>
    implements PointFinder {
  Node _parent;

  Node get parent => _parent;

  T get shape;

  ShapeNode({
    required Node parent,
    required super.minChildCount,
    required super.maxChildCount,
  }) : _parent = parent;

  void mount(Node node) {
    _parent = node;
  }
}
