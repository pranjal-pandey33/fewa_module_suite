import 'package:foundation/foundation.dart';

import 'todo_module.dart';

const ModuleEntry todoEntry = ModuleEntry(
  name: 'todo',
  register: TodoModule.register,
);
