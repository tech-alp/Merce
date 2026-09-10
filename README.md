# Merce

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/tech-alp/Merce/actions/workflows/ci.yml/badge.svg)](https://github.com/tech-alp/Merce/actions/workflows/ci.yml)
[![Live Demo](https://img.shields.io/badge/live_demo-WebAssembly-654FF0?logo=webassembly)](https://tech-alp.github.io/Merce/wasm/)
[![Release](https://img.shields.io/github/v/release/tech-alp/Merce)](https://github.com/tech-alp/Merce/releases)

Merce is a Qt 6.11+ design-system runtime for QML applications. It provides
semantic design tokens, runtime brand/mode/profile switching, a centralized
Qt.labs.StyleKit mapping, and reusable QML primitives.

> [!IMPORTANT]
> Merce depends on Qt.labs.StyleKit, which is a Technology Preview in Qt 6.11.
> Its API and behavior may change between Qt releases. See the
> [Qt StyleKit documentation](https://doc.qt.io/qt-6/qtlabsstylekit-index.html).

## Live Demo

Run the complete Merce playground in a browser through the
[WebAssembly demo](https://tech-alp.github.io/Merce/wasm/). The demo is built
from the real `MercePlayground` target and deployed from `main` after its WASM
build succeeds.

## Features

- Semantic color, typography, spacing, radius, size, motion, icon, shadow,
  breakpoint, and z-index tokens
- Runtime theme and profile switching through the Theme singleton
- Centralized styling for Qt.labs.StyleKit controls
- Built-in Material Symbols support
- Reusable controls including MButton, MBadge, and LoadingIndicator
- Optional Font Awesome module
- Optional source-integrated notification and dialog layer backed by
  [QtToastify](https://github.com/tech-alp/QtToastify)
- Optional design-token generation pipeline

## Requirements

- CMake 3.30 or newer
- Qt 6.11 or newer with Core, Gui, Qml, Quick, QuickControls2, LabsStyleKit,
  and QuickEffects
- A C++20-capable compiler

Notifications additionally require Qt Quick Vector Image and Vector Image
Helpers. Node.js 22+ and npm are required only for design-token generation.

## Modules

| QML import | Purpose |
|---|---|
| Merce.Core | Build information and common infrastructure |
| Merce.Platform | Runtime platform capabilities |
| Merce.Theme | Semantic tokens and runtime theme/profile selection |
| Merce.Foundation | Surfaces, labels, Material icons, and font helpers |
| Merce.Style | Maps Merce tokens to Qt.labs.StyleKit |
| Merce.Effects | Token-aware effects such as MShadow |
| Merce.Controls | MButton, MBadge, and LoadingIndicator |
| Merce.Icons.FontAwesome | Optional Font Awesome QML module |
| Merce.Notifications | Optional toast, dialog, and notification orchestration |

## Consume with FetchContent

Merce exposes matching namespaced CMake targets for its installable modules in
source builds and installed packages. Merce.Notifications remains source-only:

~~~cmake
include(FetchContent)

block(SCOPE_FOR VARIABLES)
    set(MERCE_BUILD_NOTIFICATIONS OFF)
    set(MERCE_ENABLE_FONTAWESOME OFF)

    FetchContent_Declare(Merce
        GIT_REPOSITORY https://github.com/tech-alp/Merce.git
        GIT_TAG v1.1.0
        GIT_SHALLOW TRUE
        EXCLUDE_FROM_ALL
    )
    FetchContent_MakeAvailable(Merce)
endblock()

target_link_libraries(MyApp PRIVATE
    Merce::Theme
    Merce::Foundation
    Merce::Style
    Merce::Controls
)
~~~

Disabling MERCE_BUILD_NOTIFICATIONS prevents QtToastify from being fetched.

## QML usage

Install MerceStyle on the root StyleKit application window, then use StyleKit
controls or Merce primitives:

~~~qml
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK

import Merce.Controls
import Merce.Style
import Merce.Theme

SK.ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: qsTr("Merce Example")

    SK.StyleKit.style: MerceStyle {}

    Component.onCompleted: {
        Theme.setContext("merce", "light", "cart")
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.md

        MButton {
            text: qsTr("Save")
            variant: MButton.Primary
            size: MButton.Medium
            iconName: "material:save"
            iconPosition: MButton.IconLeft
            onClicked: console.log("Save")
        }

        MButton {
            text: qsTr("Delete")
            variant: MButton.Destructive
        }
    }
}
~~~

Themes can be switched at runtime:

~~~qml
Theme.setTheme("merce", "dark")
Theme.setContext("merce", "light", "ops")
~~~

## Build

The default build keeps optional applications and QtToastify disabled:

~~~sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
~~~

If Qt is not found automatically, provide its kit through CMAKE_PREFIX_PATH.

A complete developer build is explicit:

~~~sh
cmake -S . -B build-full -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMERCE_BUILD_NOTIFICATIONS=ON \
  -DMERCE_ENABLE_FONTAWESOME=ON \
  -DBUILD_MERCE_PLAYGROUND=ON

cmake --build build-full --parallel
ctest --test-dir build-full --output-on-failure
~~~

Build the WebAssembly site with a matching Qt host kit, Qt for WebAssembly, and
Emscripten environment:

~~~sh
QT_HOST_PATH=/path/to/Qt/6.11.1/host \
QT_WASM_PATH=/path/to/Qt/6.11.1/wasm_singlethread \
EMSDK_ROOT=/path/to/emsdk \
./scripts/build_wasm.sh
~~~

## Install

The v1.1 installed package contains the core design-system modules and optional
Font Awesome module. Merce.Notifications is source-integration only because
QtToastify currently ships as static QML modules.

~~~sh
cmake -S . -B build-install -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/path/to/merce \
  -DMERCE_BUILD_NOTIFICATIONS=OFF \
  -DMERCE_BUILD_TESTS=OFF \
  -DBUILD_MERCE_PLAYGROUND=OFF

cmake --build build-install --parallel
cmake --install build-install
~~~

Add the installation prefix to the consuming project's CMAKE_PREFIX_PATH:

~~~cmake
find_package(Merce 1.0 CONFIG REQUIRED)

target_link_libraries(MyApp PRIVATE
    Merce::Theme
    Merce::Foundation
    Merce::Style
    Merce::Controls
)
~~~

## Build options

| Option | Default | Description |
|---|---:|---|
| MERCE_BUILD_NOTIFICATIONS | OFF | Builds Merce.Notifications and fetches the pinned QtToastify release |
| MERCE_QTTOASTIFY_GIT_TAG | v2.0.0 | QtToastify release tag used by the notifications module |
| MERCE_ENABLE_FONTAWESOME | ON | Builds Merce.Icons.FontAwesome |
| MERCE_BUILD_TESTS | Top-level only | Builds the test suite |
| BUILD_MERCE_PLAYGROUND | OFF | Builds the playground; requires notifications and Font Awesome |
| MERCE_ENABLE_TOKEN_BUILD | OFF | Adds the npm-backed merce_tokens target |

## Design-token generation

~~~sh
npm --prefix tools/design-tokens ci
npm --prefix tools/design-tokens run build
npm --prefix tools/design-tokens run validate
npm --prefix tools/design-tokens run check
~~~

Generated manifests and font resources under generated/ are committed. The
check command fails when they are stale.

## Brands and typefaces

The generated index the applications read carries only product brands: `merce`,
`algit`, and the tenant brands `migros` and `happy-center`. A brand marked
`runtime: false` in `tools/design-tokens/themes.json` is still generated, but it
is listed in `reference-index.json` instead and only the playground loads it.
An application cannot resolve one, which is the point: a cart should not be
configurable onto Apple's palette.

### Adding a brand

A brand is a seed colour, not a hand-written palette. `BrandDerivation` produces
all 42 colour roles and the state layers from one seed, for light and dark, and
rejects a seed it cannot correct into contrast rather than shipping a theme that
fails it. Author the token source under
`tools/design-tokens/tokens/themes/<brand>/variants/<mode>.json`, register the
brand in `themes.json`, and regenerate.

Two things bite when authoring by hand. Colours in a token source are
`#RRGGBBAA`, while a resolved manifest under `generated/` is Qt's `#AARRGGBB`:
copying a resolved value back into a source rotates it a second time, and a
scrim silently becomes transparent. And the family names in `typography` must
match the `name` table inside the font file, because the loader resolves
families through the font database rather than through anything written here.

### Shipping a typeface

Every brand inherits `tokens/core/fonts`, currently Lexend and JetBrains Mono.
A brand that needs its own faces puts them in
`tools/design-tokens/tokens/themes/<brand>/fonts/` with their licence text, and
overrides the families in a layer listed after `tokens/core/font-families.json`
in that brand's `source` array:

~~~json
{
  "typography": {
    "displayFont": { "$type": "fontFamily", "$value": "Source Serif 4" },
    "bodyFont":    { "$type": "fontFamily", "$value": "Inter" }
  }
}
~~~

The build copies the files out and lists them in the brand's manifest, so the
runtime registers exactly the faces that brand asks for. Keep them under the
brand rather than in `tokens/core/fonts`: core is copied into every brand, so a
typeface placed there is carried by every application that ships any brand.

Variable fonts are worth preferring. A static Regular against a profile that
asks for 500, 600 and 700 does not fail; Qt synthesises the missing weights, and
the result is a heading that looks subtly wrong with nothing reporting an error.

## Reference themes and trademarks

Some bundled themes are unofficial reference fixtures derived from publicly
available design-system material. Third-party names and marks belong to their
respective owners. Their use does not imply affiliation, sponsorship, or
endorsement.

## License

Merce is available under the [MIT License](LICENSE). Bundled third-party
components retain the license files shipped next to them.
