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

## New Implementation Update (File-based Task Persistence)

1. Added durable task store in data layer
- Created `modules/todo/lib/src/data/todo_task_store.dart`.
- New `TodoTask` model now stores:
  - `title`
  - `metadata`
  - `done`
  - `createdAt`
- New `TodoTaskStore` uses `ValueNotifier<List<TodoTask>>` for reactive task UI updates.
- Store reads/writes JSON to `${app documents}/todo_tasks.json`.
- Added load (`init`) and persistence (`_persist`) flow for restart-safe behavior.
- Added mutations:
  - `addTask(...)`
  - `setTaskDone(...)`

2. Migrated Todo UI to store-backed tasks
- Updated `modules/todo/lib/ui/screens/todo_home.dart`:
  - Removed in-memory `_tasks` list and local `UiTask` model.
- Bound list rendering to `ValueListenableBuilder<List<TodoTask>>`.
- Task updates/toggles now call store methods, which persist changes automatically.
- Added optional store injection on `TodoHome` constructor with fallback to local store for standalone usage.

3. Wired store initialization at module level
- Updated `modules/todo/lib/src/module/todo_module.dart`:
  - Added static `TodoTaskStore tasks = TodoTaskStore()`.
  - Passed `taskStore` into `TodoHome`.
  - Called `tasks.init()` in module registration to load persisted tasks during startup.

4. Persistence outcome
- Task list now survives app restarts because the store serializes and restores task state from JSON on disk.

## New Implementation Update (Task row Edit/Delete)

1. Added row-level actions backed by store mutations
- `modules/todo/lib/src/data/todo_task_store.dart`
  - Added `updateTask(...)` for editing title/metadata.
  - Added `deleteTask(...)` for task removal.
  - Both operations update `ValueNotifier<List<TodoTask>>` and persist to `todo_tasks.json`.

2. Connected overflow menu actions in task list UI
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added a task row overflow action using `PopupMenuButton`.
  - Actions:
    - `Edit`: opens the existing editor bottom sheet pre-filled with current title/metadata and saves via `updateTask`.
    - `Delete`: removes the row immediately via `deleteTask`.
- Refactored editor to a shared `_openTaskEditorSheet(...)` used by both Add and Edit flows.
- Kept list row spacing and touch targets theme-aligned by retaining existing `TaskItem` layout and increasing trailing action slot to menu icon size.

3. Theme/compliance adjustments
- `modules/todo/lib/ui/widgets/task_item.dart`
  - Increased trailing action container size to `40x40` for the overflow icon/button hit target while keeping list spacing intact.

## New Implementation Update (Loading + Empty State UX)

1. Added store initialization loading signal
- `modules/todo/lib/src/data/todo_task_store.dart`
  - Added `ValueNotifier<bool> isLoading` (defaults to `true`) to expose async init state.
  - Added non-reentrant init tracking (`_initFuture`) so simultaneous callers share one initialization cycle.
  - `init()` now sets `isLoading` during file hydration/persistence validation and clears it in `finally`, preventing UI flicker and multiple overlapping loads.
  - Kept task persistence contract unchanged (`todo_tasks.json` in app documents) and preserved existing `ValueNotifier<List<TodoTask>>` pattern.

2. Added loading skeleton placeholders in task section
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added `_buildTaskSkeletonList` and `_buildTaskSkeletonRow`.
  - Task section now renders fixed-height list placeholders while `isLoading` is true.
  - Placeholder geometry matches row height and spacing to avoid layout jank on swap to real data.

3. Added empty state for no tasks
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added `_buildEmptyTaskState` with icon + headline/body text to show when loading is complete and task list is empty.
  - Preserved theme-driven colors/typography and section spacing.

4. Wired loading lifecycle into UI
- `modules/todo/lib/ui/screens/todo_home.dart`
  - `_TodoHomeState` now calls `unawaited(_taskStore.init())` in `initState`.
  - Build path now listens to `_taskStore.isLoading` before tasks list, and selects between:
    - skeleton placeholders,
    - empty state,
    - or the interactive task list with edit/delete actions.

## New Implementation Update (HookRegistry-driven Slots + Overflow Rendering)

1. Added hook-contribution API in foundation
- `packages/foundation/lib/src/hook_registry.dart`
  - Added `HookContribution = Object? Function()`.
  - Added `registerContribution(String hookName, HookContribution contributor)` for slot-driven UI providers.
  - Added `contributions(String hookName)` and `contributionCount(String hookName)` accessors.
  - `clear()` now resets both handler and contribution collections.

2. Wired Todo UI to hook slots
- `modules/todo/lib/src/module/todo_module.dart`
  - Passed `HookRegistry` into `TodoHome` so slots can read registered hook contributions.
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added `_buildAppBarHookActions` for `todo.appbar.actions` with max 3 inline actions and overflow menu.
  - Added `_buildDashboardHookCards` for `todo.dashboard.cards` rendered as a safe wrap layout.
  - Added `_taskTrailingHookEntries` for `todo.task.item.trailing`, appended into the row menu.
  - Added safe contribution collection via `_hookWidgets` that catches bad contributions and renders only `Widget` values.

## New Implementation Update (Task List Filters)

1. Added local task filtering UI
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added `_TaskFilter` enum with values `all`, `active`, and `completed`.
  - Added filter chips below the "Task List" heading for `All`, `Active`, and `Completed`.

2. Applied filter to rendered list only
- `modules/todo/lib/ui/screens/todo_home.dart`
  - Added filtered task mapping in `_buildTaskSection` and `_filteredTaskEntries(...)` so filtering only affects rendering.
  - Kept store update paths (`setTaskDone`, `updateTask`, `deleteTask`) intact.
  - Resolved actions in filtered mode using original task index from `MapEntry.key` to avoid index mismatch.
