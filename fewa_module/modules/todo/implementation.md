# Todo Module Implementation Summary

## Scope
Refactor the Todo module to enforce clean folder boundaries from `todo_design.md` and remove cross-layer coupling from UI.

## Completed Work
1. Moved module logic out of root `lib/` entry into `lib/src/module/`
- Created `modules/todo/lib/src/module/todo_module.dart`.
- Kept `modules/todo/lib/todo_module.dart` as compatibility export.

2. Kept data/store in `lib/src/...`
- `TodoProjectionStore` remains in `lib/src/data/`.
- Module layer passes projection notifier into UI.

3. Enforced hook slot constants
- Added `modules/todo/lib/ui/hooks/hook_zones.dart` with:
  - `todo.appbar.actions`
  - `todo.dashboard.cards`
  - `todo.task.item.trailing`
- Replaced hardcoded string keys with constants in UI and module.

4. Removed UI business coupling
- `TodoHome` no longer imports `TodoModule`.
- `TodoHome` now receives `ValueListenable<int> calculationEvents` and uses it in `ValueListenableBuilder`.

5. Preserved stable imports
- UI files use explicit UI-layer imports and module-layer hook constants as designed.

## Files Changed
- `modules/todo/lib/src/module/todo_module.dart` (new)
- `modules/todo/lib/todo_module.dart` (export shim)
- `modules/todo/lib/ui/screens/todo_home.dart`
- `modules/todo/lib/ui/layout/todo_scaffold.dart`
- `modules/todo/lib/ui/widgets/task_item.dart`
- `modules/todo/lib/ui/hooks/hook_zones.dart` (new)

## Remaining Gap
- Move `TodoHome` local task state (`UiTask` list and add-task logic) into module/domain layer if strict “no business logic in ui/” is enforced universally.
