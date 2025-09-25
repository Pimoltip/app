import '../models/project.dart';

class InMemoryProjectRepo {
  final _items = <Project>[];

  List<Project> all() => List.unmodifiable(_items);
  List<Project> byTag(String tag) => _items.where((e) => e.tag == tag).toList();
  void add(Project p) => _items.add(p);
}
