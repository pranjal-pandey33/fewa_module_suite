# TODO MODULE — UI DESIGN SPEC (V2)

This module strictly follows:
- design_system.md
- Modular Architecture Rules
- Projection & Lifecycle Discipline

No deviation from global design tokens is allowed.

---

# 1. Design Intent

Todo is not a casual task app.
It is a productivity module inside a modular ERP system.

Tone:
- Calm
- Structured
- Data-aware
- Expandable
- Enterprise-clean

It must feel stable and scalable.

---

# 2. Layout Philosophy

Todo is a data + workflow module.

It consists of:

AppBar
↓
Dashboard Zone (Projection-aware stats)
↓
Task List
↓
Primary Action (FAB)

Max width: 720px
Centered on desktop.
Full-width on mobile.

---

# 3. AppBar Specification

Title:
- "Todo"
- H2 style from global typography

Right-side Hook Slot:
- todo.appbar.actions

Purpose:
Allow other modules to inject:
- Quick calculator
- Filter dropdown
- Export
- Bulk actions

Rules:
- Hook icons must not break spacing
- Max 3 icons visible
- Overflow into menu if exceeded

---

# 4. Dashboard Zone (Projection UI)

This zone displays derived data (from projection store).

Primary Stat Card:
- "Calculation Events Today"
- Uses TodoProjectionStore value

Card Style:
- Radius: 12px
- Padding: 16px
- Border: 1px neutral
- No heavy shadow

Stat Layout:

Label:
- Caption style
- Secondary text color

Value:
- 24px
- FontWeight 600
- Primary text color

Hook Slot:
- todo.dashboard.cards

Other modules may inject additional stat cards.

Example:
- "Tasks Completed"
- "Overdue"
- "Linked Calculations"

---

# 5. Task List Section

Structure:

Vertical ListView
Divider between rows
Minimum row height: 56px

Each Task Row Contains:
- Checkbox
- Title (Body style)
- Metadata (Caption)
- Trailing hook zone

Hook Slot:
- todo.task.item.trailing

Allows:
- Assign user
- Set priority
- Attach document
- Link calculation

---

# 6. Floating Action Button

Purpose:
Add new task

Style:
- Primary filled
- Radius: 28px
- Icon: plus

Behavior:
- Opens bottom sheet (mobile)
- Opens dialog (desktop)

No inline text inputs inside list.

---

# 7. Interaction Design

Checkbox:
- Animated
- 150ms transition
- No bounce

Completed Task:
- Strike-through text
- Opacity 0.6
- Smooth state update

Add Task Modal:
- Surface background
- 24px internal padding
- Clear call-to-action button

---

# 8. State & Projection Discipline

UI must NOT:

- Access EventBus
- Call projection init()
- Contain business logic
- Mutate state directly

UI must:

- Listen to ValueNotifier from ProjectionStore
- React via ValueListenableBuilder

All data flows:

Event → ProjectionStore → ValueNotifier → UI

---

# 9. Folder Structure (Strict)

lib/
  ui/
    screens/
      todo_home.dart
    widgets/
      task_item.dart
      stat_card.dart
    layout/
      todo_scaffold.dart
    hooks/
      hook_zones.dart

Rules:

- Screens compose widgets only
- Widgets must remain stateless when possible
- No business logic inside ui/
- ProjectionStore lives in src/data/
- Module logic lives in src/module/

---

# 10. Responsive Rules

Mobile:
- Single column layout
- FAB bottom-right

Tablet:
- Increased horizontal padding (32px)

Desktop:
- Centered container (max 720px)
- Future: side metadata panel

---

# 11. Animation Rules

Small transitions: 150ms
Standard transitions: 250ms
Curve: easeOut

Do not animate list reordering heavily.
ERP UI must feel stable.

---

# 12. Theming Compliance

Must use:
Theme.of(context)
TextTheme from global system

Must NOT:
- Define new ThemeData
- Hardcode hex colors
- Override typography scale

---

# 13. Accessibility

- Tap targets ≥ 44px
- Proper semantic labels
- Keyboard navigation (future)
- High contrast text

---

# 14. Extensibility Constraints

Design must remain stable when:

- Priority system added
- Tags introduced
- Due dates added
- Multi-user support introduced
- Permissions layer introduced

Layout must not collapse under feature expansion.

---

# 15. Governance Rules

Violations:

- Random padding values
- Inline styles
- Business logic in UI
- Breaking hook layout
- Visual inconsistency with design_system.md

### Everytime you start implementing the code , always read all the md files of /docs/
Must be rejected in review.

---

END OF TODO MODULE DESIGN SPEC (V2)
