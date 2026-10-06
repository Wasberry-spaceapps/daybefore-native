const fs = require('fs');
const iconSvg = <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <rect width="1024" height="1024" rx="224" fill="#17120D"/>
  <path d="M312 572A200 200 0 0 1 712 572Z" fill="#D4A25A"/>
  <rect x="232" y="572" width="560" height="28" rx="14" fill="#F2EEE6"/>
  <rect x="332" y="636" width="360" height="16" rx="8" fill="#6E6960"/>
</svg>;
const iconForegroundSvg = <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <g transform="translate(204.8, 204.8) scale(0.6)">
    <path d="M312 572A200 200 0 0 1 712 572Z" fill="#D4A25A"/>
    <rect x="232" y="572" width="560" height="28" rx="14" fill="#F2EEE6"/>
    <rect x="332" y="636" width="360" height="16" rx="8" fill="#6E6960"/>
  </g>
</svg>;
const symbolSvg = <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <path d="M312 572A200 200 0 0 1 712 572Z" fill="#D4A25A"/>
  <rect x="232" y="572" width="560" height="28" rx="14" fill="#F2EEE6"/>
  <rect x="332" y="636" width="360" height="16" rx="8" fill="#6E6960"/>
</svg>;
fs.writeFileSync('D:/daybefore-native/native/assets/icon/icon.svg', iconSvg);
fs.writeFileSync('D:/daybefore-native/native/assets/icon/icon_foreground.svg', iconForegroundSvg);
fs.writeFileSync('D:/daybefore-native/native/assets/brand/symbol.svg', symbolSvg);
