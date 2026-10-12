# Device table pattern

Open **Patterns → Devices** in the playground. The six devices are sample data;
the details action does not contact hardware.

`TableShowcase.qml` composes Qt `TableView` and `TableModel` with Merce labels,
badges, buttons and StyleKit checkboxes. Search matches device names and IDs;
the Device heading toggles name sorting. Selection uses stable device IDs,
including when a selected device is hidden by search. The header checkbox only
changes visible rows. Clear selection also clears hidden rows.

Normal rows are transparent. Use `Theme.colors.outline.subtle` for separators
and the primary action color with `Theme.state.layer.selected` for selection.
Status badges carry both words and icons. Control height and spacing follow
the active profile. The horizontal scrollbar is visible only when the table
is wider than its viewport.

The in-memory filtering and full table height suit this small playground
fixture. A production device fleet should supply a C++ model/proxy and a bounded
TableView viewport so that large datasets retain delegate virtualization.

Verify through `--playground-probe`; export through `--export-playground-pages`.
The page is included in both desktop and compact exports.
