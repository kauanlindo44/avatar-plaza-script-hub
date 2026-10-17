"""Explicit V68 delta based on the verified published V67; historical sources immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='1d79070d8dd4f120ac0a92c96398d4e8d6a3c409'
NEW={'08B8_ACCESSORY_REFINEMENT':('ModuleScript','ReplicatedStorage'),'09C15_AVATAR_TOOLS':('ModuleScript','ReplicatedStorage'),'09C16_CATALOG_HOME':('ModuleScript','ReplicatedStorage'),'09I12_REQUEST_PLAN':('ModuleScript','ReplicatedStorage'),'09I13_OUTFIT_SEARCH':('ModuleScript','ServerScriptService')}
EXTERNAL={}
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V67';previous=baseline['versions'];effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V68').glob('*.lua')):
  name=p.stem;data=p.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in NEW:
   assert name not in effective;kind,location=NEW[name];spec=dict(name=name,type=kind,location=location,action='CRIAR')
  else:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==37 and sum(s['action']=='CRIAR'for s in specs)==5
 reports=[json.loads((HERE/p).read_text())for p in ['fix_results.json','interface_results.json','regression_results.json','delta_results.json','feature_results.json','v67_results.json','v68_results.json']];cases=sum(map(len,reports));assert cases==106 and all(c['result']=='pass'for r in reports for c in r)
 note='Requer V67 completa. V68: 5 ModuleScripts NOVOS + 32 SUBSTITUIÇÕES. Pare Play. Crie primeiro os módulos da tabela; depois substitua as fontes completas e reinicie. NOVO/SUBSTITUIR não fazem parte do nome. Nenhum passe, produto, chave externa ou asset para enviar ao Roblox novo. Guia: INSTALL_V68.md.'
 version=dict(id='V68',title='NOVO ESTÚDIO, CATÁLOGO E TRUCO — 5 NOVOS / 32 SUBSTITUIÇÕES',date='2026-10-17',summary='Pedido atual e confirmação editável comandam a IA. Montador prioriza roupas completas, pagina a pesquisa, respeita cor/exclusões/orçamento e tenta outras combinações após recusa ou mudança de preço. Guarda as últimas combinações com gravação agrupada para variar entre pedidos. Menu lateral realmente recolhível no computador e formulário renovado. Catálogo começa em categorias, preserva os itens abaixo da prévia e usa cenário grafite fixo; ferramentas de desfazer/refazer/comparar, favoritos persistentes, importação e ajuste nativo de acessórios. Truco com mesa oval, retratos circulares, mão em leque, placar lateral e ações contextuais. Photo Mode corrige espaço disponível, recolhe ferramentas e pausa emotes na cópia. Praça clássica quadriculada, árvores mais próximas, novo chão neutro e aventura separada. HUD/configurações mais contidos, acabamento de patrocínio e integração segura.',install_note=note,validation='106 cenários simulados em Lua 5.4; 136 fontes efetivas compiladas; históricos/hashes/dependências e JavaScript real de cópia/offline do instalador. Sem motor Roblox nativo: renderização, física, FPS e permissões reais precisam de teste publicado.',scripts=specs)
 prior=datetime.fromisoformat(json.loads((ROOT/'manifest.json').read_text())['updated_at']);m=dict(baseline);m.update(latest='V68',updated_at=max(datetime.now(timezone.utc),datetime(2026,10,17,tzinfo=timezone.utc),prior+timedelta(seconds=1)).isoformat(timespec='seconds'),versions=previous+[version]);(ROOT/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in {'V44','V55','V56','V57','V58','V59','V60','V61','V62','V63','V64','V65','V66','V67','V68'}];sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text();constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 meta='<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. V68: 5 NOVOS + 32 SUBSTITUIÇÕES; requer V67 completa. Código recolhido, copiar fonte inteira e última linha. O arquivo também inclui V67 e as versões anteriores para uso sem conexão; consulta atualizações no GitHub. O 09A_SHOP_UI permanece nas quatro partes anteriores.</div>'
 html=re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>',meta,html,count=1);hp.write_text(html);(ROOT/'AVATAR_PLAZA_V68.html').write_text(html)
 intro='# Instalação V68 — 5 novos + 32 substituições\n\n'+note+'\n\n'
 for action,heading in [('CRIAR','Criar primeiro — NOVOS'),('SUBSTITUIR','Substituir nas instâncias existentes')]:
  intro+='## '+heading+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  intro+='\n'
 (ROOT/'INSTALL_V68.md').write_text(intro+(HERE/'INSTALL_DETAILS.md').read_text());result=dict(version='V68',base_commit=BASE,items=37,replace=32,create=5,effective_sources=len(effective)+len(NEW),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V67 already installed');(HERE/'package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
