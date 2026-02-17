# Contracts, Versioning & Testing — V1 (Flutter Modular Suite)

> This document locks the rules for **contracts** (events/hooks/routes), **versioning** (especially event evolution), and the **minimum test suite** required to ship V1 safely.
> Goal: make agent implementation consistent and prevent silent breakages.

---

## 1) Contracts — What is “Public” in V1

### 1.1 Contract boundary
A module’s public surface (contract) is:

- `modules/<name>/lib/contract/**`

Everything else is private:
- `modules/<name>/lib/src/**`

### 1.2 What goes into contracts
Contracts may contain only:
- typed **events** (classes)
- hook name constants / hook specs
- route constants/types (optional)
- DTOs/types shared across modules (keep minimal)

Contracts must NOT contain:
- repositories/services
- DB schema/migrations
- UI widgets/screens
- internal helpers

### 1.3 Contract stability rule
If another module depends on it, it must be:
- documented
- versioned (when changed)
- backward compatible when possible

---

## 2) Events Contract (Typed Events)

### 2.1 Event naming rules
Events are facts that already happened (past tense).

✅ Good:
- `CalculationCompleted`
- `InvoiceCreated`
- `StockAdjusted`

❌ Bad:
- `CalculateNow`
- `CreateInvoiceRequest`

### 2.2 Event structure rules
- Events must be immutable (final fields).
- Prefer primitive/serializable fields (string/num/bool/DateTime).
- Use explicit names, avoid ambiguous fields like `data`.

### 2.3 Event ownership rule
The module that publishes the event owns its definition:
- `modules/calculator/lib/contract/events/calculation_completed.dart`

Consumers import the contract:
- `package:calculator/contract/events/calculation_completed.dart`

### 2.4 Sync delivery (V1)
- EventBus delivery is synchronous in-process.
- Handler execution happens during `publish`.

Failure rule (V1):
- A handler throwing should fail fast in dev builds.
- (Future: isolate errors per handler)

---

## 3) Hooks Contract (Hook Names + Specs)

### 3.1 Hook naming convention
Use this shape:
- `<ownerModule>.<area>.<purpose>`

Examples:
- `todo.home.actions`
- `pharmacy.invoice.lines`
- `inventory.item.details.tabs`

### 3.2 Hook definition rule
- Hook must be defined by the owning module before others contribute.

V1 strictness:
- contributing to an undefined hook throws in dev:
  - `Hook not defined: <hookName>`

### 3.3 Contribution ordering rule (V1)
Contributions are stored in insertion order.
- (Future: priorities/weights)

---

## 4) Routes Contract (Paths)

### 4.1 Route naming convention
Module-prefixed routes:
- `/<module>` for main route
- `/<module>/<sub>` for sub routes

Examples:
- `/todo`
- `/todo/create`
- `/calculator`

### 4.2 Reserved route
- `/` is reserved for Foundation Launcher Home
- modules must never register `/`

### 4.3 Collision protection
Two modules registering the same path must fail fast:
- `Route collision: "<path>" owned by "<A>" and "<B>"`

---

## 5) Versioning Policy — V1

## 5.1 SemVer scope
- Module `version` in `module.json` uses SemVer:
  - `MAJOR.MINOR.PATCH`
- Breaking contract change increments **MAJOR**
- Backward compatible contract additions increment **MINOR**
- Fixes increment **PATCH**

---

## 5.2 Typed Event Versioning (Breaking changes)

### When do we need V2?
If you change any of these, it’s breaking:
- rename event class
- remove/rename a field
- change field meaning/type
- change required/optional behavior in a way old consumers can’t handle

### Rule: new event type for breaking changes
Create a new event class:
- `CalculationCompletedV2`

Do NOT mutate the old type and hope consumers survive.

---

## 5.3 Deprecation window (locked)

Old contract versions are supported for:
- **2 minor releases or 90 days** (whichever is longer)

During the window:
- publisher may emit both V1 and V2
- consumers migrate to V2

After the window:
- publisher stops emitting V1

> This rule applies to events primarily. It can also apply to hooks/route constants if they are treated as contract APIs.

---

## 5.4 Compatibility tactics (recommended)

### Additive changes (non-breaking)
- adding a new optional field is OK
- adding a new event type is OK
- adding a new hook is OK

### Breaking changes
- create V2 event types
- provide migration notes
- dual-emit during window if needed

---

## 6) Testing — V1 Minimum Suite

> V1 must ship with tests that prove: composition works, registries enforce rules, and versioning won’t silently break things.

---

## 6.1 Foundation tests (packages/foundation/test)

### EventBus
- publish with 0 subscribers does not crash
- publish delivers to subscribers synchronously
- multiple subscribers all receive the event
- subscription type separation works (A does not receive B)

### HookRegistry (strict mode)
- contributing to undefined hook throws
- defining hook then contributing stores items
- contributions are returned in insertion order

### RouteRegistry
- registering unique routes succeeds
- collision throws with correct error message
- getRoutes returns all registered routes

### ModuleLoader / Dependency resolution
- auto-add dependencies works
- topo order is correct (deps before dependents)
- missing dependency throws
- cycle detection throws and includes chain

### FoundationRuntime lifecycle
- methods are called in strict order:
  - registerContracts → registerSubscriptions → registerHooks → registerRoutes → start
- stop called in reverse topo order

---

## 6.2 Module compliance tests (per module)

Each module should have at least:
- “runs standalone” smoke test (example app compiles/boots)
- contract boundary check (no other module imports `src/`)
  - (manual rule in V1; future: lint rule)

---

## 6.3 Integration tests (apps/launcher)

Runner must prove:
- selecting `todo` auto-adds calculator if dependency exists
- route collision fails fast
- hook undefined contribution fails fast in dev
- navigation map includes `/` + module routes after boot

---

## 7) Documentation requirements (for agent + humans)

For every new contract (event/hook/route API), add:
- short description
- owner module
- version change note if modified
- migration note if V2 introduced

---

## Summary (What V1 guarantees)

- Contracts are clean and minimal (contract/ only)
- Events are typed and versioned safely (V2 when breaking)
- Deprecations have a clear window (2 minor or 90 days)
- Tests enforce the architecture so it doesn’t rot

After this doc: we can start coding Foundation kernel one component at a time.
