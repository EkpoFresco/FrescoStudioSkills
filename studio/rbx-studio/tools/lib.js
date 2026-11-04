#!/usr/bin/env node
// Token-cheap reader for the rbx-studio research library. Library files run 8k-13k tokens;
// most tasks need the TL;DR plus one section (300-1,500 tokens).
//   node lib.js                         index: every file, its size, its ## sections
//   node lib.js <file>                  TL;DR + section list (line, ~tokens) for one file
//   node lib.js <file> <section words>  print just that section (heading substring match)
//   node lib.js --grep <regex> [file]   matching lines with file:line (max 40)
// <file> is a stem: implementation, genres/idle-clicker, policy ...
'use strict';
const fs = require('fs');
const path = require('path');

const candidates = [path.join(__dirname, '..', 'library', 'roblox'), path.join(__dirname, '..', '..', '..', 'docs', 'roblox')];
const LIB = candidates.find((p) => fs.existsSync(p));
if (!LIB) { console.error('library not found'); process.exit(2); }
const tok = (s) => Math.round(s.length / 4);
const args = process.argv.slice(2);

function files(dir = LIB, pre = '') {
  return fs.readdirSync(dir).flatMap((f) => {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) return files(p, pre + f + '/');
    return f.endsWith('.md') ? [pre + f.slice(0, -3)] : [];
  });
}
function load(stem) {
  const p = path.join(LIB, stem.replace(/\.md$/, '') + '.md');
  if (!fs.existsSync(p)) {
    const hits = files().filter((f) => f.includes(stem));
    if (hits.length === 1) return load(hits[0]);
    console.error(hits.length ? `ambiguous "${stem}": ${hits.join(', ')}` : `no library file "${stem}"`);
    process.exit(2);
  }
  return { stem, lines: fs.readFileSync(p, 'utf8').replace(/\r\n/g, '\n').split('\n') };
}
function sections(lines) {
  const out = [];
  lines.forEach((l, i) => { const m = l.match(/^(#{2,3}) (.+)/); if (m) out.push({ level: m[1].length, title: m[2], start: i }); });
  out.forEach((s, i) => {
    const next = out.slice(i + 1).find((n) => n.level <= s.level);
    s.end = next ? next.start : lines.length;
    s.tok = tok(lines.slice(s.start, s.end).join('\n'));
  });
  return out;
}

if (!args.length) {
  for (const f of files()) {
    const { lines } = load(f);
    const secs = sections(lines).filter((s) => s.level === 2 && !/^Sources/i.test(s.title));
    console.log(`${f} (~${tok(lines.join('\n'))} tok): ${secs.map((s) => s.title.replace(/\s*\(.*\)$/, '')).join(' | ')}`);
  }
} else if (args[0] === '--grep') {
  const re = new RegExp(args[1], 'i');
  let n = 0;
  for (const f of args[2] ? [args[2]] : files()) {
    const { lines, stem } = load(f);
    lines.forEach((l, i) => { if (n < 40 && re.test(l) && !/^\[\d+\]/.test(l)) { console.log(`${stem}:${i + 1}: ${l.slice(0, 220)}`); n++; } });
  }
  if (!n) console.log('no matches');
} else {
  const { stem, lines } = load(args[0]);
  const secs = sections(lines);
  if (args.length === 1) {
    const tl = secs.find((s) => /TL;DR/i.test(s.title));
    console.log(lines.slice(0, 2).join('\n'));
    if (tl) console.log(lines.slice(tl.start, tl.end).join('\n').trim());
    console.log(`\nSections in ${stem} (read one: node lib.js ${stem} "<words>"):`);
    for (const s of secs) if (!/TL;DR|^Sources/i.test(s.title)) console.log(`${'  '.repeat(s.level - 2)}- ${s.title}  (line ${s.start + 1}, ~${s.tok} tok)`);
  } else {
    const q = args.slice(1).join(' ').toLowerCase();
    const s = secs.find((x) => x.title.toLowerCase() === q) || secs.find((x) => x.title.toLowerCase().includes(q));
    if (!s) { console.error(`no section matching "${q}" in ${stem}. Sections: ${secs.map((x) => x.title).join(' | ')}`); process.exit(2); }
    console.log(`[${stem} lines ${s.start + 1}-${s.end}, ~${s.tok} tok]`);
    console.log(lines.slice(s.start, s.end).join('\n').trim());
    const cites = [...new Set((lines.slice(s.start, s.end).join(' ').match(/\[(\d+)\]/g) || []))];
    if (cites.length) {
      const src = lines.filter((l) => cites.some((c) => l.startsWith(c + ' ')));
      if (src.length) console.log('\nSources:\n' + src.join('\n'));
    }
  }
}
