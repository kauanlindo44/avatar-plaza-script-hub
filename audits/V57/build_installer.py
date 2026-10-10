"""Seven-script V57 correction over the published V56. Historical scripts remain immutable."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
BASE='753693692bde6760da0356982e12c08e885aefa2'
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V57'];assert previous[-1]['id']=='V56'
 effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for path in sorted((ROOT/'scripts/V57').glob('*.lua')):
  name=path.stem;data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  assert name in effective;spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name
  spec.update(action='SUBSTITUIR',path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['type']!='ModuleScript',s['name']))
 assert len(specs)==7 and all(s['action']=='SUBSTITUIR'for s in specs)
 reports=[json.loads(p.read_text())for p in(ROOT/'audits/V57').glob('*_results.json')]
 cases=sum(len(r)for r in reports if isinstance(r,list));assert all(x['result']=='pass'for r in reports if isinstance(r,list)for x in r)
 note='Requer V56 completa. V57: somente 7 SUBSTITUIÇÕES e nenhum NOVO. Pare Play, substitua as fontes completas nos locais indicados e reinicie Play. Não duplique scripts. Mantenha 09C4_OUTFIT_LIBRARY da V55 já instalada; não existe substituição V56/V57 desse módulo. Guia: INSTALL_V57.md.'
 version=dict(id='V57',title='CORREÇÃO DO CABELO + CARRINHO + DIAGNÓSTICO POR ITEM — 7 SUBSTITUIÇÕES',date='2026-10-10',
  summary='Cliente aceita o carrinho V55 fornecido. Cabelo rígido usa a classificação nativa aplicada e pode ter Part/SpecialMesh sem WrapLayer; roupa 3D mantém validação de instância exata, malha, camada e corpo. Erro informa ID/tipo/requisito e separa validação do jogo, erro de script, erro nativo, conteúdo e configuração.',install_note=note,
  validation=f'{len(effective)} fontes efetivas com sintaxe Lua 5.4 válida; {cases} cenários simulados. Cliente real do catálogo/carrinho, roupa em camadas com cabelo rígido corrigido, diagnóstico cliente/servidor, rollback, prévias e Photo Mode. Não houve execução no motor Roblox ou confirmação visual do gato no mapa publicado.',scripts=specs)
 m.update(latest='V57',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 base=next(v for v in previous if v['id']=='V44');v55=next(v for v in previous if v['id']=='V55');embedded=[base,v55,previous[-1],version]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=html.replace('inclui a V56, V55 e a instalação V44','inclui a V57, V56, V55 e a instalação V44')
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V57.html').write_text(html)
 intro='# Instalação V57 — apenas 7 substituições, nenhum NOVO\n\n'+note+'\n\n## Substituir estes 7 scripts\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
 for s in specs:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
 details=(ROOT/'audits/V57/INSTALL_DETAILS.md').read_text();(ROOT/'INSTALL_V57.md').write_text(intro+'\n'+details)
 result=dict(version='V57',base_commit=BASE,items=7,replace=7,create=0,effective_sources=len(effective),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V56 already installed')
 (ROOT/'audits/V57/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
