"""V71 delta based on V69, preserving the separately published V70; preserve all historical entries and sources."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='16e26bac39034c899869f61fc641d036e1269721'
PUBLISHED='1425aaae231906c222ce3d0fc2d119a9c76e74fe'
NEW={'09I20_ASSISTANT_APPEARANCE':('ModuleScript','ReplicatedStorage')}
EXTERNAL={}
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V69';published=json.loads((HERE/'published_manifest.json').read_text());assert published['latest']=='V70'
 previous=published['versions'];effective={s['name']:s for v in baseline['versions'] for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V71').glob('*.lua')):
  name=p.stem;data=p.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in NEW:
   assert name not in effective;kind,location=NEW[name];spec=dict(name=name,type=kind,location=location,action='CRIAR')
  else:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==32 and sum(s['action']=='CRIAR'for s in specs)==1
 reports=[json.loads((HERE/p).read_text())for p in ['fix_results.json','interface_results.json','regression_results.json','delta_results.json','feature_results.json','v67_results.json','v68_results.json','v69_results.json','v71_results.json']]
 cases=sum(map(len,reports));assert cases==134 and all(c['result']=='pass'for r in reports for c in r)
 note='Base: V69 completa, por pedido do responsável. A V70 NÃO é necessária. V71: 1 ModuleScript NOVO + 31 SUBSTITUIÇÕES. Pare Play, crie primeiro o módulo novo, substitua as fontes completas e reinicie após terminar. NOVO/SUBSTITUIR não fazem parte do nome. Nenhum produto, passe, chave ou upload novo. Guia: INSTALL_V71.md.'
 version=dict(id='V71',base_version='V69',title='CATÁLOGO EM MOSAICO, IA AMPLA E MÚSICA COMPACTA — BASE V69',date='2026-10-19',summary='Parte diretamente da V69. Catálogo/HUD grafite com mosaico de categorias coloridas e prévia fixa; praça clássica neutra. Xadrez verde/creme, damas vermelhas/escuras com acabamento tradicional. Assistente claro com trilho estreito, histórico recolhível, conversa ampla, compositor central e pedido em três etapas. Montador prioriza combinação textual entre as peças. Vitrines renovam mídia a cada 15 minutos sem alterar publicação de 24 h. Player de música compacto, biblioteca expansível e bossa/lounge inicial com fallback. Regras, contas, recibos e atividades anteriores preservados; V70 só no histórico.',install_note=note,validation='134 cenários simulados em Lua 5.4; 147 fontes efetivas compiladas, sete geometrias de tela/teclado, inspeção geométrica de layouts e JavaScript real do instalador. Sem motor Roblox: renderização, física, áudio e propagação/permissões reais de assets exigem teste publicado.',scripts=specs)
 prior=datetime.fromisoformat(json.loads((ROOT/'manifest.json').read_text())['updated_at'])
 m=dict(published);m.update(latest='V71',updated_at=max(datetime.now(timezone.utc),datetime(2026,10,19,tzinfo=timezone.utc),prior+timedelta(seconds=1)).isoformat(timespec='seconds'),versions=previous+[version])
 (ROOT/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in {'V44','V55','V56','V57','V58','V59','V60','V61','V62','V63','V64','V65','V66','V67','V68','V69','V70','V71'}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
 html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 meta='<div class="meta">V71: base V69 completa, sem precisar instalar V70. 1 NOVO + 31 SUBSTITUIÇÕES. Copiar fonte inteira, nome/tipo/local e última linha. Fontes históricas preservadas e consulta de atualizações no GitHub. 09A_SHOP_UI permanece nas quatro partes anteriores.</div>'
 html=re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>',meta,html,count=1)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V71.html').write_text(html)
 intro='# Instalação V71 — 1 novo + 31 substituições\n\n'+note+'\n\n'
 for action,heading in [('CRIAR','Criar primeiro — NOVOS'),('SUBSTITUIR','Substituir nas instâncias existentes')]:
  intro+='## '+heading+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  intro+='\n'
 (ROOT/'INSTALL_V71.md').write_text(intro+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version='V71',base_version='V69',base_commit=BASE,published_parent=PUBLISHED,items=32,replace=31,create=1,effective_sources=len(effective)+len(NEW),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V69; V70 not required')
 (HERE/'package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
