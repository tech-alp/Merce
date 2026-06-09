#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../../.." && pwd)"

build_dir="${MERCE_BUILD_DIR:-build}"
gallery_dir="${MERCE_GALLERY_DIR:-docs/assets/theme-gallery}"

cd "${repo_root}"

if [[ ! -d "${build_dir}" ]]; then
    echo "Missing build directory: ${build_dir}" >&2
    echo "Set MERCE_BUILD_DIR to the active CMake build directory." >&2
    exit 2
fi

playground="${build_dir}/playground/MercePlayground"

run() {
    printf '\n==> %s\n' "$*"
    "$@"
}

run cmake --build "${build_dir}" --target MercePlayground
run cmake --build "${build_dir}" --target tst_merce_theme_manifest_loader
run cmake --build "${build_dir}" --target tst_merce_theme_runtime_switch
run ctest --test-dir "${build_dir}" --output-on-failure

if [[ ! -x "${playground}" ]]; then
    echo "Missing playground executable: ${playground}" >&2
    exit 2
fi

run env QT_QPA_PLATFORM=offscreen "${playground}" --theme-probe
run env QT_QPA_PLATFORM=offscreen "${playground}" --theme-switch-probe
run env QT_QPA_PLATFORM=offscreen "${playground}" --smoke-test
run env QT_QPA_PLATFORM=offscreen "${playground}" --theme-gallery-probe
run env QT_QPA_PLATFORM=offscreen "${playground}" --playground-probe
run env QT_QPA_PLATFORM=offscreen "${playground}" --export-theme-gallery "${gallery_dir}"

for image in merce-light merce-dark stripe-reference; do
    path="${gallery_dir}/${image}.png"
    if [[ ! -s "${path}" ]]; then
        echo "Missing or empty gallery artifact: ${path}" >&2
        exit 1
    fi
done

printf '\nMerce playground verification gates passed.\n'
