const fs = require('fs');
const path = require('path');

const tokens = JSON.parse(fs.readFileSync(path.join(__dirname, 'tokens.json'), 'utf8'));

// Generate CSS
let css = `/* AUTO-GENERATED FROM tokens.json */\n\n:root {\n`;
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

fs.writeFileSync('D:/daybefore-web/app/src/tokens.css', css);


// Generate Dart
function hexToDartColor(hex) {
    return `Color(0xFF${hex.replace('#', '').toUpperCase()})`;
}

let dart = `// AUTO-GENERATED FROM tokens.json
import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme
${Object.entries(tokens.colors.dark).map(([k, v]) => `  static const Color dark${k.charAt(0).toUpperCase() + k.slice(1)} = ${hexToDartColor(v)};`).join('\n')}

  // Light Theme
${Object.entries(tokens.colors.light).map(([k, v]) => `  static const Color light${k.charAt(0).toUpperCase() + k.slice(1)} = ${hexToDartColor(v)};`).join('\n')}
}

class AppTypography {
  static const String displayFont = 'Newsreader';
  static const String sansFont = 'Inter';
}
`;

fs.writeFileSync(path.join(__dirname, '..', 'native', 'lib', 'ui', 'tokens.dart'), dart);
console.log('Tokens generated successfully!');
