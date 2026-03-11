// Renders a .cast file to GIF using Playwright (headless Chromium) + asciinema-player + ffmpeg.
// This gives full emoji/icon support that agg lacks.
//
// Usage: node assets/render-gif.mjs [cast-file]
// Default cast file: .tmp/demo.cast
// Output: assets/demo.gif
//
// Prerequisites: npm install playwright (in .tmp/), ffmpeg, Playwright Chromium browser

import { chromium } from 'playwright';
import { execSync } from 'child_process';
import { mkdirSync, existsSync, rmSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createServer } from 'http';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const CAST_FILE = process.argv[2] || join(ROOT, '.tmp', 'demo.cast');
const FRAMES_DIR = join(ROOT, '.tmp', 'frames');
const OUTPUT_GIF = join(__dirname, 'demo.gif');
const FPS = 10;
const FRAME_INTERVAL = 1000 / FPS;

if (!existsSync(CAST_FILE)) {
  console.error(`Cast file not found: ${CAST_FILE}`);
  console.error('Run "make demo-record" first.');
  process.exit(1);
}

// Serve the HTML player and cast file via local HTTP
const server = createServer((req, res) => {
  let filePath;
  if (req.url === '/') filePath = join(__dirname, 'render-cast.html');
  else if (req.url === '/demo.cast') filePath = CAST_FILE;
  else filePath = join(__dirname, req.url);

  try {
    const content = readFileSync(filePath);
    const ext = filePath.split('.').pop();
    const types = { html: 'text/html', css: 'text/css', js: 'application/javascript', cast: 'application/json' };
    res.writeHead(200, { 'Content-Type': types[ext] || 'application/octet-stream' });
    res.end(content);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
});

await new Promise(resolve => server.listen(0, resolve));
const port = server.address().port;
console.log(`Serving on http://localhost:${port}`);

// Clean up and create frames directory
if (existsSync(FRAMES_DIR)) rmSync(FRAMES_DIR, { recursive: true });
mkdirSync(FRAMES_DIR, { recursive: true });

console.log('Launching browser...');
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
await page.setViewportSize({ width: 1200, height: 800 });

await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle' });
await page.waitForSelector('.ap-player', { timeout: 15000 });
console.log('Player loaded. Waiting for autoplay...');
await page.waitForTimeout(3000);

// Capture frames
let frameNum = 0;
const maxFrames = 120 * FPS; // 120 seconds max
let endedCount = 0;

console.log('Capturing frames...');
for (let i = 0; i < maxFrames; i++) {
  const framePath = join(FRAMES_DIR, `frame-${String(frameNum).padStart(5, '0')}.png`);
  await page.screenshot({ path: framePath });
  frameNum++;

  const isFinished = await page.evaluate(() => {
    const el = document.querySelector('.ap-player');
    return el?.classList?.contains('ap-ended') || false;
  });

  if (isFinished) {
    endedCount++;
    if (endedCount > 20) {
      console.log(`Player ended at frame ${frameNum}`);
      break;
    }
  } else {
    endedCount = 0;
  }

  await page.waitForTimeout(FRAME_INTERVAL);

  if (frameNum % 50 === 0) {
    console.log(`  ${frameNum} frames (${(frameNum / FPS).toFixed(0)}s)...`);
  }
}

console.log(`Captured ${frameNum} frames (${(frameNum / FPS).toFixed(1)}s).`);
await browser.close();
server.close();

// Convert frames to GIF using ffmpeg
console.log('Converting to GIF...');
execSync(
  `ffmpeg -y -framerate ${FPS} -i "${FRAMES_DIR}/frame-%05d.png" ` +
  `-vf "fps=${FPS},scale=1200:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" ` +
  `"${OUTPUT_GIF}"`,
  { stdio: 'inherit' }
);

const size = execSync(`du -h "${OUTPUT_GIF}" | cut -f1`).toString().trim();
console.log(`GIF saved to ${OUTPUT_GIF} (${size})`);

rmSync(FRAMES_DIR, { recursive: true });
console.log('Done!');
