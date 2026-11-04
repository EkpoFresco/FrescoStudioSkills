#!/usr/bin/env node
// Minimal stdio client for Roblox Studio's built-in MCP server (StudioMCP.exe via mcp.bat).
// For scripts and hooks that need MCP outside a Claude MCP connection, and to save
// screen_capture images to disk as look-check evidence.
//   node mcp-call.js list
//   node mcp-call.js <tool> '<json args>' [--out <file.png>] [--timeout 120]
//   node mcp-call.js batch <file.jsonl> [--outdir <dir>]   (one {"tool":..,"args":..,"out":..} per line, one server)
// Server command: $RBX_MCP_CMD, else %LOCALAPPDATA%\Roblox\mcp.bat.
'use strict';
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf(k); return i >= 0 ? argv[i + 1] : d; };
const timeoutS = Number(opt('--timeout', '180'));
const cmd = process.env.RBX_MCP_CMD || path.join(process.env.LOCALAPPDATA || '', 'Roblox', 'mcp.bat');

function start() {
  const child = spawn(cmd, [], { shell: true, stdio: ['pipe', 'pipe', 'pipe'], windowsHide: true });
  let buf = '';
  const pending = new Map();
  child.stdout.on('data', (d) => {
    buf += d.toString('utf8');
    let i;
    while ((i = buf.indexOf('\n')) >= 0) {
      const line = buf.slice(0, i).trim(); buf = buf.slice(i + 1);
      if (!line) continue;
      let msg; try { msg = JSON.parse(line); } catch { continue; }
      if (msg.id !== undefined && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
    }
  });
  child.stderr.on('data', (d) => { if (process.env.RBX_MCP_DEBUG) process.stderr.write(d); });
  let id = 0;
  const req = (method, params) => new Promise((res, rej) => {
    const myId = ++id;
    const t = setTimeout(() => { pending.delete(myId); rej(new Error(`${method} timed out after ${timeoutS}s`)); }, timeoutS * 1000);
    pending.set(myId, (m) => { clearTimeout(t); m.error ? rej(new Error(JSON.stringify(m.error))) : res(m.result); });
    child.stdin.write(JSON.stringify({ jsonrpc: '2.0', id: myId, method, params }) + '\n');
  });
  const notify = (method, params) => child.stdin.write(JSON.stringify({ jsonrpc: '2.0', method, params }) + '\n');
  return { child, req, notify };
}

function printResult(r, out) {
  const parts = (r && r.content) || [];
  let n = 0;
  for (const p of parts) {
    if (p.type === 'text') console.log(p.text);
    else if (p.type === 'image') {
      const file = out ? (parts.filter((x) => x.type === 'image').length > 1 ? out.replace(/(\.\w+)?$/, `-${n}$1`) : out) : `mcp-image-${Date.now()}-${n}.png`;
      fs.mkdirSync(path.dirname(path.resolve(file)), { recursive: true });
      fs.writeFileSync(file, Buffer.from(p.data, 'base64'));
      console.log(`[image saved: ${file} (${p.mimeType || 'image'})]`);
      n++;
    } else console.log(JSON.stringify(p));
  }
  if (r && r.isError) process.exitCode = 1;
}

(async () => {
  if (!argv.length) { console.error('usage: mcp-call.js list | <tool> <json> [--out f] | batch <file.jsonl>'); process.exit(2); }
  const s = start();
  try {
    await s.req('initialize', { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'rbx-studio-mcp-call', version: '1.0' } });
    s.notify('notifications/initialized', {});
    if (argv[0] === 'list') {
      const r = await s.req('tools/list', {});
      for (const t of r.tools) console.log(t.name);
    } else if (argv[0] === 'batch') {
      const lines = fs.readFileSync(argv[1], 'utf8').split(/\r?\n/).filter((l) => l.trim());
      for (const l of lines) {
        const step = JSON.parse(l);
        console.log(`### ${step.tool}`);
        if (step.sleep) { await new Promise((r) => setTimeout(r, step.sleep * 1000)); continue; }
        try { printResult(await s.req('tools/call', { name: step.tool, arguments: step.args || {} }), step.out); }
        catch (e) { console.log('ERROR ' + e.message); process.exitCode = 1; }
      }
    } else {
      const args = argv[1] && !argv[1].startsWith('--') ? JSON.parse(argv[1]) : {};
      printResult(await s.req('tools/call', { name: argv[0], arguments: args }), opt('--out'));
    }
  } catch (e) {
    console.error('MCP error: ' + e.message); process.exitCode = 1;
  } finally {
    s.child.stdin.end(); setTimeout(() => { try { s.child.kill(); } catch {} process.exit(); }, 300);
  }
})();
