# CALCULATOR MODULE — UI DESIGN SPEC (V1)

This module follows the global Design System (design_system.md).
No deviation from shared tokens is allowed.

Design Goal:
A clean, enterprise-grade calculator that feels like a serious tool —
not a toy app.

Tone:
Minimal
Precise
Functional
Focused

---

# 1. Visual Philosophy

Calculator is a utility module.
It should feel:

- Fast
- Accurate
- Deterministic
- Structured

No playful animations.
No bright color explosions.
No skeuomorphic design.

Think:
Financial calculator inside an ERP dashboard.

---

# 2. Layout Structure

## 2.1 Page Structure

AppBar
↓
Display Area
↓
Keypad Area
↓
Optional Footer Hook Zone

Max container width: 480px (tool-centered layout)
Centered on desktop.

Mobile: full width.

---

# 3. AppBar

Left:
- Title: "Calculator"

Right:
- Hook slot: calculator.appbar.actions

Allows:
- Clear history
- Export result
- Save to Todo
- Injected tools from other modules

AppBar height: standard Material height
No custom styling.

---

# 4. Display Section

Primary display zone for expression + result.

Structure:

Top:
- Expression (muted text)
Bottom:
- Result (large, bold)

Spacing:
- 24px vertical padding
- 16px horizontal padding

Expression style:
- 14px
- Secondary text color

Result style:
- 32px
- FontWeight 600
- Primary text color

Right-aligned numeric text.

Background:
- Surface color
- Subtle border bottom (1px neutral border)

---

# 5. Keypad Layout

Grid: 4 columns

Buttons:
7 8 9 ÷
4 5 6 ×
1 2 3 −
0 . = +

Button Size:
- Minimum 56px height
- Equal width grid

Spacing:
- 8px between buttons
- 16px outer padding

---

# 6. Button Styles

## 6.1 Number Buttons

Background: Surface
Border: 1px neutral border
Text: Primary text color

Hover (desktop):
- Slight surface tint

---

## 6.2 Operator Buttons

Background: Primary color (low opacity 10%)
Text: Primary color

---

## 6.3 Equals Button

Background: Primary (solid)
Text: White

This is the primary action.

---

## 6.4 Clear Button

Background: Red (subtle tint)
Text: Red 500

---

# 7. Interaction Design

Button press animation:
- 150ms
- Slight scale down (0.97)
- No bounce

Display update:
- Fade transition (150ms)
- No sliding animations

Typing feedback must feel instant.

---

# 8. Projection & Integration

Calculator publishes:
- CalculationCompleted event

UI must not:
- Directly call Todo
- Contain projection logic

Hook zone:
calculator.result.actions

Allows:
- "Save to Todo"
- "Create invoice"
- "Send to billing"

Modules can inject actions without modifying Calculator code.

---

# 9. Responsive Behavior

Mobile:
- Full screen tool layout

Tablet:
- Centered max width 480px

Desktop:
- Centered tool panel
- Optional side metadata panel (future expansion)

---

# 10. Theming Rules

Must use:
Theme.of(context).colorScheme
TextTheme

No hardcoded hex colors.

Dark mode must work without layout shift.

---

# 11. Accessibility

- Minimum 44px tap area
- High contrast numeric display
- Screen reader friendly labels for operators

---

# 12. Folder Structure (Enforced)

lib/
  ui/
    screens/
      calculator_home.dart
    widgets/
      keypad_button.dart
      calculator_display.dart
    layout/
      calculator_scaffold.dart

Rules:
- No business logic in widgets
- Expression state must come from module state
- UI must remain replaceable

---

# 13. Future Extensions

- Calculation history panel
- Scientific mode
- Financial mode
- Memory registers
- Export to CSV
- Multi-currency support

Layout must allow vertical expansion.

---

# 14. Non-Negotiables

- No skeuomorphic design
- No inconsistent button sizes
- No random color additions
- No playful animations

Calculator must feel enterprise-grade.

---

END OF CALCULATOR MODULE DESIGN SPEC (V1)
