import { useState } from 'react';
import { db } from './db';

declare const JSZip: any;

export default function ExportModal({ onClose }: { onClose: () => void }) {
  const [format, setFormat] = useState('markdown');
  const [exporting, setExporting] = useState(false);

  const handleExport = async () => {
    setExporting(true);
    try {
      const journals = await db.journalEntries.toArray();
      const issues = await db.issues.toArray();
      const cores = await db.corePoints.toArray();
      
      const dateStr = new Date().toISOString().split('T')[0];
      
      if (format === 'json') {
        const data = { journals, issues, cores };
        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `daybefore-export-${dateStr}.json`;
        a.click();
      } else if (format === 'pdf') {
        // Simple PDF print hack
        const printWin = window.open('', '_blank');
        if (!printWin) return;
        let html = `<html><head><title>Day Before, exported ${dateStr}</title>
          <style>
            body { font-family: Georgia, serif; max-width: 800px; margin: 0 auto; padding: 40px; line-height: 1.6; }
            h1 { font-size: 24px; border-bottom: 1px solid #ccc; padding-bottom: 10px; page-break-after: avoid; }
            h2 { font-size: 20px; margin-top: 30px; page-break-after: avoid; }
            .entry { margin-bottom: 30px; page-break-inside: avoid; }
            .date { color: #666; font-size: 14px; margin-bottom: 10px; }
            .content { white-space: pre-wrap; }
          </style>
        </head><body>`;
        html += `<h1>Day Before, exported ${dateStr}</h1>`;
        
        journals.sort((a,b) => a.createdAt - b.createdAt).forEach(j => {
           html += `<div class="entry"><div class="date">${new Date(j.createdAt).toLocaleDateString()}</div><div class="content">${j.content}</div></div>`;
        });
        
        html += `<h1>Issues</h1>`;
        issues.forEach(i => {
           html += `<div class="entry"><h2>${i.name}</h2><div class="content">${i.content || ''}</div></div>`;
        });
        
        html += `<h1>Core Points</h1>`;
        cores.forEach(c => {
           html += `<div class="entry"><h2>${c.name}</h2><div class="content">${c.content || ''}</div></div>`;
        });
        
        html += `</body><script>window.onload = function() { window.print(); window.close(); }</script></html>`;
        printWin.document.write(html);
        printWin.document.close();
      } else if (format === 'markdown') {
        const zip = new JSZip();
        zip.file("README.md", "# Day Before Export\n\nExported on " + dateStr);
        
        const jFolder = zip.folder("journal");
        journals.forEach(j => {
          const d = new Date(j.createdAt);
          const fname = `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2,'0')}-${d.getDate().toString().padStart(2,'0')}-${j.id}.md`;
          const content = `---\ndate: ${d.toISOString()}\ncreated: ${d.toISOString()}\nupdated: ${new Date(j.updatedAt).toISOString()}\n---\n\n${j.content}`;
          jFolder.file(fname, content);
        });
        
        const iFolder = zip.folder("issues");
        issues.forEach(i => {
          iFolder.file(`${i.name.replace(/[^a-z0-9]/gi, '_').toLowerCase() || i.id}.md`, `# ${i.name}\n\n${i.content || ''}`);
        });
        
        let coreContent = "# Core Points\n\n";
        cores.forEach(c => {
          coreContent += `## ${c.name}\n\n${c.content || ''}\n\n`;
        });
        zip.file("core-points.md", coreContent);
        
        const blob = await zip.generateAsync({type:"blob"});
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `daybefore-export-${dateStr}.zip`;
        a.click();
      }
    } catch (e) {
      console.error(e);
      alert('Export failed');
    }
    setExporting(false);
    onClose();
  };

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(0,0,0,0.8)', zIndex: 9999,
      display: 'flex', alignItems: 'center', justifyContent: 'center'
    }}>
      <div style={{
        background: 'var(--color-ground, var(--bg-color))',
        border: '1px solid var(--color-hairline, var(--divider))',
        padding: '32px', borderRadius: '8px', maxWidth: '400px', width: '100%'
      }}>
        <h2 style={{marginTop: 0, marginBottom: '24px'}}>Export your entries</h2>
        <p style={{color: 'var(--text-secondary)', marginBottom: '24px', fontSize: '0.9rem'}}>
          Everything is decrypted on this device and saved as files. Nothing is uploaded.
        </p>
        
        <div style={{display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '32px'}}>
          <label style={{display: 'flex', gap: '12px', cursor: 'pointer'}}>
            <input type="radio" name="format" value="markdown" checked={format === 'markdown'} onChange={() => setFormat('markdown')} />
            <div>
              <div style={{fontWeight: 'bold'}}>Markdown (recommended)</div>
              <div style={{fontSize: '0.8rem', color: 'var(--text-secondary)'}}>One file per entry, in a zip. Opens in Obsidian, Notion and any text editor.</div>
            </div>
          </label>
          <label style={{display: 'flex', gap: '12px', cursor: 'pointer'}}>
            <input type="radio" name="format" value="pdf" checked={format === 'pdf'} onChange={() => setFormat('pdf')} />
            <div>
              <div style={{fontWeight: 'bold'}}>PDF</div>
              <div style={{fontSize: '0.8rem', color: 'var(--text-secondary)'}}>One readable document of all your entries.</div>
            </div>
          </label>
          <label style={{display: 'flex', gap: '12px', cursor: 'pointer'}}>
            <input type="radio" name="format" value="json" checked={format === 'json'} onChange={() => setFormat('json')} />
            <div>
              <div style={{fontWeight: 'bold'}}>JSON</div>
              <div style={{fontSize: '0.8rem', color: 'var(--text-secondary)'}}>A complete backup, including every revision of every issue.</div>
            </div>
          </label>
        </div>
        
        <div style={{display: 'flex', justifyContent: 'flex-end', gap: '16px'}}>
          <button onClick={onClose} className="text-btn">Cancel</button>
          <button 
            onClick={handleExport}
            disabled={exporting}
            style={{
              background: 'var(--text-primary)', color: 'var(--color-ground, var(--bg-color))',
              padding: '8px 16px', borderRadius: '4px', border: 'none', cursor: 'pointer'
            }}
          >
            {exporting ? 'Exporting...' : 'Export'}
          </button>
        </div>
      </div>
    </div>
  );
}
