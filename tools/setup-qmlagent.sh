#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_dir="$repo_root/external/qmlagent"
build_dir=${QMLAGENT_BUILD_DIR:-"$repo_root/build/qmlagent"}
tool_dir="$build_dir/tools/qmlagent"
plugin_dir="$build_dir/plugins"

if [ ! -f "$source_dir/CMakeLists.txt" ]; then
    echo "QMLAgent submodule is missing. Run: git submodule update --init external/qmlagent" >&2
    exit 1
fi

if [ -n "${QT_CMAKE:-}" ]; then
    qt_cmake=$QT_CMAKE
elif command -v qt-cmake >/dev/null 2>&1; then
    qt_cmake=$(command -v qt-cmake)
else
    echo "qt-cmake not found. Set QT_CMAKE=/path/to/Qt/6.11.x/<platform>/bin/qt-cmake" >&2
    exit 1
fi

"$qt_cmake" -S "$source_dir" -B "$build_dir"
cmake --build "$build_dir" --parallel

echo "QMLAgent built in $build_dir"
echo "Launch with: QT_PLUGIN_PATH=$plugin_dir $tool_dir/qmlagent-launcher app <executable>"
echo "Codex MCP: codex mcp add qmlagent -- $tool_dir/qmlagent-mcp --timeout 5000"
echo "Claude MCP: claude mcp add qmlagent -s local -- $tool_dir/qmlagent-mcp --timeout 5000"
