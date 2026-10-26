"""Run source-executing regression suites in separate restricted Lua test processes."""
from pathlib import Path
import json,subprocess,sys,hashlib
HERE=Path(__file__).resolve().parent
names=['test_fixes.py','test_interface.py','test_regressions.py','test_features.py','test_v67.py','test_v68.py','test_v69.py','test_v72.py','test_v73.py','test_chaos.py','test_v74_ui.py','test_v75.py','test_photo_controller.py','test_reference_ui.py','test_worlds_ai.py','test_board_ui.py','test_security.py','test_functional_repair.py']
rows=[]
for name in names:
 p=subprocess.run([sys.executable,str(HERE/name)],capture_output=True,text=True,timeout=65)
 (HERE/(name.removesuffix('.py')+'.log')).write_text(p.stdout+p.stderr)
 rows.append(dict(suite=name,exit_code=p.returncode,cases=p.stdout.count('PASS ')))
 print(name,'PASS'if p.returncode==0 else'FAIL',p.stdout.count('PASS '),flush=True)
 if p.returncode:print((p.stdout+p.stderr)[-2000:],flush=True)
(HERE/'suite_results.json').write_text(json.dumps(rows,indent=2)+'\n')
failed=any(r['exit_code']for r in rows)
checkpoint=HERE/'tested_sources.json'
if failed:
 if checkpoint.exists():checkpoint.unlink()
else:
 base=json.loads((HERE/'base_manifest.json').read_text());root=HERE.parents[1]
 effective={s['name']:s['path']for v in base['versions']for s in v['scripts']}
 for source in (root/'scripts/V78').glob('*.lua'):effective[source.stem]=source.relative_to(root).as_posix()
 checkpoint.write_text(json.dumps({path:hashlib.sha256((root/path).read_bytes()).hexdigest()for path in effective.values()},indent=2)+'\n')
sys.exit(1 if failed else 0)
