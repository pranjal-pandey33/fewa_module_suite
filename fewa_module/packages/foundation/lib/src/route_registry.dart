import 'package:flutter/widgets.dart';

class RouteRegistry {
  final Map<String, WidgetBuilder> _routes = {};

  void register(String path, WidgetBuilder builder) {
    _routes[path] = builder;
  }

  Map<String, WidgetBuilder> getRoutes() {
    return Map.unmodifiable(_routes);
  }

  bool hasRoute(String path) {
    return _routes.containsKey(path);
  }

  List<String> get registeredPaths {
    return List.unmodifiable(_routes.keys);
  }

  void clear() => _routes.clear();
}
