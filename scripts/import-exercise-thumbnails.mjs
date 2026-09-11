import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(new URL('../landing/package.json', import.meta.url));
const sharp = require('sharp');
const root = path.resolve(import.meta.dirname, '..');
const exercises = JSON.parse(await fs.readFile(path.join(root, 'assets/data/free_exercise_db.json'), 'utf8'));
const output = path.join(root, 'assets/exercises');
await fs.mkdir(output, { recursive: true });
let cursor = 0;
const failures = [];
await Promise.all(Array.from({ length: 8 }, async () => {
  while (cursor < exercises.length) {
    const exercise = exercises[cursor++];
    const source = exercise.images?.[0];
    if (!source) continue;
    const destination = path.join(output, `${exercise.id}.webp`);
    try { await fs.access(destination); continue; } catch {}
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        const response = await fetch(`https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${source}`, { signal: AbortSignal.timeout(20000) });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        await sharp(Buffer.from(await response.arrayBuffer()))
          .resize(192, 192, { fit: 'inside', withoutEnlargement: true })
          .webp({ quality: 76 }).toFile(destination);
        break;
      } catch (error) {
        if (attempt === 2) failures.push(`${exercise.id}: ${error.message}`);
      }
    }
  }
}));
console.log(`Thumbnails: ${(await fs.readdir(output)).length}; failures: ${failures.length}`);
if (failures.length) { console.error(failures.join('\n')); process.exitCode = 1; }
