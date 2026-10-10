"""V56 delta over remote V55; same compact copy installer and exact metadata."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2]
BASE='dce69725a36e62a8ca371bd9824aa6308c4287cf'
SERVER_MODULES={'07M0_MUSIC_PREFS','09I1_ASSISTANT_ACCOUNTS','09I2_ASSISTANT_ENGINE','09I3_OUTFIT_BUILDER'}
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V56'];assert previous[-1]['id']=='V55'
 effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for path in sorted((ROOT/'scripts/V56').glob('*.lua')):
  name=path.stem;data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in effective:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  else:
   kind='LocalScript'if name.endswith('_CLIENT')or name=='09C12_AVATAR_FEEDBACK'else'Script'if name.endswith('_SERVER')else'ModuleScript'
   location='StarterPlayer > StarterPlayerScripts'if kind=='LocalScript'else'ServerScriptService'if kind=='Script'or name in SERVER_MODULES else'ReplicatedStorage'
   spec=dict(name=name,type=kind,location=location,action='CRIAR')
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==32 and sum(s['action']=='CRIAR'for s in specs)==4
 reports=[json.loads(p.read_text())for p in(ROOT/'audits/V56').glob('*_results.json')]
 cases=sum(len(r)for r in reports if isinstance(r,list));assert all(x['result']=='pass'for r in reports if isinstance(r,list)for x in r)
 note='Requer V55 completa. Desative 07M_PLAZA_MUSIC se ele estiver instalado: 07M_MUSIC_CLIENT será o único controlador de música. V56: 32 instalações = 28 SUBSTITUIÇÕES + 4 NOVOS. Pare Play. Crie primeiro os novos ModuleScripts nos locais indicados, depois os novos Scripts/LocalScripts e substitua os existentes. Não duplique nomes. (NOVO)/(SUBSTITUIR) não faz parte do nome. Cada fonte tem até 400 linhas. Não substitua 09A_SHOP_UI nem regras de jogos nesta versão. Guia: INSTALL_V56.md.'
 validation=f'{len(effective)+4} fontes efetivas com sintaxe Lua 5.4 válida; {cases} cenários simulados. Seis tamanhos de tela; cenários fixos, erro nativo por etapa, confirmação separada servidor/cliente, chat/looks/itens, áudio legado, compras e regras. Não houve execução no motor Roblox. Renderização de roupas 3D, TextGenerator, áudio e compras ainda precisam de teste na experiência publicada.'
 version=dict(id='V56',title='ESTÚDIO FIXO + HALLOWEEN + IA + DIAGNÓSTICO 3D — 28 SUBSTITUIÇÕES + 4 NOVOS',date='2026-10-10',
  summary='Photo Mode com seis salas locais de blocos, avatar independente do fundo e controle separado da câmera. Tema Halloween compartilhado em HUD, menus e janelas; IA com conversa e looks no mesmo fluxo, música menor sem áudio duplicado, Salem com arte de abóboras. Aplicação do avatar distingue criação, roupa 3D, mapa e conteúdo no cliente, com código/erro original no Output.',install_note=note,validation=validation,scripts=specs)
 m.update(latest='V56',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 base=next(v for v in previous if v['id']=='V44');sources={s['path']:(ROOT/s['path']).read_text()for v in[base,previous[-1],version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,previous[-1],version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V56, V55 e a instalação V44',html)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V56.html').write_text(html)
 intro='# Instalação V56 — 28 substituições + 4 NOVOS\n\n'+note+'\n\n'
 for title,action in [('Criar — 4 NOVOS','CRIAR'),('Substituir — 28 existentes','SUBSTITUIR')]:
  intro+='## '+title+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  intro+='\n'
 details=(ROOT/'audits/V56/INSTALL_DETAILS.md').read_text();(ROOT/'INSTALL_V56.md').write_text(intro+details)
 result=dict(version='V56',base_commit=BASE,items=32,replace=28,create=4,effective_sources=len(effective)+4,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V55 already installed')
 (ROOT/'audits/V56/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
