"""Explicit V69 delta over verified V68; preserve all historical entries and sources."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='04e8d334850200827fe3a7e64a8db9ae6f6f4e71'
NEW={
 '07G8_VEGETATION_PLAN':('ModuleScript','ReplicatedStorage'),
 '07H10_MATCH_CHAT_UI':('ModuleScript','ReplicatedStorage'),
 '07H9_MATCH_CHAT':('ModuleScript','ServerScriptService'),
 '09I14_SOCIAL_ACTIVITIES':('ModuleScript','ServerScriptService'),
 '09I15_ACTIVITY_RULES':('ModuleScript','ReplicatedStorage'),
 '09I16_ACTIVITY_UI':('ModuleScript','ReplicatedStorage'),
 '09I17_REMIX_PERMISSIONS':('ModuleScript','ServerScriptService'),
 '09I19_REHEARSAL_CUES':('ModuleScript','ReplicatedStorage'),
 '09I_ACTIVITIES_CLIENT':('LocalScript','StarterPlayer > StarterPlayerScripts'),
 '09I_ACTIVITIES_SERVER':('Script','ServerScriptService')}
EXTERNAL={}
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V68'
 previous=baseline['versions'];effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V69').glob('*.lua')):
  name=p.stem;data=p.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in NEW:
   assert name not in effective;kind,location=NEW[name];spec=dict(name=name,type=kind,location=location,action='CRIAR')
  else:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==45 and sum(s['action']=='CRIAR'for s in specs)==10
 reports=[json.loads((HERE/p).read_text())for p in ['fix_results.json','interface_results.json','regression_results.json','delta_results.json','feature_results.json','v67_results.json','v68_results.json','v69_results.json']]
 cases=sum(map(len,reports));assert cases==126 and all(c['result']=='pass'for r in reports for c in r)
 note='Requer V68 completa. V69: 10 scripts NOVOS + 35 SUBSTITUIÇÕES. Pare Play. Crie primeiro os oito ModuleScripts novos; depois o Script e o LocalScript novos e as substituições. Reinicie somente após terminar o conjunto. NOVO/SUBSTITUIR não fazem parte do nome. Nenhum produto, passe, chave externa ou upload novo. Guia: INSTALL_V69.md.'
 version=dict(id='V69',title='PRAÇA RENOVADA, CONVERSAS PRIVADAS E CRIAÇÃO EM GRUPO — 10 NOVOS / 35 SUBSTITUIÇÕES',date='2026-10-18',summary='Base clara, verde e cores pontuais em HUD, catálogo, looks, assistente, música, configurações, photo mode, patrocínio e jogos. Truco com feltro verde e madeira clara; xadrez/damas com tabuleiro creme e verde e animação independente da partida. Vegetação em agrupamentos planejados, clareiras, silhuetas e materiais nativos variados. Conversa própria por partida via TextChatService e participantes definidos pelo servidor. Look em colaboração, duplas com personalidade, ensaio temático e remix com autorização persistente, revogação e autoria original. Criação assistida pelo montador existente, sem serviço externo pago. Regras e produtos preservados.',install_note=note,validation='126 cenários simulados em Lua 5.4; 146 fontes efetivas compiladas; sete geometrias de tela/teclado; inspeção de layouts extraídos das interfaces; hashes/históricos/dependências e JavaScript real de cópia/offline do instalador. Sem motor Roblox: renderização, filtragem/permissões, física e serviços reais precisam de teste publicado.',scripts=specs)
 prior=datetime.fromisoformat(json.loads((ROOT/'manifest.json').read_text())['updated_at'])
 m=dict(baseline);m.update(latest='V69',updated_at=max(datetime.now(timezone.utc),datetime(2026,10,18,tzinfo=timezone.utc),prior+timedelta(seconds=1)).isoformat(timespec='seconds'),versions=previous+[version])
 (ROOT/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in {'V44','V55','V56','V57','V58','V59','V60','V61','V62','V63','V64','V65','V66','V67','V68','V69'}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
 html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 meta='<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. V69: 10 NOVOS + 35 SUBSTITUIÇÕES; requer V68 completa. Código recolhido, copiar fonte inteira e última linha. Inclui V68 e versões anteriores para uso sem conexão; consulta atualizações no GitHub. O 09A_SHOP_UI permanece nas quatro partes anteriores.</div>'
 html=re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>',meta,html,count=1)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V69.html').write_text(html)
 intro='# Instalação V69 — 10 novos + 35 substituições\n\n'+note+'\n\n'
 for action,heading in [('CRIAR','Criar primeiro — NOVOS'),('SUBSTITUIR','Substituir nas instâncias existentes')]:
  intro+='## '+heading+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  intro+='\n'
 (ROOT/'INSTALL_V69.md').write_text(intro+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version='V69',base_commit=BASE,items=45,replace=35,create=10,effective_sources=len(effective)+len(NEW),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V68 already installed')
 (HERE/'package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
