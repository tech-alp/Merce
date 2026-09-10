import { copyFile, mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import {
  formatProfile,
  formatResolvedTheme,
} from './src/merce-manifest-format.mjs';
import {
  generatedIndex,
  isRuntimeBrand,
  loadThemeRegistry,
  profileEntries,
  resolveRegistryPath,
  themeEntries,
} from './src/theme-registry.mjs';
import {
  validateProfileFile,
  validateResolvedThemeFile,
} from './src/validate-manifest.mjs';

const TOOL_ROOT = process.cwd();
const GENERATED_THEME_DIR = path.resolve(TOOL_ROOT, '../../generated/themes');
const GENERATED_PROFILE_DIR = path.resolve(TOOL_ROOT, '../../generated/profiles');

if (process.argv.includes('--clean')) {
  await Promise.all([
    rm(GENERATED_THEME_DIR, { recursive: true, force: true }),
    rm(GENERATED_PROFILE_DIR, { recursive: true, force: true }),
  ]);
  process.exit(0);
}

await Promise.all([
  mkdir(GENERATED_THEME_DIR, { recursive: true }),
  mkdir(GENERATED_PROFILE_DIR, { recursive: true }),
]);

const registry = await loadThemeRegistry();
await writeFile(
  path.join(GENERATED_THEME_DIR, 'index.json'),
  `${JSON.stringify(generatedIndex(registry), null, 2)}\n`,
);

// The playground loads this through --theme-source, so reference palettes stay
// demonstrable without an application being able to resolve one.
const referenceBrands = Object.entries(registry.brands).filter((e) => !isRuntimeBrand(e));
if (referenceBrands.length > 0) {
  await writeFile(
    path.join(GENERATED_THEME_DIR, 'reference-index.json'),
    `${JSON.stringify(generatedIndex(registry, (e) => !isRuntimeBrand(e), false), null, 2)}\n`,
  );
}

for (const entry of themeEntries(registry)) {
  await writeDocument({
    entry,
    outputDir: GENERATED_THEME_DIR,
    formatter: formatResolvedTheme,
    options: {
      brandId: entry.brandId,
      mode: entry.mode,
      fonts: await copyBrandFonts(entry.brandId),
    },
  });
  await validateResolvedThemeFile(path.join(GENERATED_THEME_DIR, entry.path), entry);
}

for (const entry of profileEntries(registry)) {
  await writeDocument({
    entry,
    outputDir: GENERATED_PROFILE_DIR,
    formatter: formatProfile,
    options: {
      profileId: entry.profileId,
    },
  });
  await validateProfileFile(path.join(GENERATED_PROFILE_DIR, entry.path), entry);
}

// A brand ships its typeface next to its tokens. Everything in the brand's
// fonts/ directory is copied out and listed in the resolved manifest, so the
// runtime can register the files the theme actually asks for instead of
// carrying one hardcoded family for every brand.
//
// The family name is deliberately not declared here: it lives inside the font
// file, and the loader reads it back from the font database. A hand-written
// name would only be a second source of truth to drift from.
async function copyBrandFonts(brandId) {
  // Core first: the families every brand declares live once, not once per
  // brand. A brand's own directory adds to that rather than replacing it.
  return [
    ...await copyFontDir(path.resolve(TOOL_ROOT, 'tokens/core/fonts'), 'core'),
    ...await copyFontDir(path.resolve(TOOL_ROOT, 'tokens/themes', brandId, 'fonts'), brandId),
  ];
}

async function copyFontDir(sourceDir, outputName) {
  const outputDir = path.join(GENERATED_THEME_DIR, 'fonts', outputName);
  await rm(outputDir, { recursive: true, force: true });

  let names;
  try {
    names = await readdir(sourceDir);
  } catch (error) {
    if (error.code === 'ENOENT') {
      return [];
    }
    throw error;
  }

  const fontNames = names.filter((name) => /\.(ttf|otf)$/i.test(name)).sort();
  if (fontNames.length === 0) {
    return [];
  }

  await mkdir(outputDir, { recursive: true });
  for (const name of fontNames) {
    await copyFile(path.join(sourceDir, name), path.join(outputDir, name));
  }

  return fontNames.map((name) => `fonts/${outputName}/${name}`);
}

async function writeDocument({
  entry,
  outputDir,
  formatter,
  options,
}) {
  const sources = await Promise.all(entry.source.map(async (sourcePath) => (
    JSON.parse(await readFile(resolveRegistryPath(sourcePath, TOOL_ROOT), 'utf8'))
  )));
  const dictionary = resolveDictionary(sources.reduce(deepMerge, {}));
  const document = formatter(dictionary, options);
  await writeFile(path.join(outputDir, entry.path), `${JSON.stringify(document, null, 2)}\n`);
}

function deepMerge(base, overlay) {
  const merged = structuredClone(base);
  for (const [key, value] of Object.entries(overlay)) {
    if (isObject(value) && isObject(merged[key])) {
      merged[key] = deepMerge(merged[key], value);
    } else {
      merged[key] = structuredClone(value);
    }
  }
  return merged;
}

function resolveDictionary(tokens) {
  const raw = new Map();
  collectTokens(tokens, [], raw);

  const resolved = new Map();
  const resolving = new Set();
  const resolveToken = (name) => {
    if (resolved.has(name)) {
      return resolved.get(name);
    }
    if (!raw.has(name)) {
      throw new Error(`Unresolved token reference '{${name}}'`);
    }
    if (resolving.has(name)) {
      throw new Error(`Circular token reference '{${name}}'`);
    }

    resolving.add(name);
    const value = resolveReferences(raw.get(name), resolveToken);
    resolving.delete(name);
    resolved.set(name, value);
    return value;
  };

  return {
    allTokens: [...raw.keys()].map((name) => ({
      path: name.split('.'),
      $value: resolveToken(name),
    })),
    tokens,
  };
}

function collectTokens(value, pathSegments, target) {
  if (!isObject(value)) {
    return;
  }
  if (Object.prototype.hasOwnProperty.call(value, '$value')
      || Object.prototype.hasOwnProperty.call(value, 'value')) {
    target.set(pathSegments.join('.'), value.$value ?? value.value);
    return;
  }
  for (const [key, child] of Object.entries(value)) {
    collectTokens(child, [...pathSegments, key], target);
  }
}

function resolveReferences(value, resolveToken) {
  if (typeof value === 'string') {
    const match = value.match(/^\{([^{}]+)\}$/);
    return match ? resolveToken(match[1]) : value;
  }
  if (Array.isArray(value)) {
    return value.map((child) => resolveReferences(child, resolveToken));
  }
  if (isObject(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, child]) => [key, resolveReferences(child, resolveToken)]),
    );
  }
  return value;
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}
