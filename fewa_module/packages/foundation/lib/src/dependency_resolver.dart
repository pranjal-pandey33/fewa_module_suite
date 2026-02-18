import 'module_manifest.dart';

class DependencyResolver {
  /// Returns modules in load order (deps first), including auto-added deps.
  /// Throws if missing module or cyclic deps.
  List<String> resolve({
    required List<String> requested,
    required Map<String, ModuleManifest> all,
  }) {
    // 1) Build closure (auto-add deps)
    final Set<String> closure = {};
    void addWithDeps(String name) {
      final m = all[name];
      if (m == null) {
        throw StateError("Missing module manifest: $name");
      }
      if (closure.add(name)) {
        for (final dep in m.dependencies) {
          addWithDeps(dep);
        }
      }
    }

    for (final r in requested) {
      addWithDeps(r);
    }

    // 2) Topological sort with cycle detection (DFS)
    final List<String> order = [];
    final Set<String> visiting = {};
    final Set<String> visited = {};

    void dfs(String name) {
      if (visited.contains(name)) return;
      if (visiting.contains(name)) {
        throw StateError("Cyclic dependency detected at: $name");
      }
      visiting.add(name);
      final m = all[name]!;
      for (final dep in m.dependencies) {
        dfs(dep);
      }
      visiting.remove(name);
      visited.add(name);
      order.add(name);
    }

    for (final name in closure) {
      dfs(name);
    }

    return order;
  }
}
