"""Run the functional suites and retain individual exit codes; fail on any error."""
from pathlib import Path
import json,subprocess,sys
HERE=Path(__file__).resolve().parent
names=['test_fixes.py','test_interface.py','test_regressions.py','test_delta.py','test_features.py','test_v67.py','test_v68.py','test_v69.py']
rows=[]
for name in names:
 p=subprocess.run([sys.executable,str(HERE/name)],capture_output=True,text=True)
 (HERE/(name.removesuffix('.py')+'.log')).write_text(p.stdout+p.stderr)
 rows.append(dict(suite=name,exit_code=p.returncode))
 print(name,'pass'if p.returncode==0 else'FAIL',flush=True)
 if p.returncode:print((p.stdout+p.stderr)[-3500:])
(HERE/'suite_results.json').write_text(json.dumps(rows,indent=2)+'\n')
sys.exit(1 if any(r['exit_code']for r in rows)else 0)
