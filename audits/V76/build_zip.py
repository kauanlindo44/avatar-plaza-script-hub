"""Ship the verified installer, exact delta and honest audit coverage."""
from pathlib import Path
import hashlib,json,zipfile,os
ROOT=Path(__file__).resolve().parents[2]
v=json.loads((ROOT/'manifest.json').read_text())['versions'][-1];assert v['id']=='V76'
start='''AVATAR CATALOG & GAMES — V76

1. Extraia este ZIP e abra AVATAR_PLAZA_V76.html no navegador.
2. Selecione V76. Base exigida: V75 completa.
3. Pare Play. Crie os 2 ModuleScripts novos nos locais indicados:
   07G10_HUD_LAYOUT em ReplicatedStorage;
   09I26_REQUEST_GUARD em ServerScriptService.
4. Substitua as 12 fontes existentes por inteiro, mantendo nomes/tipos/locais.
5. Leia INSTALL_V76.md; reinicie Play depois dos dois grupos.

190 cenários simulados; 175 fontes compiladas. Testes nativos pendentes.
20 referências de vídeos identificadas; revisão audiovisual integral pendente.
Consulte audits/V76/PROMPT_REVIEW.md para a cobertura exata do pedido.
'''
files=['AVATAR_PLAZA_V76.html','INSTALL_V76.md']
files+=['audits/V76/'+n for n in ['README.md','RESEARCH.md','PROMPT_REVIEW.md','video_references.json','video_minutes.csv','suite_results.json','syntax_results.json','sandbox_results.json','security_results.json','v76_results.json','installer_logic_results.json','installer_browser_results.json']]
output=ROOT/'AVATAR_PLAZA_V76.zip'
temporary=ROOT/('AVATAR_PLAZA_V76.build-'+str(os.getpid())+'.zip')
with zipfile.ZipFile(temporary,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
 z.writestr('00_COMECE_AQUI.txt',start)
 for p in files:z.write(ROOT/p,p)
 z.writestr('manifest_V76.json',json.dumps(v,ensure_ascii=False,indent=2)+'\n')
 for s in v['scripts']:z.write(ROOT/s['path'],s['path'])
with zipfile.ZipFile(temporary)as z:
 assert z.testzip()is None
 for s in v['scripts']:assert hashlib.sha256(z.read(s['path'])).hexdigest()==s['sha256']
 assert z.read('AVATAR_PLAZA_V76.html')==(ROOT/'AVATAR_PLAZA_V76.html').read_bytes()
temporary.replace(output)
print('ZIP verified:',output.stat().st_size,'bytes;',len(v['scripts']),'sources')
