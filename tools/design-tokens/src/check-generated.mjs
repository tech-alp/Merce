import { readdir, readFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { validateGeneratedDirectory } from './validate-manifest.mjs';

const GENERATED_THEME_DIR = path.resolve(new URL('../../../generated/themes', import.meta.url).pathname);
const GENERATED_PROFILE_DIR = path.resolve(new URL('../../../generated/profiles', import.meta.url).pathname);
const BUILD_SCRIPT = path.resolve(new URL('../build.mjs', import.meta.url).pathname);

export async function checkGenerated() {
  const generatedDirectories = [GENERATED_THEME_DIR, GENERATED_PROFILE_DIR];
  const before = await snapshotDirectories(generatedDirectories);
  await runNode(BUILD_SCRIPT);
  await validateGeneratedDirectory(GENERATED_THEME_DIR);
  const after = await snapshotDirectories(generatedDirectories);

  const changed = diffSnapshots(before, after);
  if (changed.length > 0) {
    throw new Error(`Generated theme/profile manifests are stale:\n${changed.map((file) => `- ${file}`).join('\n')}`);
  }
}

async function snapshotDirectories(directoryPaths) {
  const snapshots = await Promise.all(
    directoryPaths.map(async (directoryPath) => [directoryPath, await snapshotDirectory(directoryPath)]),
  );

  return new Map(
    snapshots.flatMap(([directoryPath, snapshot]) => (
      [...snapshot.entries()].map(([name, content]) => [
        path.join(path.basename(directoryPath), name),
        content,
      ])
    )),
  );
}

async function snapshotDirectory(directoryPath) {
  const files = await listFiles(directoryPath);
  const entries = await Promise.all(files.map(async (file) => {
    const content = await readFile(file);
    return [path.relative(directoryPath, file), content.toString('base64')];
  }));
  return new Map(entries);
}

async function listFiles(directoryPath) {
  let entries;
  try {
    entries = await readdir(directoryPath, { withFileTypes: true });
  } catch {
    return [];
  }

  const files = await Promise.all(entries.map(async (entry) => {
    const fullPath = path.join(directoryPath, entry.name);
    if (entry.isDirectory()) {
      return listFiles(fullPath);
    }
    return entry.isFile() ? [fullPath] : [];
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
