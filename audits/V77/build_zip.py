"""Package the exact tested V77 delta, installer, guide and audit results."""
from pathlib import Path
import hashlib,json,zipfile,os
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
v=json.loads((ROOT/'manifest.json').read_text())['versions'][-1];assert v['id']=='V77'
start='''AVATAR CATALOG & GAMES — V77

1. Extraia este ZIP e abra AVATAR_PLAZA_V77.html no navegador.
2. Selecione V77. Base exigida: V76 completa.
3. Pare Play. Crie os cinco ModuleScripts novos em ReplicatedStorage, exatamente nos nomes indicados.
4. Substitua as 24 fontes existentes por inteiro, preservando tipos e locais.
5. Leia INSTALL_V77.md e reinicie Play depois de instalar os dois grupos.

198 cenários simulados; 180 fontes compiladas em Lua 5.4.
Roblox nativo e gameplay integral quadro a quadro permanecem pendentes.
Este pacote no GitHub não publica o place Roblox.
'''
files=['AVATAR_PLAZA_V77.html','INSTALL_V77.md']
files+=['audits/V77/'+n for n in ['README.md','RESEARCH.md','PROMPT_REVIEW.md','suite_results.json','syntax_results.json','sandbox_results.json','security_results.json','reference_ui_results.json','worlds_ai_results.json','board_ui_results.json','photo_controller_results.json','installer_logic_results.json','installer_browser_results.json','counter_results.json','visual_review.jpg']]
output=ROOT/'AVATAR_PLAZA_V77.zip';temporary=ROOT/('AVATAR_PLAZA_V77.build-'+str(os.getpid())+'.zip')
with zipfile.ZipFile(temporary,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
 z.writestr('00_COMECE_AQUI.txt',start)
 for p in files:z.write(ROOT/p,p)
 z.writestr('manifest_V77.json',json.dumps(v,ensure_ascii=False,indent=2)+'\n')
 for s in v['scripts']:z.write(ROOT/s['path'],s['path'])
with zipfile.ZipFile(temporary)as z:
 assert z.testzip()is None
 for s in v['scripts']:assert hashlib.sha256(z.read(s['path'])).hexdigest()==s['sha256']
 assert z.read('AVATAR_PLAZA_V77.html')==(ROOT/'AVATAR_PLAZA_V77.html').read_bytes()
temporary.replace(output)
print('ZIP verified:',output.stat().st_size,'bytes;',len(v['scripts']),'sources')
