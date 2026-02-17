# Foundation Architecture — V1 (Flutter + Dart)

> This document defines the **Foundation package** in detail: what it contains, how it behaves, and what rules it enforces.
> Modules depend on Foundation. Foundation depends on **no modules**.

---

## 1) Purpose of Foundation

Foundation is the **runtime engine** that makes this possible:

- Run **one module** as a standalone product
- Run **multiple modules together** as one suite
- Modules stay isolated (no direct imports), yet integrate through registries

Foundation provides:

- **Kernel registries**: EventBus, HookRegistry, RouteRegistry
- **ModuleLoader**: discovery + dependency resolution + topo sort
- **Lifecycle orchestrator**: calls module methods in strict order
- **Foundation Launcher Home**: route `/` reserved for foundation

---

## 2) Foundation Structure (Package Layout)

```
packages/foundation/
  pubspec.yaml
  lib/
    foundation.dart              # public exports only
    src/
      kernel/
        event_bus/
        hook_registry/
        route_registry/
      module_loader/
      runtime/
        foundation_runtime.dart
        launcher_home/
  test/
```

### Rules
- Everything inside `lib/src/` is **private implementation**.
- Other packages import only: `package:foundation/foundation.dart`.

---

## 3) Kernel Registries (V1)

## 3.1 EventBus (Typed events, sync delivery)

### What it is
An in-app **post office**. Modules publish events; subscribers receive them **immediately**.

### What it does
- Decouples modules: publisher never knows who consumes.
- Enables integrations + projections without DB access.

### V1 Rules
- **Typed events only** (classes, not strings).
- **Synchronous** in-process delivery (publish → handlers run now).
- Publishing with no subscribers must be a **no-op** (not an error).

### Failure rules
- A handler throwing should fail fast in dev (surface bug).
  - (Future: configurable error isolation)

---

## 3.2 HookRegistry (Strict hooks)

### What it is
A **plugin slot system**. One module defines “extension points” (hooks), others contribute items.

### What it does
- Enables UI/flow extensibility without cross-module imports.
- Example: Todo defines `todo.home.actions`, Calculator contributes a button/action.

### V1 Rules
- Hooks must be **defined** before contribution.
- **Strict in dev**:
  - Contributing to an undefined hook throws:
    - `Hook not defined: <hookName>`
- Stores contributions as ordered lists.

### Hook naming convention
- `<ownerModule>.<screenOrArea>.<purpose>`
- Example: `todo.home.actions`, `pharmacy.invoice.lines`

---

## 3.3 RouteRegistry (Aggregation + collision protection)

### What it is
A global **route collector**.

### What it does
- Collects routes/screens from all loaded modules.
- Enables one navigation map for the suite.

### V1 Rules
- Every route has:
  - `path` (e.g. `/todo`)
  - `ownerModule` (e.g. `todo`)
  - a screen/builder reference
- **Collision protection**:
  - Two modules cannot register the same `path`.
  - Collision must fail fast with clear message.

### Route convention (V1)
- Module prefixed paths:
  - Todo: `/todo`
  - Calculator: `/calculator`
- `/` is reserved for Foundation Launcher Home.

---

## 4) ModuleLoader (Composition Engine)

### What it is
The **conductor** that turns “selected module names” into a safe runtime composition.

### What it does
1. **Discover** modules via `modules/*/module.json`
2. **Validate** manifests (name uniqueness, fields, etc.)
3. **Auto-add dependencies**
4. **Topological sort** (deps first)
5. Return start order + metadata

### V1 Rules
- Dependency cycles must fail fast with chain:
  - `Dependency cycle detected: A -> B -> A`
- Missing dependency fails fast:
  - `Missing dependency: <dep> required by <module>`

> Flutter/Dart cannot runtime-import arbitrary source files.
> So instantiation is done via a **Module Registry Map** in the runner app.
> ModuleLoader still owns: discovery + dependency graph + ordering.

---

## 5) Lifecycle Orchestration (Strict Order)

For all loaded modules:

1. `registerContracts()`
2. `registerSubscriptions()`
3. `registerHooks()`
4. `registerRoutes()`
5. `start()`

Shutdown:
- `stop()` in reverse topo order (dependents first)

### Why this order
- Contracts exist before anyone consumes them.
- Subscriptions set up before events start flowing.
- Hooks defined before contributions are rendered.
- Routes collected before router is built.
- Start happens last so everything is wired.

---

## 6) Foundation Launcher Home (`/`)

Foundation always owns `/`.

### Purpose
- Provide a neutral entrypoint when running any composition.
- Show:
  - loaded modules (name, version)
  - available main routes
  - optional diagnostics (future)

### Rule
- Modules must never claim `/`.

---

## 7) Enforcement & Error Messages (V1)

Foundation must fail fast on these:

- **Route collision**
  - `Route collision: "<path>" owned by "<A>" and "<B>"`
- **Undefined hook contribution (dev)**
  - `Hook not defined: <hookName>`
- **Duplicate module name**
  - `Duplicate module name: <name>`
- **Missing dependency**
  - `Missing dependency: <dep> required by <module>`
- **Dependency cycle**
  - `Dependency cycle detected: A -> B -> A`

---

## 8) Testing Expectations (V1)

Minimum test cases inside `packages/foundation/test/`:

- EventBus: publish to 0 subscribers (no crash)
- EventBus: publish to subscribers (sync)
- HookRegistry: contribute to undefined hook (throws in strict mode)
- RouteRegistry: collision throws
- ModuleLoader: auto-add deps
- ModuleLoader: cycle detection
- Runtime: lifecycle order respected

---

## 9) Out of Scope (V1)

Not required now:
- Async event queue / durability / outbox
- Distributed modules / remote loading
- Plugin permissions / capability registry
- Multi-tenant routing/auth
- Version negotiation beyond event V2 policy

---

## Summary

Foundation is the **engine**:
- Registers + wires modules through registries
- Loads and orders modules safely
- Enforces isolation and fail-fast integrity
- Provides `/` launcher home

Next doc after this: **Module Spec — V1** (module.json schema + module interface + contracts policy).
