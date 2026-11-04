const fs = require('fs');
const path = require('path');
const src = process.argv[2] || path.join(process.env.LOCALAPPDATA || '', 'Roblox', 'StudioMCP', 'tools-cache.json');
const out = process.argv[3] || path.join(__dirname, '..', 'docs', 'roblox', 'studio-mcp-tools.md');
const j = JSON.parse(fs.readFileSync(src, 'utf8'));
const d = new Date(j.date * 1000).toISOString().slice(0,10);
let md = `# Roblox Studio MCP: Tool Manifest\n\nSource: built-in Studio MCP server (StudioMCP.exe, shipped with Roblox Studio), tool cache at \`%LOCALAPPDATA%\Roblox\StudioMCP\tools-cache.json\`.\nCache written by Studio on ${d}. Checked 2026-11-03. Tool count: ${j.tools.length}.\nLaunch command Studio registers: \`%LOCALAPPDATA%\Roblox\mcp.bat\` (wraps \`Versions\<ver>\StudioMCP.exe\`).\nThis file is generated verbatim from the cache. Re-generate after Studio updates: \`node tools/dump-mcp-manifest.js\`.\n\n## Index\n\n| Tool | Params |\n|---|---|\n`;
for (const t of j.tools) md += `| \`${t.name}\` | ${Object.keys((t.inputSchema||{}).properties||{}).filter(p=>p!=='studio_id').join(', ')} |\n`;
md += `\nEvery tool also takes optional \`studio_id\` (target a specific open Studio window).\n\n## Full descriptions\n`;
for (const t of j.tools) {
  md += `\n### \`${t.name}\`\n\n${(t.description||'').trim()}\n\n`;
  const props = (t.inputSchema||{}).properties||{};
  const req = new Set((t.inputSchema||{}).required||[]);
  const keys = Object.keys(props).filter(p=>p!=='studio_id');
  if (keys.length) {
    md += `| Param | Type | Req | Notes |\n|---|---|---|---|\n`;
    for (const k of keys) {
      const p = props[k];
      let type = p.type || (p.enum ? 'enum' : (p.anyOf ? p.anyOf.map(a=>a.type).join('|') : ''));
      if (p.enum) type += ': ' + p.enum.join(' / ');
      const desc = (p.description||'').replace(/\|/g,'\|').replace(/\n+/g,' ');
      md += `| ${k} | ${type} | ${req.has(k)?'yes':''} | ${desc} |\n`;
    }
  }
}
fs.writeFileSync(out, md);
console.log('wrote', out, md.length, 'chars');
