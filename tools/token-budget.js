#!/usr/bin/env node
// Estimates the token cost of the rbx-studio payload (chars / 4, an estimate, not a tokenizer).
// Usage: node tools/token-budget.js [--json]
//   always-on  : what every Claude Code session pays (skill + agent listings), Roblox or not
//   roblox-start: what a Roblox session pays at start (SessionStart context)
//   per-skill  : SKILL.md body loaded when a skill runs, plus the library files it names
'use strict';
const fs = require('fs');
const path = require('path');
const REPO = path.resolve(__dirname, '..');
const S = (...p) => path.join(REPO, ...p);
const tok = (s) => Math.round(s.length / 4);
const read = (p) => fs.readFileSync(p, 'utf8');
const fm = (t) => { const m = t.match(/^---\r?\n([\s\S]*?)\r?\n---/); return m ? m[1] : ''; };
const field = (f, k) => { const m = f.match(new RegExp(`^${k}:\\s*"?(.*?)"?\\s*$`, 'm')); return m ? m[1] : ''; };

const skills = fs.readdirSync(S('studio', 'skills')).map((d) => {
  const t = read(S('studio', 'skills', d, 'SKILL.md'));
  const f = fm(t);
  const hidden = /^disable-model-invocation:\s*true/m.test(f);
  const listing = hidden ? 0 : tok(`- ${d}: ${field(f, 'description')}`);
  const libs = [...new Set([...t.matchAll(/\{\{RBX_HOME\}\}\/library\/roblox\/([\w\-/]+\.md)/g)].map((m) => m[1]))];
  const libTok = libs.reduce((a, l) => a + (fs.existsSync(S('docs', 'roblox', l)) ? tok(read(S('docs', 'roblox', l))) : 0), 0);
  return { name: d, hidden, listing, body: tok(t), libs: libs.length, libTok };
});
const agents = fs.readdirSync(S('studio', 'agents')).map((f) => {
  const t = read(S('studio', 'agents', f));
  return { name: f.replace('.md', ''), listing: tok(`- ${f.replace('.md', '')}: ${field(fm(t), 'description')}`), body: tok(t) };
});
const ctx = tok(read(S('studio', 'rbx-studio', 'CONTEXT.md'))) + 60;
const lib = fs.readdirSync(S('docs', 'roblox')).filter((f) => f.endsWith('.md')).map((f) => ({ name: f, tok: tok(read(S('docs', 'roblox', f))) }));

const sum = (a, k) => a.reduce((x, y) => x + y[k], 0);
const out = {
  alwaysOn: { skills: sum(skills, 'listing'), agents: sum(agents, 'listing'), total: sum(skills, 'listing') + sum(agents, 'listing'), hiddenSkills: skills.filter((s) => s.hidden).length },
  robloxStart: ctx,
  skillBodyAvg: Math.round(sum(skills, 'body') / skills.length),
  skillBodyMax: Math.max(...skills.map((s) => s.body)),
  libraryNamedPerSkillAvg: Math.round(sum(skills, 'libTok') / skills.length),
  libraryTotal: sum(lib, 'tok'),
  biggestLibrary: lib.sort((a, b) => b.tok - a.tok).slice(0, 5),
};
if (process.argv.includes('--json')) console.log(JSON.stringify({ ...out, skills, agents }, null, 2));
else {
  console.log(`always-on listing (every session): ${out.alwaysOn.total} tok  [skills ${out.alwaysOn.skills} (${out.alwaysOn.hiddenSkills} hidden), agents ${out.alwaysOn.agents}]`);
  console.log(`roblox session start (CONTEXT): ${out.robloxStart} tok`);
  console.log(`skill body: avg ${out.skillBodyAvg}, max ${out.skillBodyMax} tok`);
  console.log(`library files a skill names (if read whole): avg ${out.libraryNamedPerSkillAvg} tok per skill`);
  console.log(`library total: ${out.libraryTotal} tok; biggest: ${out.biggestLibrary.map((b) => `${b.name} ${b.tok}`).join(', ')}`);
}
