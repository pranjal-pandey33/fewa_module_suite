typedef HookHandler = void Function();

class HookRegistry {
  final Map<String, List<HookHandler>> _hooks = {};

  void register(String hookName, HookHandler handler) {
    final list = _hooks.putIfAbsent(hookName, () => []);
    list.add(handler);
  }

  void trigger(String hookName) {
    final handlers = _hooks[hookName];
    if (handlers == null) return;

    for (final handler in List<HookHandler>.from(handlers)) {
      handler();
    }
  }

  int count(String hookName) => _hooks[hookName]?.length ?? 0;

  void clear() => _hooks.clear();
}
