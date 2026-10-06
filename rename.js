const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        if (file === 'node_modules' || file === 'dist' || file.startsWith('.')) return;
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            results.push(file);
        }
    });
    return results;
}

const files = walk('C:\\Users\\WASBERRY\\.gemini\\antigravity\\scratch\\dayahead');
files.forEach(f => {
    if (!f.match(/\.(ts|tsx|md|json|html|toml|css|sql)$/)) return;
    let content = fs.readFileSync(f, 'utf8');
    let orig = content;
    
    content = content.replace(/Day Ahead/g, 'Day Before');
    content = content.replace(/dayahead\.com/g, 'daybefore.app');
    content = content.replace(/dayahead/g, 'daybefore');
    content = content.replace(/DayAhead/g, 'DayBefore');
    
    // Naming reasoning update in NAMING.md
    if (f.endsWith('NAMING.md')) {
        content = content.replace(/forward-looking rather than backward-looking/gi, 'backward-looking rather than forward-looking');
        content = content.replace(/a journal where you process today while turning toward tomorrow/gi, 'a journal where you process yesterday while turning toward today');
        content = content.replace(/"open your Day Ahead"/gi, '"open your Day Before"');
    }
    
    if (content !== orig) {
        fs.writeFileSync(f, content, 'utf8');
        console.log(`Updated ${f}`);
    }
});
