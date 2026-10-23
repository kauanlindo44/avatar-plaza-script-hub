"""Build a copyable installation package using exactly the current V75 source hashes."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
m=json.loads((ROOT/'manifest.json').read_text());v=m['versions'][-1];assert v['id']=='V75'
cases=sum(r['cases']for r in json.loads((ROOT/'audits/V75/suite_results.json').read_text()))
start=f'''AVATAR CATALOG & GAMES — V75

1. Extraia este ZIP.
2. Abra AVATAR_PLAZA_V75.html no navegador e selecione V75.
3. Com Play parado, crie os 2 ModuleScripts novos e substitua os 35 scripts indicados.
4. Use Copiar script inteiro. As duas partes pertencem a mesma instancia.
5. Leia INSTALL_V75.md para nomes, tipos e locais exatos. Base: V74 completa.

{cases} cenarios simulados passaram; isso nao substitui teste no Roblox.
Multiplayer, sons/permissoes, fisica do empurrao, toque e FPS precisam de teste nativo.
Pesquisa e limites de acesso aos videos: audits/V75/RESEARCH.md.
'''
files=['AVATAR_PLAZA_V75.html','INSTALL_V75.md','audits/V75/README.md','audits/V75/RESEARCH.md','audits/V75/HISTORY.md','audits/V75/suite_results.json','audits/V75/syntax_results.json','audits/V75/sandbox_results.json','audits/V75/installer_logic_results.json','audits/V75/installer_browser_results.json']
output=ROOT/'AVATAR_PLAZA_V75.zip'
with zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
 z.writestr('00_COMECE_AQUI.txt',start)
 for p in files:z.write(ROOT/p,p)
 z.writestr('manifest_V75.json',json.dumps(v,ensure_ascii=False,indent=2)+'\n')
 for s in v['scripts']:z.write(ROOT/s['path'],s['path'])
with zipfile.ZipFile(output)as z:
 assert z.testzip()is None
 for s in v['scripts']:assert hashlib.sha256(z.read(s['path'])).hexdigest()==s['sha256']
 assert z.read('AVATAR_PLAZA_V75.html')==(ROOT/'AVATAR_PLAZA_V75.html').read_bytes()
print('ZIP verified:',output.stat().st_size,'bytes;',len(v['scripts']),'sources')
