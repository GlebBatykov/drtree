part of drtree;

mixin NodeMixin<T extends Node> on Node {
  final List<T> _nodes = [];

  List<T> get nodes => List.unmodifiable(_nodes);
}
