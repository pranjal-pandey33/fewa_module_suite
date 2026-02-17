# Runner & Composition Spec — V1 (Flutter)

> This document defines **how modules are selected, discovered, instantiated, and composed** into a runnable Flutter app.
> This is the missing “implementation reality” doc for Flutter/Dart (no dynamic runtime imports).

---

## 1) Goal (Runner Responsibility)

The Runner (apps/launcher) must support:

- Run single module: `todo`
- Run multiple modules: `todo,calculator`
- Automatically load dependencies
- Compose routes + hooks + events with **no manual glue inside modules**
- Always keep `/` reserved for Foundation Launcher Home

---

## 2) Runner Inputs (V1)

V1 supports **one** official input method (keep it simple):

### 2.1 `--dart-define=MODULES=...`
Example:
- `flutter run --dart-define=MODULES=todo`
- `flutter run --dart-define=MODULES=todo,calculator`

Rules:
- Value is a comma-separated list of module names
- Whitespace trimmed
- Empty value → error

> Future (out of V1): JSON config file, profiles, environments.

---

## 3) Discovery (How we find available modules)

### 3.1 Discovery path
The runner discovers module manifests at:

- `modules/*/module.json`

### 3.2 Manifest parse output
Each manifest becomes a `Manifest` record with:
- `name`
- `version`
- `entry` (V1: key for registry map, not a file path)
- `dependencies` (module names)
- `main_route`

### 3.3 Validation (fail fast)
Runner MUST fail fast if any manifest is invalid:

- missing required fields
- `name` not equal to folder name
- duplicate `name`
- invalid SemVer
- invalid route (must start with `/`)
- dependency refers to unknown module
- dependency cycles exist

Error format (required):
- `Duplicate module name: <name>`
- `Missing dependency: <dep> required by <module>`
- `Dependency cycle detected: A -> B -> A`
- `Invalid manifest: <module> (<reason>)`

---

## 4) Instantiation (Flutter/Dart reality)

### 4.1 Why we need a registry map
Flutter/Dart cannot dynamically import arbitrary module source files at runtime in a production build.

Therefore, V1 uses:

✅ **Static Module Registry Map** inside the runner app.

### 4.2 Module registry map (V1)
The runner maintains a map:

- `moduleName -> ModuleFactory()`

Rules:
- Every discovered module **must** have a factory registered.
- Missing factory → fail fast:
  - `No factory registered for module: <name>`

> Future (out of V1): auto-generate the registry via build_runner or a simple script.

---

## 5) Composition Algorithm (V1)

Given user-selected modules `S` from `MODULES=...`:

### 5.1 Discover all manifests `M`
Scan `modules/*/module.json` → `manifestsByName`.

### 5.2 Expand the load set (auto-add dependencies)
Create `LoadSet = closure(S)` where closure means:

- For each module in LoadSet:
  - add all dependencies from its manifest
- Repeat until no new modules are added

If a dependency is missing from manifests:
- error: `Missing dependency: <dep> required by <module>`

### 5.3 Build dependency graph
Edge direction (required):

- `dep -> module`  
(so deps come first in topo order)

### 5.4 Topological sort
Topo sort `LoadSet` using the graph.

If cycle:
- error: `Dependency cycle detected: A -> B -> A`

Output:
- `modulesInOrder` (deps first)

---

## 6) Boot Flow (Strict Runtime Order)

Runner creates Foundation runtime with registries + loader results, then boots.

### 6.1 Strict lifecycle phases (must match docs)
For all modules in `modulesInOrder`:

1. `registerContracts()`
2. `registerSubscriptions()`
3. `registerHooks()`
4. `registerRoutes()`

Then:

5. Foundation registers `/` route (Launcher Home)
6. `start()` for each module (deps first)

Shutdown:
- `stop()` in reverse order

### 6.2 Why this boot flow matters
- Everyone sees contracts before consuming.
- Subscriptions exist before events start flowing.
- Hooks defined before UI tries to read contributions.
- Routes aggregated before router build.
- Start happens only after all wiring is complete.

---

## 7) Router Composition (Flutter)

### 7.1 Source of truth
The router is built from **RouteRegistry** after all modules register routes.

### 7.2 Route collision enforcement
If two routes share the same path:
- fail fast:
  - `Route collision: "<path>" owned by "<A>" and "<B>"`

### 7.3 Route conventions
- Module primary routes:
  - `/todo`, `/calculator`, etc.
- `/` reserved for Foundation Launcher Home.

> V1 UI implementation can use GoRouter or Navigator 1.0.
> The contract is the same: RouteRegistry must supply `path + builder + ownerModule`.

---

## 8) Hook Composition (Runner Expectations)

HookRegistry strictness (V1):
- strict in dev: contributing to undefined hook throws

Runner responsibility:
- initialize HookRegistry in strict mode for dev builds
- (future) allow non-strict in release via config

---

## 9) Storage Root & DB Paths (V1)

Runner must provide each module a module-specific storage directory:

- `<appDataDir>/modules/<moduleName>/`

DB file path convention:
- `<moduleDir>/<moduleName>.db`

Rules:
- modules never read/write outside their own moduleDir
- no shared DB

---

## 10) Minimum Logs & Diagnostics (V1)

Runner should log these events (for debugging composition):

- selected modules list
- expanded load set after deps
- topo order
- lifecycle phase start/end
- registered routes list
- collision/validation errors with clear messages

---

## 11) Example Walkthrough (Todo + Calculator)

Input:
- `MODULES=todo`

Manifests:
- todo depends on calculator

Process:
1. LoadSet starts `{todo}`
2. Auto-add deps → `{todo, calculator}`
3. Topo sort → `[calculator, todo]`
4. Run lifecycle phases in that order
5. Build router from RouteRegistry
6. App runs with `/` home + `/calculator` + `/todo`

Guarantees:
- If only Todo selected, Calculator still loads automatically if required.
- If Todo does not depend on Calculator, selecting Todo alone does not load Calculator.

---

## Summary

Runner is responsible for:
- selecting modules (dart-define)
- discovering manifests
- resolving deps + topo ordering
- instantiating modules via registry map
- booting Foundation runtime in strict lifecycle order
- building router from RouteRegistry

After this doc, the agent can implement V1 without guessing.
