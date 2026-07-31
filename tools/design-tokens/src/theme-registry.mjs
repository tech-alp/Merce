import { readFile } from 'node:fs/promises';
import path from 'node:path';

export async function loadThemeRegistry(registryPath = new URL('../themes.json', import.meta.url)) {
  const registry = JSON.parse(await readFile(registryPath, 'utf8'));

  if (registry.schemaVersion !== 1) {
    throw new Error('themes.json schemaVersion must be 1');
  }
  requireRegisteredDefault(registry, 'defaultBrand', 'brands');
  requireRegisteredDefault(registry, 'defaultProfile', 'profiles');

  return registry;
}

export function themeEntries(registry) {
  return Object.entries(registry.brands).flatMap(([brandId, brand]) => {
    if (!brand || typeof brand !== 'object' || Array.isArray(brand)) {
      throw new Error(`Brand '${brandId}' must be an object`);
    }
    if (!brand.modes || typeof brand.modes !== 'object' || Array.isArray(brand.modes)
        || Object.keys(brand.modes).length === 0) {
      throw new Error(`Brand '${brandId}' must declare modes`);
    }
    if (!Object.prototype.hasOwnProperty.call(brand.modes, brand.defaultMode)) {
      throw new Error(`Brand '${brandId}' defaultMode '${brand.defaultMode}' is not registered`);
    }

    return Object.entries(brand.modes).map(([mode, entry]) => normalizeEntry(
      entry,
      `Brand '${brandId}' mode '${mode}'`,
      { brandId, mode },
    ));
  });
}

export function profileEntries(registry) {
  return Object.entries(registry.profiles).map(([profileId, profile]) => normalizeEntry(
    profile,
    `Profile '${profileId}'`,
    { profileId },
  ));
}

export function generatedIndex(registry) {
  return {
    schemaVersion: 1,
    defaultBrand: registry.defaultBrand,
    brands: Object.fromEntries(
      Object.entries(registry.brands)
        .filter(([, brand]) => brand.runtime !== false)
        .map(([brandId, brand]) => [
        brandId,
        {
          displayName: nonEmptyString(brand.displayName, `Brand '${brandId}' displayName`),
          defaultMode: nonEmptyString(brand.defaultMode, `Brand '${brandId}' defaultMode`),
          modes: Object.fromEntries(
            Object.entries(brand.modes).map(([mode, entry]) => [
              mode,
              validateManifestPath(entry.path, `Brand '${brandId}' mode '${mode}' path`),
            ]),
          ),
        },
        ]),
    ),
    defaultProfile: registry.defaultProfile,
    profiles: Object.fromEntries(
      Object.entries(registry.profiles).map(([profileId, profile]) => [
        profileId,
        {
          displayName: nonEmptyString(profile.displayName, `Profile '${profileId}' displayName`),
          path: validateManifestPath(profile.path, `Profile '${profileId}' path`),
        },
      ]),
    ),
  };
}

export function resolveRegistryPath(relativePath, baseDir = process.cwd()) {
  return path.resolve(baseDir, relativePath);
}

export function validateManifestPath(value, label) {
  if (typeof value !== 'string'
      || value.length === 0
      || path.isAbsolute(value)
      || value.startsWith(':')
      || value.includes('/')
      || value.includes('\\')
      || value.includes('..')) {
    throw new Error(`${label} must be a safe manifest filename`);
  }

  return value;
}

function requireRegisteredDefault(registry, defaultField, entriesField) {
  const entries = registry[entriesField];
  if (!entries || typeof entries !== 'object' || Array.isArray(entries)
      || Object.keys(entries).length === 0) {
    throw new Error(`themes.json must declare a non-empty ${entriesField} object`);
  }
  if (typeof registry[defaultField] !== 'string'
      || !Object.prototype.hasOwnProperty.call(entries, registry[defaultField])) {
    throw new Error(`themes.json ${defaultField} must name a registered ${entriesField} entry`);
  }
}

function normalizeEntry(entry, label, identity) {
  if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
    throw new Error(`${label} must be an object`);
  }
  if (!Array.isArray(entry.source) || entry.source.length === 0
      || entry.source.some((source) => typeof source !== 'string' || source.length === 0)) {
    throw new Error(`${label} source must be a non-empty string array`);
  }

  return {
    ...identity,
    displayName: nonEmptyString(entry.displayName, `${label} displayName`),
    path: validateManifestPath(entry.path, `${label} path`),
    source: entry.source,
  };
}

function nonEmptyString(value, label) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${label} must be a non-empty string`);
  }
  return value;
}
