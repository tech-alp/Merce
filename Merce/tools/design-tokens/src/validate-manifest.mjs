import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const REQUIRED_TOP_LEVEL = [
  'schemaVersion',
  'theme',
  'palette',
  'spacing',
  'radius',
  'typography',
];

const REQUIRED_FIELDS = [
  'palette.textPrimary',
  'palette.backgroundBase',
  'palette.actionPrimary',
  'spacing.md',
  'spacing.touchTarget',
  'radius.button',
  'typography.bodyFont',
];

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

  if ('colors' in manifest) {
    errors.push('manifest must not contain a top-level colors compatibility section');
  }

  for (const field of REQUIRED_FIELDS) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required runtime field: ${field}`);
    }
  }

  if (containsRawDtcg(manifest)) {
    errors.push('manifest must not contain raw DTCG keys or unresolved token references');
  }

  return {
    ok: errors.length === 0,
    errors,
  };
}

export async function validateManifestFile(filePath, context = {}) {
  const manifest = JSON.parse(await readFile(filePath, 'utf8'));
  const result = validateManifest(manifest, context);

  if (!result.ok) {
    throw new Error(`${filePath}\n- ${result.errors.join('\n- ')}`);
  }

  return result;
}

async function validateDirectory(directoryPath) {
  const indexPath = path.join(directoryPath, 'index.json');
  const index = JSON.parse(await readFile(indexPath, 'utf8'));
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
