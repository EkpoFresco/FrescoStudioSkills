#!/usr/bin/env node
// studio-lint: static checks for the rbx-studio payload (skills, agents, rules, docs, templates).
// Usage: node tools/studio-lint.js [all | skills | agents | <skill-or-agent-name>] [--json]
// Prints one row per file: COMPLIANT | WARNINGS | NON-COMPLIANT, with the failing checks.
// Exit 1 if anything is NON-COMPLIANT. Used by /skill-test static.
'use strict';
const fs = require('fs');
const path = require('path');

const REPO = path.resolve(__dirname, '..');
const S = (...p) => path.join(REPO, ...p);
const args = process.argv.slice(2);
const json = args.includes('--json');
const target = args.find((a) => !a.startsWith('--')) || 'all';

const EM = '—';
const ENGINE = /\b(godot|gdscript|unity|unreal|blueprint|\.tscn|steamcmd|butler)\b/i;
const VERDICT = /\b(PASS|FAIL|CONCERNS|APPROVED|CHANGES REQUIRED|NOT ASSESSED|BLOCKER|MAJOR|MINOR|GO|NO-GO|SAFE|AT RISK|PROVEN|PLAUSIBLE)\b/;
const ASSESSING = new Set(['rbx-review', 'rbx-remote-audit', 'rbx-data-audit', 'rbx-perf', 'rbx-playtest', 'rbx-first-60', 'rbx-launch', 'rbx-monetize', 'rbx-optimize', 'rbx-art', 'rbx-metrics', 'rbx-concept', 'rbx-issues']);
const MAX_SKILL_LINES = 300;

function read(p) { return fs.readFileSync(p, 'utf8').replace(/\r\n/g, '\n'); }
function frontmatter(text) {
  const m = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return null;
  const fm = {};
  let key = null;
  for (const line of m[1].split('\n')) {
    const kv = line.match(/^([A-Za-z][\w-]*):\s*(.*)$/);
    if (kv) { key = kv[1]; fm[key] = kv[2].replace(/^"(.*)"$/, '$1'); }
    else if (key && /^\s+-\s+/.test(line)) { fm[key] = (fm[key] ? fm[key] + '\n' : '') + line.trim().slice(2).replace(/^"(.*)"$/, '$1'); }
  }
  return fm;
}
// {{RBX_HOME}}/library/roblox/x -> docs/roblox/x ; {{RBX_HOME}}/y -> studio/rbx-studio/y
function refsMissing(text) {
  const missing = [];
  const re = /\{\{RBX_HOME\}\}\/([A-Za-z0-9_\-./]+[A-Za-z0-9_\-])/g;
  let m;
  while ((m = re.exec(text))) {
    let rel = m[1];
    if (rel.includes('<') || rel.endsWith('/')) continue;
    const p = rel.startsWith('library/roblox') ? S('docs', 'roblox', rel.slice('library/roblox'.length)) : S('studio', 'rbx-studio', rel);
    if (!fs.existsSync(p)) missing.push(rel);
  }
  // bare library file mentions like `ux-standards.md` inside library context are not checked (ambiguous)
  return [...new Set(missing)];
}
function common(text, file, res) {
  if (text.includes(EM)) res.fail.push('em dash present');
  const eng = text.match(ENGINE);
  if (eng) res.fail.push(`engine reference "${eng[0]}"`);
  const miss = refsMissing(text);
  if (miss.length) res.fail.push('broken refs: ' + miss.join(', '));
}
function reportShape(text, res, where) {
  const rep = text.split(/\n## Report\b/)[1];
  if (!rep) { res.fail.push(`no "## Report" section (${where})`); return; }
  for (const w of ['DONE', 'YOU DO', 'NEXT']) if (!rep.includes(w)) res.fail.push(`Report missing ${w}`);
}

function lintSkill(dir) {
  const name = path.basename(dir);
  const file = path.join(dir, 'SKILL.md');
  const res = { kind: 'skill', name, file: path.relative(REPO, file), fail: [], warn: [] };
  if (!fs.existsSync(file)) { res.fail.push('SKILL.md missing'); return res; }
  const text = read(file);
  const fm = frontmatter(text);
  if (!fm) { res.fail.push('frontmatter does not parse'); return res; }
  for (const k of ['name', 'description', 'argument-hint', 'user-invocable', 'allowed-tools']) if (!(k in fm) || fm[k] === '') res.fail.push(`frontmatter missing ${k}`);
  if (fm.name && fm.name !== name) res.fail.push(`name "${fm.name}" != folder "${name}"`);
  if (!name.startsWith('rbx-')) res.fail.push('skill name must start with rbx-');
  if (fm.description && !/^Roblox/.test(fm.description)) res.fail.push('description must start with "Roblox"');
  if (fm.description && fm.description.length > 1000) res.warn.push('description over 1000 chars');
  if (!/\n## 0\. Relevance check\n/.test(text)) res.fail.push('no "## 0. Relevance check"');
  else if (!/SKIPPED|skip/i.test(text.split('## 0. Relevance check')[1].split('\n## ')[0])) res.fail.push('relevance check never skips');
  const phases = (text.match(/\n## [1-9][0-9]?\. /g) || []).length;
  if (phases < 2) res.fail.push(`only ${phases} numbered phases (need >= 2)`);
  reportShape(text, res, 'skill');
  if (ASSESSING.has(name) && !VERDICT.test(text)) res.fail.push('assessment skill without verdict or severity words');
  const tools = fm['allowed-tools'] || '';
  if (/\b(Write|Edit)\b/.test(tools) && !/\.rbx-studio\//.test(text)) res.fail.push('writes files but never states a .rbx-studio/ write scope');
  if (/git push|gh pr create|gh issue create/.test(text) && !/approv/i.test(text)) res.fail.push('mentions push/PR/issue writes without the approval gate');
  const lines = text.split('\n').length;
  if (lines > MAX_SKILL_LINES) res.fail.push(`${lines} lines (max ${MAX_SKILL_LINES})`);
  if (!/\{\{RBX_HOME\}\}\//.test(text)) res.warn.push('never points at the library or studio docs');
  common(text, file, res);
  return res;
}

function lintAgent(file) {
  const name = path.basename(file, '.md');
  const res = { kind: 'agent', name, file: path.relative(REPO, file), fail: [], warn: [] };
  const text = read(file);
  const fm = frontmatter(text);
  if (!fm) { res.fail.push('frontmatter does not parse'); return res; }
  for (const k of ['name', 'description', 'model']) if (!fm[k]) res.fail.push(`frontmatter missing ${k}`);
  if (fm.name !== name) res.fail.push(`name "${fm.name}" != file "${name}"`);
  if (fm.description && !/^Roblox/.test(fm.description)) res.fail.push('description must start with "Roblox"');
  if (!/## Knowledge/.test(text)) res.fail.push('no "## Knowledge" section');
  if (!/## Hard rules/.test(text)) res.fail.push('no "## Hard rules" section');
  if (!/## Hand off to/.test(text)) res.warn.push('no "## Hand off to" section');
  if (!/No em dashes|no em dashes/.test(text)) res.fail.push('style block missing ("No em dashes")');
  reportShape(text, res, 'agent');
  if (!/\{\{RBX_HOME\}\}\/library\/roblox\//.test(text) && !/\{\{RBX_HOME\}\}\/docs\//.test(text)) res.warn.push('reads no library file');
  common(text, file, res);
  return res;
}

function lintPlain(file, kind, needPaths) {
  const res = { kind, name: path.basename(file), file: path.relative(REPO, file), fail: [], warn: [] };
  const text = read(file);
  if (needPaths) { const fm = frontmatter(text); if (!fm || !fm.paths) res.fail.push('rule without paths: frontmatter'); }
  common(text, file, res);
  return res;
}

const results = [];
const skillDirs = fs.readdirSync(S('studio', 'skills')).map((d) => S('studio', 'skills', d)).filter((d) => fs.statSync(d).isDirectory());
const agentFiles = fs.readdirSync(S('studio', 'agents')).filter((f) => f.endsWith('.md')).map((f) => S('studio', 'agents', f));
const want = (n) => target === 'all' || target === n;
if (target === 'all' || target === 'skills') skillDirs.forEach((d) => results.push(lintSkill(d)));
if (target === 'all' || target === 'agents') agentFiles.forEach((f) => results.push(lintAgent(f)));
if (!['all', 'skills', 'agents'].includes(target)) {
  skillDirs.filter((d) => path.basename(d) === target).forEach((d) => results.push(lintSkill(d)));
  agentFiles.filter((f) => path.basename(f, '.md') === target).forEach((f) => results.push(lintAgent(f)));
  if (!results.length) { console.error(`"${target}" is neither a skill in studio/skills/ nor an agent in studio/agents/`); process.exit(2); }
}
if (target === 'all') {
  fs.readdirSync(S('studio', 'rules')).forEach((f) => results.push(lintPlain(S('studio', 'rules', f), 'rule', true)));
  for (const sub of ['docs', 'templates']) fs.readdirSync(S('studio', 'rbx-studio', sub)).forEach((f) => results.push(lintPlain(S('studio', 'rbx-studio', sub, f), sub.slice(0, -1), false)));
  results.push(lintPlain(S('studio', 'rbx-studio', 'CONTEXT.md'), 'context', false));
}

const verdict = (r) => (r.fail.length ? 'NON-COMPLIANT' : r.warn.length ? 'WARNINGS' : 'COMPLIANT');
if (json) { console.log(JSON.stringify(results.map((r) => ({ ...r, verdict: verdict(r) })), null, 2)); }
else {
  const pad = (s, n) => (s + ' '.repeat(n)).slice(0, n);
  console.log(`${pad('Kind', 9)}| ${pad('Name', 28)}| ${pad('Result', 14)}| Issues`);
  for (const r of results) console.log(`${pad(r.kind, 9)}| ${pad(r.name, 28)}| ${pad(verdict(r), 14)}| ${[...r.fail, ...r.warn.map((w) => 'warn: ' + w)].join('; ')}`);
  const c = { 'COMPLIANT': 0, 'WARNINGS': 0, 'NON-COMPLIANT': 0 };
  results.forEach((r) => c[verdict(r)]++);
  const sk = results.filter((r) => r.kind === 'skill').length, ag = results.filter((r) => r.kind === 'agent').length;
  console.log(`\nChecked ${results.length} files (${sk} skills, ${ag} agents, ${results.length - sk - ag} other). ${c.COMPLIANT} COMPLIANT, ${c.WARNINGS} WARNINGS, ${c['NON-COMPLIANT']} NON-COMPLIANT.`);
}
process.exit(results.some((r) => r.fail.length) ? 1 : 0);
