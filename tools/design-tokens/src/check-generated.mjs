import { readdir, readFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const GENERATED_DIR = path.resolve(new URL('../../../generated/themes', import.meta.url).pathname);
const BUILD_SCRIPT = path.resolve(new URL('../build.mjs', import.meta.url).pathname);

export async function checkGenerated() {
  const before = await snapshotDirectory(GENERATED_DIR);
  await runNode(BUILD_SCRIPT);
  const after = await snapshotDirectory(GENERATED_DIR);

  const changed = diffSnapshots(before, after);
  if (changed.length > 0) {
    throw new Error(`Generated theme manifests are stale:\n${changed.map((file) => `- ${file}`).join('\n')}`);
  }
}

async function snapshotDirectory(directoryPath) {
  const files = await listJsonFiles(directoryPath);
  const entries = await Promise.all(
    files.map(async (file) => [path.relative(directoryPath, file), await readFile(file, 'utf8')]),
  );
  return new Map(entries);
}

async function listJsonFiles(directoryPath) {
  let entries;
  try {
    entries = await readdir(directoryPath, { withFileTypes: true });
  } catch {
    return [];
  }

  const files = await Promise.all(entries.map(async (entry) => {
    const fullPath = path.join(directoryPath, entry.name);
    if (entry.isDirectory()) {
      return listJsonFiles(fullPath);
    }
    return entry.isFile() && entry.name.endsWith('.json') ? [fullPath] : [];
  }));

  return files.flat().sort();
}

function diffSnapshots(before, after) {
  const names = new Set([...before.keys(), ...after.keys()]);
  return [...names].filter((name) => before.get(name) !== after.get(name)).sort();
}

function runNode(scriptPath) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [scriptPath], {
      cwd: path.resolve(new URL('..', import.meta.url).pathname),
      stdio: 'inherit',
    });

    child.on('error', reject);
    child.on('exit', (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`build exited with code ${code}`));
    });
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  checkGenerated().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}
