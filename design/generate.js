const fs   = require('fs');
const path = require('path');

const tokens = JSON.parse(fs.readFileSync(path.join(__dirname, 'tokens.json'), 'utf8'));

// ─── CSS ──────────────────────────────────────────────────────────────────────
// Only write CSS if the web project output directory actually exists.
// The canonical path is set by WEB_TOKENS_OUT env var, or falls back to the
// sibling location used on the web dev machine.
const cssOutEnv = process.env.WEB_TOKENS_OUT;
const cssOutDefault = path.join(path.dirname(__dirname), 'daybefore-web', 'app', 'src', 'tokens.css');
const cssOut = cssOutEnv || cssOutDefault;

let css = `/* AUTO-GENERATED FROM tokens.json — do not hand-edit */\n\n:root {\n`;
for (const [key, value] of Object.entries(tokens.typography.fontFamily)) {
  css += `  --font-${key}: ${value};\n`;
}
for (const [key, value] of Object.entries(tokens.typography.scale)) {
  css += `  --text-${key}: ${value};\n`;
}
css += `  --radius-small: ${tokens.space.radii.small};\n`;
css += `  --radius-large: ${tokens.space.radii.large};\n`;
css += `}\n\n`;

css += `@media (prefers-color-scheme: dark) {\n  :root {\n`;
for (const [key, value] of Object.entries(tokens.colors.dark)) {
  css += `    --color-${key}: ${value};\n`;
}
css += `  }\n}\n\n`;

css += `@media (prefers-color-scheme: light) {\n  :root {\n`;
for (const [key, value] of Object.entries(tokens.colors.light)) {
  css += `    --color-${key}: ${value};\n`;
}
css += `  }\n}\n\n`;

css += `[data-theme="dark"] {\n`;
for (const [key, value] of Object.entries(tokens.colors.dark)) {
  css += `  --color-${key}: ${value};\n`;
}
css += `}\n\n`;

css += `[data-theme="light"] {\n`;
for (const [key, value] of Object.entries(tokens.colors.light)) {
  css += `  --color-${key}: ${value};\n`;
}
css += `}\n`;

const cssDir = path.dirname(cssOut);
if (fs.existsSync(cssDir)) {
  fs.writeFileSync(cssOut, css);
  console.log(`CSS tokens written to: ${cssOut}`);
} else {
  console.log(`CSS output directory does not exist (${cssDir}). Skipping CSS write.`);
  console.log(`To generate CSS, set WEB_TOKENS_OUT=/path/to/daybefore-web/app/src/tokens.css`);
}

// ─── Dart ─────────────────────────────────────────────────────────────────────
// Writes gen_colors.dart — a small generated file that tokens.dart imports.
// NEVER overwrites tokens.dart directly so hand-crafted Palette/Ty/Sp/Rad/Mo
// classes are not lost.
function hexToDartColor(hex) {
  return `Color(0xFF${hex.replace('#', '').toUpperCase()})`;
}

const dartOut = path.join(__dirname, '..', 'native', 'lib', 'ui', 'gen_colors.dart');

let dart = `// AUTO-GENERATED FROM tokens.json — do not hand-edit.
// Regenerate with: node design/generate.js
// from the repo root.
import 'package:flutter/material.dart';

/// Flat color constants derived from design/tokens.json.
/// Use the runtime [Palette] (from tokens.dart) in widgets — these constants
/// are provided for reference and for any code that needs compile-time values.
class AppColors {
  // ── Dark theme ──────────────────────────────────────────────────────────────
`;

for (const [k, v] of Object.entries(tokens.colors.dark)) {
  const name = 'dark' + k.charAt(0).toUpperCase() + k.slice(1);
  dart += `  static const Color ${name} = ${hexToDartColor(v)};\n`;
}

dart += `\n  // ── Light theme ─────────────────────────────────────────────────────────────\n`;

for (const [k, v] of Object.entries(tokens.colors.light)) {
  const name = 'light' + k.charAt(0).toUpperCase() + k.slice(1);
  dart += `  static const Color ${name} = ${hexToDartColor(v)};\n`;
}

dart += `}\n\n`;

dart += `/// Typography constants derived from design/tokens.json.
class AppTypography {
  static const String displayFont = 'Newsreader';
  static const String sansFont    = 'Inter';
}
`;

fs.writeFileSync(dartOut, dart);
console.log(`Dart color constants written to: ${dartOut}`);
console.log('Done. tokens.dart was NOT modified — it imports gen_colors.dart.');
