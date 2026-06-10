# Merce Foundation Fonts

Font assets are grouped by font family, matching the StatusQ asset layout:

- `Inter/*.otf`
- `RobotoMono/*.ttf`
- `MaterialSymbolsRounded/*.ttf`

`Inter` and `RobotoMono` were sourced from StatusQ in
`status-im/status-app`:

- https://github.com/status-im/status-app/tree/master/ui/StatusQ/src/assets/fonts
- https://github.com/status-im/status-app/blob/master/ui/StatusQ/src/assets/fonts/fonts.qrc

The upstream repository license is MPL-2.0:

- https://github.com/status-im/status-app/blob/master/LICENSE.md

Before shipping those assets, verify whether each bundled font has additional
font-specific license or attribution requirements.

`MaterialSymbolsRounded` was sourced from DankMaterialShell's bundled
`material-design-icons` assets:

- https://github.com/AvengeMedia/DankMaterialShell/tree/master/quickshell/assets/fonts/material-design-icons
- https://github.com/AvengeMedia/DankMaterialShell/tree/master/quickshell/assets/fonts/material-design-icons/variablefont

The Material Symbols / Material Icons font assets are documented there as
Apache-2.0 licensed, with the license copied into
`MaterialSymbolsRounded/LICENSE`.
