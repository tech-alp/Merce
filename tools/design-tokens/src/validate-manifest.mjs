import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import {
  COLOR_FIELD_MAP,
  PROFILE_FIELD_MAP,
  STATE_FIELD_MAP,
} from './merce-manifest-format.mjs';
import { validateManifestPath } from './theme-registry.mjs';

const RESOLVED_THEME_FIELDS = new Set([
  'kind',
  'resolvedThemeSchemaVersion',
  'brandId',
  'mode',
  'identity',
  'colors',
  'state',
]);

const PROFILE_FIELDS = new Set([
  'profileSchemaVersion',
  'profileId',
  ...Object.keys(PROFILE_FIELD_MAP),
]);

const TYPOGRAPHY_STRING_FIELDS = new Set([
  'displayFont',
  'bodyFont',
  'monoFont',
  'displayFontFallback',
  'bodyFontFallback',
]);

const COLOR_PATHS = Object.entries(COLOR_FIELD_MAP).flatMap(([group, fields]) => (
  fields.map((field) => `colors.${group}.${field}`)
));

const STATE_PATHS = Object.entries(STATE_FIELD_MAP).flatMap(([group, fields]) => (
  fields.map((field) => `state.${group}.${field}`)
));

const PROFILE_PATHS = Object.entries(PROFILE_FIELD_MAP).flatMap(([section, fields]) => (
  fields.map((field) => `${section}.${field}`)
));

export function validateResolvedTheme(manifest, context = {}) {
  const errors = [];

  requireExactVersion(manifest, 'resolvedThemeSchemaVersion', errors);
  requireString(manifest, 'kind', errors);
  if (manifest.kind !== 'resolved-theme') {
    errors.push("kind must be 'resolved-theme'");
  }
  requireString(manifest, 'brandId', errors);
  requireString(manifest, 'mode', errors);

  if (context.brandId && manifest.brandId !== context.brandId) {
    errors.push(`brandId must be '${context.brandId}'`);
  }
  if (context.mode && manifest.mode !== context.mode) {
    errors.push(`mode must be '${context.mode}'`);
  }

  rejectUnknownFields(manifest, RESOLVED_THEME_FIELDS, 'resolved theme', errors);

  if (!hasPath(manifest, 'identity.mark')) {
    errors.push('missing required field: identity.mark');
  } else {
    validateColor(manifest, 'identity.mark', errors);
  }

  for (const field of COLOR_PATHS) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required runtime field: ${field}`);
    } else {
      validateColor(manifest, field, errors);
    }
  }

  rejectUnknownFields(manifest.state ?? {}, new Set(Object.keys(STATE_FIELD_MAP)), 'state', errors);
  for (const [group, fields] of Object.entries(STATE_FIELD_MAP)) {
    rejectUnknownFields(
      manifest.state?.[group] ?? {},
      new Set(fields),
      `state.${group}`,
      errors,
    );
  }
  for (const field of STATE_PATHS) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required runtime field: ${field}`);
      continue;
    }
    const opacity = valueAtPath(manifest, field);
    if (typeof opacity !== 'number' || !Number.isFinite(opacity)
        || opacity < 0 || opacity > 1) {
      errors.push(`runtime field ${field} must be a finite number from 0 to 1`);
    }
  }

  rejectRawDtcg(manifest, errors);
  return { ok: errors.length === 0, errors };
}

export function validateProfile(profile, context = {}) {
  const errors = [];

  requireExactVersion(profile, 'profileSchemaVersion', errors);
  requireString(profile, 'profileId', errors);
  if (context.profileId && profile.profileId !== context.profileId) {
    errors.push(`profileId must be '${context.profileId}'`);
  }

  rejectUnknownFields(profile, PROFILE_FIELDS, 'profile', errors);

  for (const field of PROFILE_PATHS) {
    if (!hasPath(profile, field)) {
      errors.push(`missing required runtime field: ${field}`);
      continue;
    }

    const value = valueAtPath(profile, field);
    const [section, name] = field.split('.');
    if (section === 'typography' && TYPOGRAPHY_STRING_FIELDS.has(name)) {
      if (typeof value !== 'string' || value.trim().length === 0) {
        errors.push(`runtime field ${field} must be a resolved non-empty string`);
      }
    } else if (typeof value !== 'number' || !Number.isFinite(value)) {
      errors.push(`runtime field ${field} must be numeric`);
    }
  }

  rejectRawDtcg(profile, errors);
  return { ok: errors.length === 0, errors };
}

export async function validateResolvedThemeFile(filePath, context = {}) {
  return validateJsonFile(filePath, (value) => validateResolvedTheme(value, context));
}

export async function validateProfileFile(filePath, context = {}) {
  return validateJsonFile(filePath, (value) => validateProfile(value, context));
}

export async function validateGeneratedDirectory(themeDirectory) {
  const indexPath = path.join(themeDirectory, 'index.json');
  const index = JSON.parse(await readFile(indexPath, 'utf8'));
  const indexErrors = validateIndex(index);
  if (indexErrors.length > 0) {
    throw new Error(`${indexPath}\n- ${indexErrors.join('\n- ')}`);
  }

  const expectedThemeFiles = new Set(['index.json']);
  const validations = [];
  for (const [brandId, brand] of Object.entries(index.brands)) {
    for (const [mode, fileName] of Object.entries(brand.modes)) {
      expectedThemeFiles.add(fileName);
      validations.push(validateResolvedThemeFile(
        path.join(themeDirectory, fileName),
        { brandId, mode },
      ));
    }
  }

  const profileDirectory = path.resolve(themeDirectory, '../profiles');
  const expectedProfileFiles = new Set();
  for (const [profileId, profile] of Object.entries(index.profiles)) {
    expectedProfileFiles.add(profile.path);
    validations.push(validateProfileFile(
      path.join(profileDirectory, profile.path),
      { profileId },
    ));
  }

  await Promise.all(validations);
  await validateFixtureFiles(themeDirectory, expectedThemeFiles);
  await rejectUnexpectedJsonFiles(profileDirectory, expectedProfileFiles, 'profile');
}

function validateIndex(index) {
  const errors = [];
  if (index.schemaVersion !== 1) {
    errors.push('theme index schemaVersion must be exactly 1');
  }

  validateRegistryAxis(index, {
    defaultField: 'defaultBrand',
    entriesField: 'brands',
    entryLabel: 'brand',
    validateEntry: (brandId, brand) => {
      const entryErrors = [];
      requireString(brand, 'displayName', entryErrors, `brand '${brandId}'`);
      requireString(brand, 'defaultMode', entryErrors, `brand '${brandId}'`);
      if (!brand.modes || typeof brand.modes !== 'object' || Array.isArray(brand.modes)
          || Object.keys(brand.modes).length === 0) {
        entryErrors.push(`brand '${brandId}' must declare non-empty modes`);
        return entryErrors;
      }
      if (!Object.prototype.hasOwnProperty.call(brand.modes, brand.defaultMode)) {
        entryErrors.push(`brand '${brandId}' defaultMode '${brand.defaultMode}' is not registered`);
      }
      for (const [mode, fileName] of Object.entries(brand.modes)) {
        if (!mode) {
          entryErrors.push(`brand '${brandId}' contains an empty mode`);
        }
        validateIndexPath(fileName, `brand '${brandId}' mode '${mode}' path`, entryErrors);
      }
      return entryErrors;
    },
  }, errors);

  validateRegistryAxis(index, {
    defaultField: 'defaultProfile',
    entriesField: 'profiles',
    entryLabel: 'profile',
    validateEntry: (profileId, profile) => {
      const entryErrors = [];
      requireString(profile, 'displayName', entryErrors, `profile '${profileId}'`);
      validateIndexPath(profile.path, `profile '${profileId}' path`, entryErrors);
      return entryErrors;
    },
  }, errors);

  return errors;
}

function validateRegistryAxis(index, config, errors) {
  const entries = index[config.entriesField];
  if (!entries || typeof entries !== 'object' || Array.isArray(entries)
      || Object.keys(entries).length === 0) {
    errors.push(`theme index must declare a non-empty ${config.entriesField} object`);
    return;
  }
  if (typeof index[config.defaultField] !== 'string' || index[config.defaultField].length === 0) {
    errors.push(`theme index must declare a non-empty ${config.defaultField}`);
  } else if (!Object.prototype.hasOwnProperty.call(entries, index[config.defaultField])) {
    errors.push(`${config.defaultField} '${index[config.defaultField]}' is not registered`);
  }

  for (const [id, entry] of Object.entries(entries)) {
    if (!id) {
      errors.push(`theme index contains an empty ${config.entryLabel} id`);
      continue;
    }
    if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
      errors.push(`${config.entryLabel} '${id}' must be an object`);
      continue;
    }
    errors.push(...config.validateEntry(id, entry));
  }
}

async function validateJsonFile(filePath, validator) {
  const value = JSON.parse(await readFile(filePath, 'utf8'));
  const result = validator(value);
  if (!result.ok) {
    throw new Error(`${filePath}\n- ${result.errors.join('\n- ')}`);
  }
  return result;
}

async function rejectUnexpectedJsonFiles(directory, expected, label) {
  const actual = (await readdir(directory))
    .filter((name) => name.endsWith('.json'));
  const unexpected = actual.filter((name) => !expected.has(name));
  if (unexpected.length > 0) {
    throw new Error(`${directory}\n- unregistered generated ${label} manifest: ${unexpected.join(', ')}`);
  }
}

async function validateFixtureFiles(directory, registeredFiles) {
  const fixtures = (await readdir(directory))
    .filter((name) => name.endsWith('.json') && !registeredFiles.has(name));
  await Promise.all(
    fixtures.map((name) => validateResolvedThemeFile(path.join(directory, name))),
  );
}

function validateIndexPath(value, label, errors) {
  try {
    validateManifestPath(value, label);
  } catch (error) {
    errors.push(error.message);
  }
}

function requireExactVersion(value, field, errors) {
  if (value[field] !== 1) {
    errors.push(`${field} must be exactly 1`);
  }
}

function requireString(value, field, errors, prefix = '') {
  if (typeof value[field] !== 'string' || value[field].trim().length === 0) {
    errors.push(`${prefix ? `${prefix} ` : ''}${field} must be a non-empty string`);
  }
}

function rejectUnknownFields(value, allowed, label, errors) {
  for (const field of Object.keys(value)) {
    if (!allowed.has(field)) {
      errors.push(`${label} must not contain top-level field: ${field}`);
    }
  }
}

function validateColor(value, field, errors) {
  const color = valueAtPath(value, field);
  const isScrim = field === 'colors.surface.scrim';
  const pattern = isScrim ? /^#[0-9a-fA-F]{8}$/ : /^#[0-9a-fA-F]{6}$/;
  if (typeof color !== 'string' || !pattern.test(color)) {
    errors.push(
      `runtime field ${field} must be a valid ${isScrim ? '#AARRGGBB' : '#RRGGBB'} color`,
    );
  }
}

function hasPath(value, dottedPath) {
  let cursor = value;
  for (const segment of dottedPath.split('.')) {
    if (!cursor || typeof cursor !== 'object'
        || !Object.prototype.hasOwnProperty.call(cursor, segment)) {
      return false;
    }
    cursor = cursor[segment];
  }
  return true;
}

function valueAtPath(value, dottedPath) {
  return dottedPath.split('.').reduce((cursor, segment) => cursor[segment], value);
}

function rejectRawDtcg(value, errors) {
  if (containsRawDtcg(value)) {
    errors.push('document must not contain raw DTCG keys or unresolved token references');
  }
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
    throw new Error('Usage: validate-manifest.mjs <resolved-theme-file-or-generated-theme-directory>');
  }

  const resolved = path.resolve(process.cwd(), target);
  if (path.extname(resolved) === '.json') {
    await validateResolvedThemeFile(resolved);
  } else {
    await validateGeneratedDirectory(resolved);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}
