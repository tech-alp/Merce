import { readFile } from 'node:fs/promises';
import path from 'node:path';

export async function loadThemeRegistry(registryPath = new URL('../themes.json', import.meta.url)) {
  const raw = await readFile(registryPath, 'utf8');
  const registry = JSON.parse(raw);

  if (registry.schemaVersion !== 1) {
    throw new Error('themes.json schemaVersion must be 1');
  }

  if (!registry.defaultTheme) {
    throw new Error('themes.json must declare defaultTheme');
  }

  if (!registry.themes || typeof registry.themes !== 'object') {
    throw new Error('themes.json must declare a themes object');
  }

  if (containsKey(registry, 'defaultMode')) {
    throw new Error('themes.json must not use defaultMode; use sparse path or variant registry fields');
  }

  return registry;
}

export function themeEntries(registry) {
  const coreSources = registry.core ?? [
    'tokens/core/palette.json',
    'tokens/core/spacing.json',
    'tokens/core/radius.json',
    'tokens/core/typography.json',
  ];

  return Object.entries(registry.themes).flatMap(([themeName, theme]) => {
    const themeSources = theme.source ?? [];

    if (theme.variants) {
      const entries = [];

      if (theme.basePath) {
        entries.push({
          theme: themeName,
          displayName: theme.displayName ?? themeName,
          path: validateManifestPath(theme.basePath, `Theme '${themeName}' basePath`),
          source: [...coreSources, ...themeSources],
        });
      }

      entries.push(...Object.entries(theme.variants).map(([variantName, destination]) => {
        const variantSources = theme.variantSources?.[variantName] ?? [
          `tokens/themes/${themeName}/variants/${variantName}.json`,
        ];

        return {
          theme: themeName,
          displayName: theme.displayName ?? themeName,
          variant: variantName,
          path: validateManifestPath(destination, `Theme '${themeName}' variant '${variantName}' path`),
          source: [...coreSources, ...themeSources, ...variantSources],
        };
      }));

      return entries;
    }

    if (!theme.path) {
      throw new Error(`Theme '${themeName}' must declare path or variants`);
    }

    return [{
      theme: themeName,
      displayName: theme.displayName ?? themeName,
      path: validateManifestPath(theme.path, `Theme '${themeName}' path`),
      source: [...coreSources, ...themeSources],
    }];
  });
}

export function generatedIndex(registry) {
  const themes = Object.fromEntries(
    Object.entries(registry.themes).map(([themeName, theme]) => {
      if (theme.variants) {
        return [themeName, {
          displayName: theme.displayName ?? themeName,
          ...(theme.basePath ? { basePath: validateManifestPath(theme.basePath, `Theme '${themeName}' basePath`) } : {}),
          defaultVariant: theme.defaultVariant,
          variants: Object.fromEntries(
            Object.entries(theme.variants).map(([variantName, destination]) => [
              variantName,
              validateManifestPath(destination, `Theme '${themeName}' variant '${variantName}' path`),
            ]),
          ),
        }];
      }

      return [themeName, {
        displayName: theme.displayName ?? themeName,
        path: validateManifestPath(theme.path, `Theme '${themeName}' path`),
      }];
    }),
  );

  return {
    schemaVersion: registry.schemaVersion,
    defaultTheme: registry.defaultTheme,
    themes,
  };
}

export function resolveRegistryPath(relativePath, baseDir = process.cwd()) {
  return path.resolve(baseDir, relativePath);
}

function containsKey(value, key) {
  if (!value || typeof value !== 'object') {
    return false;
  }

  if (Object.prototype.hasOwnProperty.call(value, key)) {
    return true;
  }

  return Object.values(value).some((child) => containsKey(child, key));
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
