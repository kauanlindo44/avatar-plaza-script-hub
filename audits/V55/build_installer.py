"""V55 delta over remote V54; same compact copy installer and exact metadata."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2]
BASE='71ecc10926b71518f8786fb13491a2daadcaf3d7'
SERVER_MODULES={'07M0_MUSIC_PREFS','09I1_ASSISTANT_ACCOUNTS','09I2_ASSISTANT_ENGINE','09I3_OUTFIT_BUILDER'}
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V55'];assert previous[-1]['id']=='V54'
 effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for path in sorted((ROOT/'scripts/V55').glob('*.lua')):
  name=path.stem;data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in effective:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  else:
   kind='LocalScript'if name.endswith('_CLIENT')else'Script'if name.endswith('_SERVER')else'ModuleScript'
   location='StarterPlayer > StarterPlayerScripts'if kind=='LocalScript'else'ServerScriptService'if kind=='Script'or name in SERVER_MODULES else'ReplicatedStorage'
   spec=dict(name=name,type=kind,location=location,action='CRIAR')
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==32 and sum(s['action']=='CRIAR'for s in specs)==14
 reports=[json.loads(p.read_text())for p in(ROOT/'audits/V55').glob('*_results.json')]
 cases=sum(len(r)for r in reports if isinstance(r,list));assert all(x['result']=='pass'for r in reports if isinstance(r,list)for x in r)
 note='Requer V54 completa. V55: 32 instalações = 18 SUBSTITUIÇÕES + 14 NOVOS. Pare Play. Crie primeiro os novos ModuleScripts nos locais indicados, depois os novos Scripts/LocalScripts e substitua os existentes. Não duplique nomes. (NOVO)/(SUBSTITUIR) não faz parte do nome. Cada fonte tem até 400 linhas. Não substitua 09A_SHOP_UI nem regras de jogos nesta versão. Guia: INSTALL_V55.md.'
 validation=f'{len(effective)+14} fontes efetivas com sintaxe Lua 5.4 válida; {cases} cenários simulados. Seis tamanhos de tela, recibos, expiração, convites, aplicação do gato com catálogo fechado, música e regras preservadas. Não houve execução no motor Roblox. TextGenerator, malhas/WrapLayers, áudio permitido e compras precisam de teste na experiência publicada.'
 version=dict(id='V55',title='HALLOWEEN + AVATAR IA + PHOTO MODE + MÚSICA — 18 SUBSTITUIÇÕES + 14 NOVOS',date='2026-10-10',
  summary='Itens equipados recuperados; aplicação de camadas no mapa independente do catálogo; comunidade 5×2 em deitado; decoração Halloween e Salem permanente. Assistente real via TextGenerator com enquete, looks, planos de 30 dias e convites sem senha; Photo Mode simplificado e música compacta com volume inicial 40%.',install_note=note,validation=validation,scripts=specs)
 m.update(latest='V55',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 base=next(v for v in previous if v['id']=='V44');sources={s['path']:(ROOT/s['path']).read_text()for v in[base,version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V55 e a instalação V44',html)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V55.html').write_text(html)
 intro='# Instalação V55 — 18 substituições + 14 NOVOS\n\n'+note+'\n\n'
 for title,action in [('Criar — 14 NOVOS','CRIAR'),('Substituir — 18 existentes','SUBSTITUIR')]:
  intro+='## '+title+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  intro+='\n'
 details=(ROOT/'audits/V55/INSTALL_DETAILS.md').read_text();(ROOT/'INSTALL_V55.md').write_text(intro+details)
 result=dict(version='V55',base_commit=BASE,items=32,replace=18,create=14,effective_sources=len(effective)+14,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V54 already installed')
 (ROOT/'audits/V55/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
