#!/usr/bin/env node
// rbx-map: a Roblox-aware project graph so agents read one small map instead of every script.
// No LLM tokens to build (pure static scan), rebuilt in well under a second for typical games.
//   node rbx-map.js [gameDir]               write .rbx-studio/map.md + map.json
//   node rbx-map.js [gameDir] --check       exit 1 if the map is stale (sources changed)
//   node rbx-map.js [gameDir] --stdout      print map.md, write nothing
//   node rbx-map.js [gameDir] --from-json f build from a Studio scan (rbx-map.luau output) for MCP-only games
// Facts per script: kind, DataModel path, lines, requires, exports, services, remotes (created / fired /
// handled), DataStore calls, purchase hooks, analytics calls, per-frame connections, infinite loops.
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const argv = process.argv.slice(2);
const flag = (f) => argv.includes(f);
const optv = (f) => { const i = argv.indexOf(f); return i >= 0 ? argv[i + 1] : null; };
const ROOT = path.resolve(argv.find((a, i) => !a.startsWith('--') && argv[i - 1] !== '--from-json') || process.cwd());
const OUT = path.join(ROOT, '.rbx-studio');
const SKIP = /(^|[\\/])(node_modules|\.git|Packages|ServerPackages|DevPackages|\.rbx-studio|build|out)([\\/]|$)/;

// ---------- DataModel mapping from default.project.json ----------
function dmMap() {
  const pj = path.join(ROOT, 'default.project.json');
  const map = [];
  if (!fs.existsSync(pj)) return map;
  try {
    const walk = (node, dm) => {
      if (!node || typeof node !== 'object') return;
      if (node.$path) map.push({ fs: path.resolve(ROOT, node.$path), dm });
      for (const [k, v] of Object.entries(node)) if (!k.startsWith('$')) walk(v, dm ? `${dm}.${k}` : k);
    };
    walk(JSON.parse(fs.readFileSync(pj, 'utf8')).tree, '');
  } catch { /* unreadable project file: paths stay file-based */ }
  return map.sort((a, b) => b.fs.length - a.fs.length);
}
const DM = dmMap();
function dmPath(file) {
  const m = DM.find((x) => file === x.fs || file.startsWith(x.fs + path.sep));
  if (!m) return null;
  let rel = path.relative(m.fs, file).replace(/\\/g, '/');
  rel = rel.replace(/\.(server|client)?\.?(luau|lua)$/, '').replace(/\/init$/, '').replace(/^init$/, '');
  return [m.dm, ...rel.split('/').filter(Boolean)].join('.');
}

// ---------- scan one source ----------
const kindOf = (name) => (/\.server\.(luau|lua)$/.test(name) ? 'server' : /\.client\.(luau|lua)$/.test(name) ? 'client' : 'module');
function scan(src) {
  const lines = src.replace(/\r\n/g, '\n').split('\n');
  const f = { lines: lines.length, requires: [], exports: [], services: [], remotes: { created: [], fired: [], handled: [] }, data: [], purchases: [], analytics: [], perFrame: [], loops: [], connects: 0, strict: /^--!strict/.test(src) };
  const push = (arr, v) => { if (!arr.includes(v)) arr.push(v); };
  // local aliases: local remoteBuy = Remotes.get("BuyUpgrade") / :WaitForChild("BuyUpgrade")
  const alias = {};
  for (const m of src.matchAll(/local\s+(\w+)\s*(?::\s*\w+)?\s*=\s*[^\r\n]*?(?:get|WaitForChild|FindFirstChild)\(\s*["'](\w+)["']\s*\)/g)) alias[m[1]] = m[2];
  lines.forEach((l, i) => {
    const n = i + 1;
    if (/^\s*--/.test(l)) return;
    for (const m of l.matchAll(/require\(\s*([^)]+?)\s*\)/g)) {
      const t = m[1].match(/["']([^"']+)["']\s*\)?\s*$/) || m[1].match(/([A-Za-z_][\w]*)\s*\)?\s*$/);
      if (t) push(f.requires, t[1]);
    }
    for (const m of l.matchAll(/GetService\(\s*["'](\w+)["']\s*\)/g)) push(f.services, m[1]);
    let m;
    if ((m = l.match(/^function\s+\w+[.:](\w+)\s*\(/))) f.exports.push(`${m[1]}:${n}`);
    if (/Instance\.new\(\s*["'](RemoteEvent|RemoteFunction|UnreliableRemoteEvent)["']/.test(l)) f.remotes.created.push(`${n}`);
    const rname = (s) => { const r = s.match(/["'](\w+)["']\s*\)\s*[.:]\s*(?:Fire|On|Invoke)/) || s.match(/(?:remotes|Remotes|net|Net)\.(\w+)[.:]/) || s.match(/(\w+)[.:](?:FireServer|FireClient|FireAllClients|OnServerEvent|OnClientEvent|OnServerInvoke|InvokeServer)/); return r ? (alias[r[1]] || r[1]) : '?'; };
    if (/:(FireServer|FireClient|FireAllClients|InvokeServer)\s*\(/.test(l)) f.remotes.fired.push(`${rname(l)}@${n}`);
    if (/\.(OnServerEvent|OnServerInvoke|OnClientEvent)\b/.test(l)) f.remotes.handled.push(`${rname(l)}@${n}${/function\s*\(([^)]*,[^)]*)\)/.test(l) ? '(args)' : ''}`);
    if (/\b(GetDataStore|GetOrderedDataStore|UpdateAsync|SetAsync|GetAsync|RemoveAsync|IncrementAsync)\b/.test(l)) f.data.push(`${(l.match(/\b(GetDataStore|GetOrderedDataStore|UpdateAsync|SetAsync|GetAsync|RemoveAsync|IncrementAsync)\b/) || [])[1]}@${n}`);
    if (/ProcessReceipt|BindReceiptHandler|PromptProductPurchase|PromptGamePassPurchase|UserOwnsGamePassAsync|PromptSubscriptionPurchase/.test(l)) f.purchases.push(`${(l.match(/ProcessReceipt|BindReceiptHandler|PromptProductPurchase|PromptGamePassPurchase|UserOwnsGamePassAsync|PromptSubscriptionPurchase/) || [])[0]}@${n}`);
    if (/AnalyticsService\s*:\s*Log\w+/.test(l)) f.analytics.push(`${(l.match(/Log\w+/) || [])[0]}@${n}`);
    if (/\.(RenderStepped|Heartbeat|Stepped|PreSimulation|PostSimulation|PreRender|PreAnimation)\s*:\s*Connect/.test(l)) f.perFrame.push(`${(l.match(/RenderStepped|Heartbeat|Stepped|PreSimulation|PostSimulation|PreRender|PreAnimation/) || [])[0]}@${n}`);
    if (/^\s*while\s+true\s+do/.test(l)) f.loops.push(`${n}`);
    f.connects += (l.match(/:Connect\(/g) || []).length;
  });
  return f;
}

// ---------- collect ----------
function collectFiles() {
  const out = [];
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (SKIP.test(p.slice(ROOT.length))) continue;
      if (e.isDirectory()) walk(p);
      else if (/\.(luau|lua)$/.test(e.name)) out.push(p);
    }
  };
  walk(ROOT);
  return out.sort();
}
function fromFiles() {
  const files = collectFiles();
  const h = crypto.createHash('sha256');
  const scripts = files.map((p) => {
    const src = fs.readFileSync(p, 'utf8');
    h.update(p).update(src);
    return { path: path.relative(ROOT, p).replace(/\\/g, '/'), dm: dmPath(p), kind: kindOf(p), ...scan(src) };
  });
  return { source: 'files', hash: h.digest('hex').slice(0, 16), scripts };
}
function fromStudio(jsonFile) {
  const raw = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));
  const h = crypto.createHash('sha256');
  const scripts = raw.map((s) => {
    h.update(s.path).update(s.source || '');
    const kind = s.className === 'Script' ? 'server' : s.className === 'LocalScript' ? 'client' : 'module';
    return { path: s.path, dm: s.path, kind, ...scan(s.source || '') };
  });
  return { source: 'studio', hash: h.digest('hex').slice(0, 16), scripts };
}

// ---------- render ----------
function render(g) {
  const L = [];
  const s = g.scripts;
  const at = (x) => x.dm || x.path;
  L.push(`# Project map (${g.source}, ${s.length} scripts, ${s.reduce((a, b) => a + b.lines, 0)} lines) hash ${g.hash}`);
  L.push(`Built by rbx-map. Read this before opening scripts; open only the files a task needs. Rebuild: node "{{RBX_HOME}}/tools/rbx-map.js".`);
  const remotes = {};
  for (const x of s) {
    for (const r of x.remotes.fired) { const [n, line] = r.split('@'); (remotes[n] ||= { fired: [], handled: [] }).fired.push(`${x.path}:${line}`); }
    for (const r of x.remotes.handled) { const [n, line] = r.split('@'); (remotes[n] ||= { fired: [], handled: [] }).handled.push(`${x.path}:${line}`); }
  }
  if (Object.keys(remotes).length) {
    L.push('\n## Remotes (name: fired at -> handled at)');
    for (const [n, r] of Object.entries(remotes).sort()) L.push(`- ${n}: ${r.fired.join(', ') || '-'} -> ${r.handled.join(', ') || '-'}`);
  }
  const list = (title, key) => { const rows = s.filter((x) => x[key].length).map((x) => `- ${x.path}: ${x[key].join(', ')}`); if (rows.length) L.push(`\n## ${title}`, ...rows); };
  list('DataStore calls', 'data');
  list('Purchases', 'purchases');
  list('Analytics', 'analytics');
  list('Per-frame connections (hot paths)', 'perFrame');
  list('Infinite loops (while true)', 'loops');
  L.push('\n## Scripts');
  for (const x of s) {
    const bits = [`${x.kind}`, `${x.lines} lines`, x.strict ? 'strict' : 'not strict', `${x.connects} connects`];
    L.push(`- ${x.path}${x.dm && x.dm !== x.path ? ` (${x.dm})` : ''}: ${bits.join(', ')}`);
    if (x.requires.length) L.push(`  requires: ${x.requires.join(', ')}`);
    if (x.exports.length) L.push(`  exports: ${x.exports.join(', ')}`);
    if (x.services.length) L.push(`  services: ${x.services.join(', ')}`);
  }
  return L.join('\n') + '\n';
}

// ---------- main ----------
const g = optv('--from-json') ? fromStudio(optv('--from-json')) : fromFiles();
if (!g.scripts.length) { console.error('rbx-map: no .luau/.lua files found under ' + ROOT + (optv('--from-json') ? '' : ' (MCP-only game? run rbx-map.luau via execute_luau, then --from-json)')); process.exit(2); }
if (flag('--check')) {
  let old = null;
  try { old = JSON.parse(fs.readFileSync(path.join(OUT, 'map.json'), 'utf8')).hash; } catch { /* no map yet */ }
  if (old === g.hash) { console.log('map current'); process.exit(0); }
  console.log(old ? 'map stale' : 'no map'); process.exit(1);
}
const md = render(g).replace('{{RBX_HOME}}', path.resolve(__dirname, '..').replace(/\\/g, '/'));
if (flag('--stdout')) { process.stdout.write(md); process.exit(0); }
fs.mkdirSync(OUT, { recursive: true });
fs.writeFileSync(path.join(OUT, 'map.md'), md);
fs.writeFileSync(path.join(OUT, 'map.json'), JSON.stringify(g));
console.log(`rbx-map: ${g.scripts.length} scripts -> .rbx-studio/map.md (~${Math.round(md.length / 4)} tok)`);
