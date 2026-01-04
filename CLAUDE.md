# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Merce is a **modular Qt 6.11+ QML design system** for smart cart ecosystem applications (kiosks, tablets, embedded systems). The project uses a layered architecture with strict type safety through Qt 6.11's new property semantics (`virtual`, `override`, `final`, `required`).

**Shopping-Optimized:** The color palette is designed for e-commerce conversion with warm terracotta primary colors and semantic tokens for pricing, badges, and product status.

## Status

✅ Core Foundation - **IMPLEMENTED** (Theme tokens broken into modular singletons)
🔧 Foundation Components - **IMPLEMENTED** (MSurface, MText, MBaseControl)
🔧 Controls - **IMPLEMENTED** (MButton, MInput)
🔧 Notifications - **IMPLEMENTED** (MToast, MDialog)

## Architecture

### Module Hierarchy (Dependency Tree)

```
Application (SmartCart App)
    ├── Merce.Controls (MButton, MInput, etc.)
    │       └── Merce.Foundation (MSurface, MText)
    │               └── Merce.Core (Theme, Palette, Icons)
    └── Merce.Notifications (MToast, MDialog)
            └── Merce.Foundation
                    └── Merce.Core
```

**Key Rule:** Modules only depend on modules below them in the hierarchy.

### Module Structure

```
/Merce
├── CMakeLists.txt              # Root build configuration
├── /Core                       # URI: Merce.Core (Theme, Palette, Icons)
├── /Foundation                 # URI: Merce.Foundation (MSurface, MText)
├── /Controls                   # URI: Merce.Controls (MButton, MInput)
└── /Notifications              # URI: Merce.Notifications (MToast, MDialog)
```

Each module has its own `CMakeLists.txt` and is a separate CMake target.

## Qt 6.11+ Property Semantics

The design system relies heavily on Qt 6.11's property modifiers:

### `virtual` Properties
- Can be overridden by child components
- Used for customizable styling (colors, fonts, etc.)
- Example: `virtual property color accentColor: "blue"`

### `override` Properties
- Required when explicitly overriding a parent's `virtual` property
- Signals intention clearly in the code
- Example: `override property color accentColor: Theme.colors.action.primary`

### `final` Properties
- Cannot be overridden by child components
- Used for system standards (touch target sizes, accessibility requirements)
- Example: `final property int touchTarget: 44`

### `required` Properties
- Must be provided by the component user
- Enforces component contracts
- Example: `required property int surfaceType`

## Theme System

Theme is modularized into separate singletons (all in `Merce.Core`):

```qml
import Merce.Core

// Main entry point - combines all tokens
Theme.colors.action.primary           // Primary action color
Theme.spacing.md                       // 16px spacing
Theme.typography.body.size             // 16px font size
Theme.radius.button                    // 12px border radius
Theme.shadows.card                     // Card shadow preset

// Direct singleton access (also available)
Palette.raw.primary                    // Raw color value #C4785A
Spacing.touchTarget                    // 44px minimum
Typography.fontBody                    // "DM Sans"
```

### Token Files

| File | Purpose |
|------|---------|
| `Theme.qml` | Main entry point, imports all other singletons |
| `Palette.qml` | Color palette (action, product, text, background, border, status) |
| `Spacing.qml` | 8pt-based spacing scale with touch targets |
| `Typography.qml` | Font families, sizes, weights, and preset styles |
| `Radius.qml` | Border radius values |
| `Shadows.qml` | Elevation/shadow presets |
| `Motion.qml` | Animation durations and easing functions |

### Shopping-Specific Color Tokens

```qml
// Product colors
Theme.colors.product.priceRegular      // #1F1510
Theme.colors.product.priceSale         // #C45A5A (error red)
Theme.colors.product.badgeNew          // #E8B5A3 (light terracotta)
Theme.colors.product.badgeSale         // #E8A8A8 (light red)
Theme.colors.product.badgeBestSeller   // #A8D4B8 (light green)

// Action colors (CTA buttons)
Theme.colors.action.primary            // #C4785A (warm terracotta)
Theme.colors.action.secondary          // #2D4A3E (deep forest)
Theme.colors.action.destructive        // #C45A5A (error red)

// Helper functions
Palette.action.base("success")         // Returns success color
Palette.action.light("warning")        // Returns warning light variant
```

## CMake Module Pattern

Each module follows this pattern in its `CMakeLists.txt`:

```cmake
qt_add_qml_module(MerceControls
    URI "Merce.Controls"
    VERSION 1.0
    QML_FILES
        MButton.qml
        MInput.qml
)

target_link_libraries(MerceControls PRIVATE MerceFoundation MerceCore)
```

- URI must match the module's namespace
- Link only to direct dependencies (not transitive ones)
- Use `PRIVATE` linking for QML modules

## Component Design Guidelines

### Touch Optimization
- Minimum touch target: **44px** (enforced via `final` properties)
- Designed for kiosk/tablet interaction

### Naming Convention
- All components prefixed with `M`: `MButton`, `MInput`, `MSurface`, `MText`
- Module URIs use dot notation: `Merce.Controls`, `Merce.Foundation`

### Component Inheritance Pattern

```qml
// Base component (Foundation)
import QtQuick

Item {
    virtual property color accentColor: "blue"
    final property int touchTarget: 44
}
```

```qml
// Derived component (Controls)
import QtQuick
import Merce.Foundation

MBaseControl {
    override property color accentColor: Theme.colors.action.primary
}
```

## Design Document Reference

The complete technical specification is in `Merce_Design_Spec.md` (in Turkish). Key sections:
- Architecture overview with dependency diagrams
- Property semantics usage patterns
- Theme singleton structure
- CMake integration examples
- Component development guidelines

## Component Catalog

### Merce.Foundation
| Component | Purpose |
|-----------|---------|
| `MSurface` | Base surface with customizable background, border, radius |
| `MText` | Typography component with preset styles (display, h1-h4, body, caption, overline, price) |
| `MBaseControl` | Base class for interactive controls with hover/press/focus states |

### Merce.Controls
| Component | Purpose |
|-----------|---------|
| `MButton` | Button with variants (primary, secondary, outline, ghost, destructive), sizes, loading state |
| `MInput` | Text input with validation states, icons, character count, password toggle |

### Merce.Notifications
| Component | Purpose |
|-----------|---------|
| `MToast` | Auto-dismissing toast with variants (success, warning, error, info), actions |
| `MDialog` | Modal dialog with overlay, customizable size (small, medium, large) |

## Build Commands

```bash
# Configure build
cmake -B build -S Merce -DBUILD_MERCE_EXAMPLES=ON

# Build all modules
cmake --build build

# Install (to /usr/local by default)
cmake --install build
```

## Development Notes

- **Color Palette**: Warm terracotta (#C4785A) as primary - creates urgency and warmth for shopping
- **Typography**: Editorial aesthetic - Playfair Display (headings) + DM Sans (body)
- **Touch Targets**: Minimum 44px enforced via `final` properties
- **Property Semantics**: Use `virtual` for overridable, `final` for system standards, `override` when overriding
