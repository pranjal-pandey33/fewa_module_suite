# Fewa Modular Suite (Foundation-First) — V1 Architecture

## Project Overview

**Project Name**: Fewa Modular Suite (Foundation-First)  
**Tech Stack**: Flutter (apps + modules), Dart (foundation engine)  
**Architecture**: Foundation-first modular architecture (modules are standalone runnable products + composable suite)  
**Target**: ERP-style multi-product suite (future: Pharmacy, Inventory, Billing, Accounting, CRM). V1 practice modules: **Todo + Calculator**.

---

## Core Principles (Non‑Negotiable)

1. **Modules are standalone runnable products**
   - A module must be runnable by itself (with minimal config).
   - A module may also run together with other modules without code changes.

2. **Modules never import each other**
   - No `import` of another module’s internal code.
   - Allowed imports:
     - `package:foundation/...`
     - another module’s **contract** only (public types/events/hook names)

3. **Automatic connection happens through Foundation registries**
   - Modules only **register** what they provide/consume.
   - Foundation wires everything at runtime (no manual glue inside modules).

4. **Data isolation**
   - Separate DB per module (`todo.db`, `calculator.db`, future modules).
   - No cross-module transactions.
   - Cross-module integration via events + projections.

---

## Architecture at a Glance

### What “Foundation” is
Foundation is the **engine/runtime** that:
- loads modules
- wires them together
- aggregates routes
- dispatches events
- manages lifecycle

### What a “Module” is
A module is a **product unit** with:
- its own UI routes/screens
- its own domain logic
- its own DB/storage
- its own public **contract** (events/types/hook names)

---

## Project Structure (Folder Layout)

> Final V1 structure for Flutter.

```
repo/
  README.md

  packages/
    foundation/                 # PURE DART package (engine)
    module_contracts/           # optional: shared base types (Event base, HookSpec, etc.)

  modules/
    todo/                       # Flutter package (standalone product)
    calculator/                 # Flutter package (standalone product)

  apps/
    launcher/                   # thin runner app to run 1+ modules together
```

### `packages/foundation/` (Pure Dart engine)
Purpose: kernel registries + module loader + runtime orchestration + foundation “/” home.

### `modules/<module>/` (Standalone Flutter packages)
Each module is a Flutter package that can run alone or in suite.

### `apps/launcher/` (Thin runner)
A minimal Flutter app that boots Foundation runtime and runs selected module(s).  
This is **not** a permanent “main shell product”.

---

## Foundation Kernel Components (V1)

### 1) EventBus (typed, sync)
**What it is**: in-app “post office”  
**What it does**:
- modules publish typed events
- other modules subscribe without knowing the publisher

**Rules**
- typed events only
- sync delivery (in-process)
- publish is OK even if zero subscribers

### 2) HookRegistry (strict hooks)
**What it is**: plugin slot system  
**What it does**:
- a module defines “hook points”
- other modules contribute items to those hooks

**Rules**
- strict in dev: contributing to an undefined hook = error
- stores contributions by hook name

### 3) RouteRegistry (aggregation + collision protection)
**What it is**: global route collector  
**What it does**:
- modules register routes/screens
- foundation merges them into one navigation map

**Rules**
- collisions are rejected (same path claimed by two modules)
- convention: module-prefixed paths (`/todo`, `/calculator`)

### 4) ModuleLoader (discovery + composition engine)
**What it is**: the conductor  
**What it does**:
- discovers modules via `module.json` manifests
- auto-adds dependencies
- topological sorts modules (deps first)
- runs lifecycle in strict order

---

## Module Contract (Industrial Interface)

Every module must implement:

- `registerContracts()`
- `registerSubscriptions()`
- `registerHooks()`
- `registerRoutes()`
- `start()` / `stop()`

And include a manifest:

### `module.json` (per module)
Contains:
- `name`, `version`
- `entry` (module entrypoint)
- `dependencies` (runtime deps)
- (optional) `main_route`

---

## Lifecycle Order (Strict)

For **all loaded modules**:

1. `registerContracts()`
2. `registerSubscriptions()`
3. `registerHooks()`
4. `registerRoutes()`
5. `start()`

Shutdown:
- `stop()` in reverse order (dependents first)

---

## Running (V1)

- Run single:
  - `run todo` → loads Todo only
- Run multiple:
  - `run todo,calculator` → loads both and auto-wires events/hooks/routes
- `/` is always reserved for Foundation Launcher Home

---

## Data Policy (V1)

### Storage boundaries
- each module owns its DB file
- modules do not read/write other modules’ DB

### Integration via events
- module publishes events
- other modules subscribe and update their own data

### Projections (read integration)
If Todo needs “stats” from Calculator:
- Todo subscribes to Calculator events
- Todo stores derived stats locally in `todo.db`
- Todo UI reads from its own DB (never from calculator DB)

---

## Versioning Policy (V1)

### Typed event versioning
Breaking change → new event type:
- `CalculationCompletedV2`

### Deprecation window
Support old versions for:
- **2 minor releases or 90 days** (whichever is longer)

During window:
- publisher may emit both V1 and V2
After window:
- stop emitting V1

---

## State Management Rules (Flutter) — V1

- Each module manages its state internally (Cubit/Bloc/Notifier), but:
  - **No business logic in Widgets**
  - UI reads state; domain logic lives in module services/use-cases
- No cross-module shared state.
  - Cross-module coordination must be **events/hooks/routes only**.

---

## Quality Gates (V1 Minimum)

- Route collision must fail fast (clear error message)
- Undefined hook contribution must fail fast in dev
- Dependency cycle must fail fast with chain shown
- Each module must be runnable alone (no “suite-only” assumptions)

---

## V1 Example (Todo + Calculator)

- Calculator publishes: `CalculationCompleted(expression, result)`
- Todo subscribes and updates a local projection:
  - “calculations done today”
- Calculator contributes to Todo hook:
  - `todo.home.actions` → “Open Calculator”

This is the exact pattern we will reuse for future ERP modules.
