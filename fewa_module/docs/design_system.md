# FEVA MODULAR SUITE — DESIGN SYSTEM (V1)

This document defines the global visual system used across all modules.
No module is allowed to override core design tokens.

Goal:
Create a unified, scalable, enterprise-grade visual language
for a modular ERP-style product suite.

---

# 1. Design Philosophy

System must feel:

- Professional
- Calm
- Fast
- Data-oriented
- Minimal
- Modular

No playful gradients.
No random accent colors.
No heavy shadows.
No over-animation.

Think:
Linear + Stripe + Notion discipline.

---

# 2. Core Design Tokens

All tokens must live in foundation or a shared design package.

No hardcoded hex values inside modules.

---

## 2.1 Color System

### Brand

Primary: Indigo 600 (#4F46E5)
Primary Hover: Indigo 500 (#6366F1)
Primary Pressed: Indigo 700 (#4338CA)

Accent: Emerald 500 (#10B981)

Error: Red 500 (#EF4444)
Warning: Amber 500 (#F59E0B)
Success: Emerald 500 (#10B981)

---

### Neutral Palette

Background: #F9FAFB
Surface: #FFFFFF
Border: #E5E7EB

Text Primary: #111827
Text Secondary: #6B7280
Text Muted: #9CA3AF

Dark Mode (future support):

Background: #0F172A
Surface: #1E293B
Border: #334155
Text Primary: #F1F5F9
Text Secondary: #94A3B8

---

# 3. Typography System

Font: Inter (fallback: system)

Hierarchy:

H1: 24px / 600
H2: 18px / 600
H3: 16px / 500
Body: 14px / 400
Caption: 12px / 400
Button: 14px / 500

Letter spacing:
- Slight negative for headers (-0.3)
- Default for body

No custom font sizes outside system scale.

---

# 4. Spacing System

Base unit: 8px

Allowed spacing values:
8 / 16 / 24 / 32 / 40 / 48

No arbitrary padding like 13 or 21.

Consistency over creativity.

---

# 5. Elevation & Shadows

Cards:
- Border radius: 12px
- Elevation: 0–2 only
- Prefer borders over heavy shadows

Modals:
- Elevation 4 max

ERP UI must feel stable, not floating everywhere.

---

# 6. Component Guidelines

## 6.1 Buttons

Primary:
- Filled with Primary color
- Height: 40px
- Radius: 8px

Secondary:
- Outlined
- Border color: #E5E7EB

Danger:
- Red filled

No rounded-pill enterprise buttons.

---

## 6.2 Cards

Radius: 12px
Padding: 16px
Border: 1px neutral border

No gradient backgrounds.

---

## 6.3 Lists

Row height min: 56px
Divider: 1px border color
Hover state (desktop): subtle surface tint

---

# 7. Layout Rules

Container max width:
- 720px (desktop center alignment)

Mobile:
- Full width

Tablet/Desktop:
- Increased horizontal padding (32px)

No full-bleed text-heavy layouts.

---

# 8. Animation System

Small transitions: 150ms
Standard transitions: 250ms
Curve: easeOut

No bouncy effects.
No elastic animations.
ERP ≠ gaming app.

---

# 9. Hook-Compatible UI Zones

Every module must support:

- AppBar action injection
- Dashboard stat injection
- Contextual action injection

Hooks must not break layout.
Design must anticipate dynamic additions.

---

# 10. Theming Rules

Modules must:

- Use Theme.of(context)
- Not create new ThemeData
- Respect dark/light mode
- Not override typography scale

Theme must be defined once in foundation or launcher.

---

# 11. Accessibility Rules

- Minimum tap target: 44px
- Contrast ratio > 4.5
- No color-only indicators
- Support dynamic text scaling

---

# 12. Iconography

Use:
Material Icons (outlined style preferred)

Icon size:
20px inline
24px standard
28px large

No mixed icon libraries.

---

# 13. Design Governance Rules

Modules are forbidden from:

- Hardcoding colors
- Introducing custom font sizes
- Creating their own theme
- Breaking spacing scale

All UI must comply with this system.

Violations must be rejected in review.

---

END OF DESIGN SYSTEM (V1)
