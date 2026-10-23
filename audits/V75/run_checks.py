"""Run source-executing regression suites in separate restricted Lua test processes."""
from pathlib import Path
import json,subprocess,sys
HERE=Path(__file__).resolve().parent
names=['test_fixes.py','test_interface.py','test_regressions.py','test_features.py','test_v67.py','test_v68.py','test_v69.py','test_v72.py','test_v73.py','test_chaos.py','test_v74_ui.py','test_v75.py']
rows=[]
for name in names:
 p=subprocess.run([sys.executable,str(HERE/name)],capture_output=True,text=True,timeout=65)
 (HERE/(name.removesuffix('.py')+'.log')).write_text(p.stdout+p.stderr)
 rows.append(dict(suite=name,exit_code=p.returncode,cases=p.stdout.count('PASS ')))
 print(name,'PASS'if p.returncode==0 else'FAIL',p.stdout.count('PASS '),flush=True)
 if p.returncode:print((p.stdout+p.stderr)[-2000:],flush=True)
(HERE/'suite_results.json').write_text(json.dumps(rows,indent=2)+'\n')
sys.exit(1 if any(r['exit_code']for r in rows)else 0)
