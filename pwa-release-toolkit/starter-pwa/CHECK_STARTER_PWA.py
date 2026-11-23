"""Read-only project-file validator for a simple static PWA (Python 3.9+)."""
import json
from pathlib import Path
from sys import argv

root = Path(argv[1]).expanduser().resolve() if len(argv) > 1 else Path(__file__).resolve().parent
print("Checking:", root)
checks = []
for name in ("index.html", "manifest.webmanifest", "sw.js"):
    checks.append((name, (root / name).is_file()))
try:
    m = json.loads((root / 'manifest.webmanifest').read_text(encoding='utf-8'))
    checks.append(("manifest has app name", bool(m.get('name'))))
    checks.append(("manifest start_url", bool(m.get('start_url'))))
    for icon in m.get('icons', []):
        src = icon.get('src', '').removeprefix('./')
        if src.startswith('/') or '..' in Path(src).parts or '://' in src:
            checks.append(("valid local icon path", False))
        else:
            checks.append((f"icon exists: {src}", (root / src).is_file()))
except (OSError,ValueError) as e:
    print('Manifest issue:', e)
    checks.append(('valid manifest JSON', False))
for label, ok in checks:
    print(('[PASS]' if ok else '[FAIL]'),label)
print(f"{sum(ok for _,ok in checks)}/{len(checks)} checks passed. This does not replace testing in a browser.")
raise SystemExit(0 if all(ok for _,ok in checks) else 1)
