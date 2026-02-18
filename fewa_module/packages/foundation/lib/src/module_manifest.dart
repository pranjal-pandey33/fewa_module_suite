class ModuleManifest {
  final String name;
  final String version;
  final String mainRoute;
  final List<String> dependencies;

  ModuleManifest({
    required this.name,
    required this.version,
    required this.mainRoute,
    required this.dependencies,
  });
}
