typedef EventHandler<T> = void Function(T event);

/// Minimal, synchronous in-process EventBus.
/// V1 rules:
/// - In-memory only
/// - Typed subscriptions
/// - No ordering guarantees between different handlers
class EventBus {
  final Map<Type, List<Function>> _handlers = {};

  /// Subscribe to events of type T.
  /// Returns an `unsubscribe()` function.
  void Function() subscribe<T>(EventHandler<T> handler) {
    final type = T;
    final list = _handlers.putIfAbsent(type, () => <Function>[]);
    list.add(handler);

    return () {
      final handlers = _handlers[type];
      if (handlers == null) return;
      handlers.remove(handler);
      if (handlers.isEmpty) _handlers.remove(type);
    };
  }

  /// Publish an event instance to all subscribers of its *exact* type.
  void publish<T>(T event) {
    final handlers = _handlers[T];
    if (handlers == null || handlers.isEmpty) return;

    // Defensive copy so handlers can unsubscribe while iterating.
    final snapshot = List<Function>.from(handlers);
    for (final fn in snapshot) {
      (fn as EventHandler<T>)(event);
    }
  }

  /// For testing/debugging.
  int subscriberCount<T>() => _handlers[T]?.length ?? 0;

  void clear() => _handlers.clear();
}
