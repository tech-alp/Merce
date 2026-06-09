import { copyFile, mkdir, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import StyleDictionary from 'style-dictionary';
import { formatMerceManifest } from './src/merce-manifest-format.mjs';
import { generatedIndex, loadThemeRegistry, resolveRegistryPath, themeEntries } from './src/theme-registry.mjs';
import { validateManifestFile } from './src/validate-manifest.mjs';

const TOOL_ROOT = process.cwd();
const GENERATED_DIR = path.resolve(TOOL_ROOT, '../../generated/themes');
const FORMAT_NAME = 'merce/manifest-json';

StyleDictionary.registerFormat({
  name: FORMAT_NAME,
  format: ({ dictionary, options }) => `${JSON.stringify(formatMerceManifest(dictionary, options), null, 2)}\n`,
});

if (process.argv.includes('--clean')) {
  await rm(GENERATED_DIR, { recursive: true, force: true });
  process.exit(0);
}

await mkdir(GENERATED_DIR, { recursive: true });

const registry = await loadThemeRegistry();
const index = generatedIndex(registry);
await writeFile(path.join(GENERATED_DIR, 'index.json'), `${JSON.stringify(index, null, 2)}\n`);

const entries = themeEntries(registry);
await copyFontAssets(entries);

for (const entry of entries) {
  const sd = new StyleDictionary({
    source: entry.source.map((sourcePath) => resolveRegistryPath(sourcePath, TOOL_ROOT)),
    platforms: {
      merce: {
        buildPath: `${GENERATED_DIR}/`,
        files: [{
          destination: entry.path,
          format: FORMAT_NAME,
          options: {
            theme: entry.theme,
            variant: entry.variant,
            fonts: entry.fonts,
          },
        }],
      },
    },
    log: {
      warnings: 'warn',
      verbosity: 'default',
      errors: {
        brokenReferences: 'throw',
      },
    },
  });

  await sd.buildAllPlatforms();
  await validateManifestFile(path.join(GENERATED_DIR, entry.path), {
    theme: entry.theme,
    variant: entry.variant,
  });
}

async function copyFontAssets(entries) {
  const copied = new Set();
  for (const entry of entries) {
    for (const font of entry.fonts ?? []) {
      if (copied.has(font.destination))
        continue;

      const sourcePath = resolveRegistryPath(font.source, TOOL_ROOT);
      const destinationPath = path.join(GENERATED_DIR, font.destination);
      await mkdir(path.dirname(destinationPath), { recursive: true });
      await copyFile(sourcePath, destinationPath);
      copied.add(font.destination);
    }
  }
}
