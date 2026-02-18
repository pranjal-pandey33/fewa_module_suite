typedef HookHandler = void Function();
typedef HookContribution = Object? Function();

class HookRegistry {
  final Map<String, List<HookHandler>> _hooks = {};
  final Map<String, List<HookContribution>> _contributions = {};

  void register(String hookName, HookHandler handler) {
    final list = _hooks.putIfAbsent(hookName, () => []);
    list.add(handler);
  }

  void registerContribution(String hookName, HookContribution contribution) {
    final list = _contributions.putIfAbsent(hookName, () => []);
    list.add(contribution);
  }

  void trigger(String hookName) {
    final handlers = _hooks[hookName];
    if (handlers == null) return;

    for (final handler in List<HookHandler>.from(handlers)) {
      handler();
    }
  }

  int count(String hookName) => _hooks[hookName]?.length ?? 0;

  int contributionCount(String hookName) =>
      _contributions[hookName]?.length ?? 0;

  Iterable<HookContribution> contributions(String hookName) =>
      _contributions[hookName] ?? const [];

  void clear() {
    _hooks.clear();
    _contributions.clear();
  }
}
