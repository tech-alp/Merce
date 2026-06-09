import { access, readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { COLOR_FIELD_MAP, FIELD_MAP } from './merce-manifest-format.mjs';
import { validateManifestPath } from './theme-registry.mjs';

const REQUIRED_TOP_LEVEL = [
  'schemaVersion',
  'theme',
  'colors',
  'spacing',
  'radius',
  'typography',
];

const TYPOGRAPHY_STRING_FIELDS = new Set([
  'displayFont',
  'bodyFont',
  'monoFont',
  'displayFontFallback',
  'bodyFontFallback',
]);

const GENERIC_FONT_FAMILIES = new Set([
  '-apple-system',
  'blinkmacsystemfont',
  'serif',
  'sans-serif',
  'sans serif',
  'monospace',
  'ui-monospace',
  'system-ui',
]);

const REQUIRED_FIELDS = Object.entries(FIELD_MAP).flatMap(([section, fields]) => (
  fields.map(([field]) => `${section}.${field}`)
));

const REQUIRED_COLOR_FIELDS = Object.entries(COLOR_FIELD_MAP).flatMap(([group, fields]) => (
  fields.map(([field]) => `colors.${group}.${field}`)
));

export function validateManifest(manifest, context = {}) {
  const errors = [];

  for (const field of REQUIRED_TOP_LEVEL) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required field: ${field}`);
    }
  }

  if (manifest.schemaVersion !== 1) {
    errors.push('schemaVersion must be 1');
  }

  if (context.theme && manifest.theme !== context.theme) {
    errors.push(`theme must be '${context.theme}'`);
  }

  if (context.variant && manifest.variant !== context.variant) {
    errors.push(`variant must be '${context.variant}'`);
  }

  if (!context.variant && Object.prototype.hasOwnProperty.call(context, 'variant') && 'variant' in manifest) {
    errors.push('single-manifest themes must not include variant');
  }

  if ('palette' in manifest) {
    errors.push('manifest must not contain a top-level palette section');
  }

  if (manifest.colors && typeof manifest.colors === 'object' && !Array.isArray(manifest.colors)
      && 'raw' in manifest.colors) {
    errors.push('runtime colors must not expose raw color scales');
  }

  for (const field of REQUIRED_COLOR_FIELDS) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required runtime field: ${field}`);
      continue;
    }

    validateRuntimeField(manifest, field, errors);
  }

  for (const field of REQUIRED_FIELDS) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required runtime field: ${field}`);
      continue;
    }

    validateRuntimeField(manifest, field, errors);
  }

  if (containsRawDtcg(manifest)) {
    errors.push('manifest must not contain raw DTCG keys or unresolved token references');
  }

  validateFonts(manifest, errors);

  return {
    ok: errors.length === 0,
    errors,
  };
}

export async function validateManifestFile(filePath, context = {}) {
  const manifest = JSON.parse(await readFile(filePath, 'utf8'));
  const result = validateManifest(manifest, { ...context, manifestPath: filePath });

  if (!result.ok) {
    throw new Error(`${filePath}\n- ${result.errors.join('\n- ')}`);
  }

  if (Array.isArray(manifest.fonts)) {
    await validateFontFiles(manifest.fonts, filePath);
  }

  return result;
}

async function validateDirectory(directoryPath) {
  const indexPath = path.join(directoryPath, 'index.json');
  const index = JSON.parse(await readFile(indexPath, 'utf8'));
  const indexErrors = validateIndex(index);
  if (indexErrors.length > 0) {
    throw new Error(`${indexPath}\n- ${indexErrors.join('\n- ')}`);
  }

  const validations = [];

  for (const [theme, entry] of Object.entries(index.themes ?? {})) {
    if (entry.basePath) {
      validations.push(validateManifestFile(path.join(directoryPath, entry.basePath), { theme, variant: undefined }));
    }

    if (entry.variants) {
      for (const [variant, manifestPath] of Object.entries(entry.variants)) {
        validations.push(validateManifestFile(path.join(directoryPath, manifestPath), { theme, variant }));
      }
    } else if (entry.path) {
      validations.push(validateManifestFile(path.join(directoryPath, entry.path), { theme, variant: undefined }));
    }
  }

  await Promise.all(validations);

  const files = await readdir(directoryPath);
  if (!files.includes('index.json')) {
    throw new Error(`${directoryPath} must include index.json`);
  }
}

function validateIndex(index) {
  const errors = [];

  if (index.schemaVersion !== 1) {
    errors.push('theme index schemaVersion must be 1');
  }

  if (typeof index.defaultTheme !== 'string' || index.defaultTheme.length === 0) {
    errors.push('theme index must declare a non-empty defaultTheme');
  }

  if (!index.themes || typeof index.themes !== 'object' || Array.isArray(index.themes)
      || Object.keys(index.themes).length === 0) {
    errors.push('theme index must declare a non-empty themes object');
    return errors;
  }

  let defaultThemeRegistered = false;

  for (const [themeName, theme] of Object.entries(index.themes)) {
    if (!themeName) {
      errors.push('theme index contains an empty theme name');
      continue;
    }

    if (!theme || typeof theme !== 'object' || Array.isArray(theme)) {
      errors.push(`theme '${themeName}' must be an object`);
      continue;
    }

    if (themeName === index.defaultTheme) {
      defaultThemeRegistered = true;
    }

    if (typeof theme.displayName !== 'string' || theme.displayName.length === 0) {
      errors.push(`theme '${themeName}' must declare a non-empty displayName`);
    }

    if ('basePath' in theme) {
      validateIndexManifestPath(theme.basePath, `theme '${themeName}' basePath`, errors);
    }

    const hasPath = Object.prototype.hasOwnProperty.call(theme, 'path');
    const hasVariants = Object.prototype.hasOwnProperty.call(theme, 'variants');
    if (hasPath && hasVariants) {
      errors.push(`theme '${themeName}' must not declare both path and variants`);
    }

    if (hasVariants) {
      if (!theme.variants || typeof theme.variants !== 'object' || Array.isArray(theme.variants)
          || Object.keys(theme.variants).length === 0) {
        errors.push(`theme '${themeName}' variants must be a non-empty object`);
        continue;
      }

      if (typeof theme.defaultVariant !== 'string' || theme.defaultVariant.length === 0) {
        errors.push(`theme '${themeName}' must declare a non-empty defaultVariant`);
      } else if (!Object.prototype.hasOwnProperty.call(theme.variants, theme.defaultVariant)) {
        errors.push(`theme '${themeName}' defaultVariant '${theme.defaultVariant}' is not registered`);
      }

      for (const [variantName, manifestPath] of Object.entries(theme.variants)) {
        if (!variantName) {
          errors.push(`theme '${themeName}' contains an empty variant name`);
          continue;
        }
        validateIndexManifestPath(manifestPath, `theme '${themeName}' variant '${variantName}' path`, errors);
      }
      continue;
    }

    if (!hasPath) {
      errors.push(`theme '${themeName}' must declare path or variants`);
      continue;
    }

    validateIndexManifestPath(theme.path, `theme '${themeName}' path`, errors);
  }

  if (index.defaultTheme && !defaultThemeRegistered) {
    errors.push(`defaultTheme '${index.defaultTheme}' is not registered`);
  }

  return errors;
}

function validateIndexManifestPath(value, label, errors) {
  try {
    validateManifestPath(value, label);
  } catch (error) {
    errors.push(error.message);
  }
}

function validateFonts(manifest, errors) {
  if (!Object.prototype.hasOwnProperty.call(manifest, 'fonts')) {
    return;
  }

  if (!Array.isArray(manifest.fonts)) {
    errors.push('runtime field fonts must be an array');
    return;
  }

  manifest.fonts.forEach((font, index) => {
    const prefix = `runtime field fonts[${index}]`;
    if (!font || typeof font !== 'object' || Array.isArray(font)) {
      errors.push(`${prefix} must be an object`);
      return;
    }

    if (typeof font.family !== 'string' || font.family.trim().length === 0) {
      errors.push(`${prefix}.family must be a non-empty string`);
    }
    if (typeof font.source !== 'string' || !isSafeRelativeAssetPath(font.source)) {
      errors.push(`${prefix}.source must be a safe relative .ttf or .otf path`);
    }
    if (typeof font.weight !== 'number' || !Number.isFinite(font.weight)) {
      errors.push(`${prefix}.weight must be numeric`);
    }
    if ('style' in font && (typeof font.style !== 'string' || font.style.trim().length === 0)) {
      errors.push(`${prefix}.style must be a non-empty string`);
    }
    if ('required' in font && typeof font.required !== 'boolean') {
      errors.push(`${prefix}.required must be boolean`);
    }
  });
}

async function validateFontFiles(fonts, manifestPath) {
  const manifestDir = path.dirname(manifestPath);
  await Promise.all(fonts.map(async (font, index) => {
    if (!font || typeof font.source !== 'string' || !isSafeRelativeAssetPath(font.source)) {
      return;
    }

    try {
      await access(path.join(manifestDir, font.source));
    } catch {
      throw new Error(`${manifestPath}\n- runtime field fonts[${index}].source file does not exist: ${font.source}`);
    }
  }));
}

function isSafeRelativeAssetPath(value) {
  const lower = value.toLowerCase();
  return value.length > 0
    && !path.isAbsolute(value)
    && !value.startsWith(':')
    && !value.includes('\\')
    && (lower.endsWith('.ttf') || lower.endsWith('.otf'))
    && value.split('/').every((part) => part.length > 0 && part !== '..');
}

function hasPath(object, dottedPath) {
  let current = object;

  for (const part of dottedPath.split('.')) {
    if (!current || !Object.prototype.hasOwnProperty.call(current, part)) {
      return false;
    }
    current = current[part];
  }

  return true;
}

function valueAtPath(object, dottedPath) {
  let current = object;

  for (const part of dottedPath.split('.')) {
    current = current[part];
  }

  return current;
}

function validateRuntimeField(manifest, dottedPath, errors) {
  const [section, field] = dottedPath.split('.');
  const value = valueAtPath(manifest, dottedPath);

  if (section === 'colors') {
    if (typeof value !== 'string' || !/^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(value)) {
      errors.push(`runtime field ${dottedPath} must be a valid color string`);
    }
    return;
  }

  if (section === 'typography' && TYPOGRAPHY_STRING_FIELDS.has(field)) {
    if (typeof value !== 'string'
        || value.trim().length === 0
        || isUnresolvedTokenReference(value)) {
      errors.push(`runtime field ${dottedPath} must be a resolved non-empty string`);
    } else if (!isSingleQtFontFamily(value)) {
      errors.push(`runtime field ${dottedPath} must be a single Qt font family name`);
    }
    return;
  }

  if (typeof value !== 'number' || !Number.isFinite(value)) {
    errors.push(`runtime field ${dottedPath} must be numeric`);
  }
}

function isUnresolvedTokenReference(value) {
  const trimmed = value.trim();
  return trimmed.startsWith('{') && trimmed.endsWith('}');
}

function isSingleQtFontFamily(value) {
  const trimmed = value.trim();
  if (trimmed.includes(',') || /^['"]|['"]$/.test(trimmed)) {
    return false;
  }

  return !GENERIC_FONT_FAMILIES.has(trimmed.toLowerCase());
}

function containsRawDtcg(value) {
  if (Array.isArray(value)) {
    return value.some(containsRawDtcg);
  }

  if (!value || typeof value !== 'object') {
    return typeof value === 'string' && /^\{.+\}$/.test(value);
  }

  return Object.entries(value).some(([key, child]) => key.startsWith('$') || containsRawDtcg(child));
}

async function main() {
  const target = process.argv[2];
  if (!target) {
    throw new Error('Usage: validate-manifest.mjs <manifest-file-or-generated-directory>');
  }

  const resolved = path.resolve(process.cwd(), target);
  if (path.extname(resolved) === '.json') {
    await validateManifestFile(resolved);
  } else {
    await validateDirectory(resolved);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}
