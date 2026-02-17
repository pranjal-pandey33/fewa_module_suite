# Module Spec — V1 (Flutter Modules)

> This document defines what a **Module** is in our system, what files it must contain, what it is allowed to expose, and how it integrates with Foundation.
> Foundation is the engine. Modules are the products.

---

## 1) What a Module is (V1 definition)

A **Module** is a standalone runnable **product unit** with:

- its own UI/screens/routes
- its own domain logic
- its own data storage (separate DB)
- its own public **contract** (events/types/hook names)
- ability to run alone OR with other modules **without code changes**

---

## 2) Module Rules (Non‑negotiable)

### 2.1 Isolation (imports)
Modules must never import other modules’ internal code.

Allowed imports:
- `package:foundation/...`
- another module’s **contract** only (public types/events/hook names)

Forbidden:
- importing `lib/src/` of another module
- calling another module’s services directly
- reading another module’s DB

### 2.2 Integration
Modules integrate only through Foundation registries:
- EventBus (events)
- HookRegistry (extensions)
- RouteRegistry (navigation)

### 2.3 Data boundary
- each module owns its DB file (`<module>.db`)
- no cross-module transactions
- no cross-module reads
- read needs across modules must be done via **projections** (events → local derived tables/models)

---

## 3) Module Folder Structure (V1 template)

Each module is a **Flutter package** under `modules/<name>/`:

```
modules/<name>/
  pubspec.yaml
  module.json

  lib/
    <name>.dart                # minimal public export
    contract/                  # ONLY public surface
      contract.dart            # re-export contract
      events/
      hooks/
      routes/

    src/                       # PRIVATE implementation (never imported by other modules)
      module/
      ui/
      domain/
      data/
        db/
        migrations/

  example/                     # runnable standalone mini-app
    pubspec.yaml
    lib/
      main.dart
```

### Why `example/` is mandatory
It ensures every module can be run alone (product mindset).  
You can run:
- `flutter run` inside `modules/todo/example`

---

## 4) Module Contract (Public Surface)

A module’s public surface is **only** what’s inside:

- `lib/contract/**`

### What belongs in `contract/`
- typed event classes this module publishes
- hook name constants/specs the module defines
- route constants/types (optional)
- DTOs/types meant for other modules (keep minimal)

### What must NOT be in `contract/`
- database code
- repositories/services/use-cases
- UI widgets/screens
- internal helpers

> Rule of thumb: If another module uses it, it must be stable and versioned.

---

## 5) Module Interface (Industrial Lifecycle)

Each module must implement these lifecycle phases:

1. `registerContracts()`
2. `registerSubscriptions()`
3. `registerHooks()`
4. `registerRoutes()`
5. `start()` / `stop()`

### Intent of each phase

#### 5.1 `registerContracts()`
Purpose: declare what this module “speaks” publicly (events/hook definitions/route constants).

- Define hooks your module owns (via HookRegistry).
- Keep all event types in `contract/events/`.

#### 5.2 `registerSubscriptions()`
Purpose: subscribe to other modules’ events.

- Used to build **projections**.
- Must not query other modules.
- Must tolerate “publisher not present” (if other module isn’t loaded).

#### 5.3 `registerHooks()`
Purpose: contribute to hooks defined by other modules.

- Must tolerate “other module not present”:
  - if hook doesn’t exist, strict-dev will throw
  - so contributions should only target hooks you are confident exist in the composition
  - (later: capability checks, not in V1)

#### 5.4 `registerRoutes()`
Purpose: register this module’s screens/routes.

- Use module-prefixed routes: `/<module>`
- Never register `/` (reserved for foundation)

#### 5.5 `start()` / `stop()`
Purpose: start runtime work:
- open DB
- start services/timers
- initialize state

Stop:
- close DB
- cancel timers/subscriptions

---

## 6) `module.json` Manifest (V1)

### Location
`modules/<name>/module.json`

### Required fields (V1)
```json
{
  "name": "todo",
  "version": "1.0.0",
  "entry": "todo",
  "dependencies": [],
  "main_route": "/todo"
}
```

### Field meaning (V1)
- `name`: unique module name (must equal folder name)
- `version`: SemVer string
- `entry`: module key used by the runner’s **module registry map**
  - (Flutter cannot dynamically import arbitrary files at runtime)
- `dependencies`: runtime module dependencies (names)
- `main_route`: module’s primary route path

### Validation rules (fail fast)
- `name` matches folder name
- `name` unique across repo
- `version` is valid SemVer
- `main_route` starts with `/`
- every dependency exists
- no dependency cycles

---

## 7) Dependency Rules (V1)

### 7.1 Auto-add dependencies
If the runner asks for:
- `run todo`

and Todo depends on Calculator, loader must:
- auto-add `calculator`

So the loaded set becomes:
- `{ calculator, todo }`

### 7.2 Topological order
Dependencies start first:
- `calculator` before `todo`

Cycle must fail fast:
- `Dependency cycle detected: todo -> calculator -> todo`

---

## 8) Projections (Read Integration Rule)

When Module A needs “read info” from Module B:

✅ Do:
- subscribe to B’s events
- store derived data locally in A’s DB
- read locally for UI

❌ Don’t:
- query B’s DB
- call B synchronously
- share repositories

### V1 example
- Calculator publishes: `CalculationCompleted`
- Todo subscribes and stores:
  - `todo_calc_stats(date, count)` in `todo.db`
- Todo UI reads from `todo.db`

---

## 9) Route & Hook Conventions (V1)

### Routes
- `/<module>` is the main route
- Example:
  - `/todo`
  - `/calculator`
- `/` reserved for Foundation

### Hook names
- `<ownerModule>.<area>.<purpose>`
- Example:
  - `todo.home.actions`
  - `inventory.item.details.tabs`

---

## 10) State Management Rules (Flutter) — V1

Keep state local to the module:

- UI widgets must not contain business logic
- domain/services live under `src/domain/` or `src/data/`
- module can use Bloc/Cubit/Provider/Notifier internally
- no cross-module state sharing

Cross-module coordination MUST be:
- events + projections
- hooks
- routes

---

## 11) Quality Gates (V1)

A module is “V1 compliant” only if:

- it runs standalone via `example/`
- it exposes only `contract/` to other modules
- it never imports other module internals
- it owns its own DB file
- it registers routes without collision
- its integrations are event/hook based

---

## Summary

A module is a **product** with strict boundaries:
- contract = public
- src = private
- data isolated
- integration via foundation registries only

Next doc after this: **Runner & Composition Spec — V1**  
(How we select modules to run, config format, module registry map, and boot flow.)
