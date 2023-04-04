part of drtree;

extension ListExtension on List {
  void removeAll(List list) {
    for (var i = 0; i < list.length; i++) {
      remove(list[i]);
    }
  }
}
