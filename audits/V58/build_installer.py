"""V58 patch over the published V57; historical sources remain immutable."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
BASE='b918b7d1baf28448855f97fdc00868e01e4704b2'
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V58'];assert previous[-1]['id']=='V57'
 effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for path in sorted((ROOT/'scripts/V58').glob('*.lua')):
  name=path.stem;data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in effective:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;action='SUBSTITUIR'
  else:
   assert name=='07UI_SLIDER';spec=dict(name=name,type='ModuleScript',location='ReplicatedStorage');action='CRIAR'
  spec.update(action=action,path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 assert len(specs)==27 and sum(s['action']=='CRIAR'for s in specs)==1
 reports=[json.loads(p.read_text())for p in(ROOT/'audits/V58').glob('*_results.json')if p.name!='syntax_results.json']
 cases=sum(len(r)for r in reports if isinstance(r,list));assert cases==76
 assert all(x['result']=='pass'for r in reports if isinstance(r,list)for x in r)
 note='Requer V57 completa. V58: 26 SUBSTITUIÇÕES + 1 NOVO: 07UI_SLIDER (ModuleScript em ReplicatedStorage). Pare Play, crie esse módulo primeiro, substitua as fontes completas nos locais indicados e reinicie Play. Não duplique scripts. Guia: INSTALL_V58.md.'
 version=dict(id='V58',title='IA NATIVA + MÚSICA + PHOTO MODE + HALLOWEEN — 26 SUBSTITUIÇÕES + 1 NOVO',date='2026-10-11',
  summary='IA Roblox com chamada mínima, recuperação e diagnóstico; conversa ampla, perfil simples, música compacta com barras/fila, carrinho explícito, categoria Halloween, truco com cartas menores e autoria, dez fundos locais e movimentos para vídeo. Roupa replicada usa o ID da instância confirmada pelo servidor mantendo validação física.',install_note=note,
  validation='98 fontes efetivas com sintaxe válida; 76 cenários simulados. Geometria em seis tamanhos de tela, cliente real de música/catálogo/Photo Mode, falhas nativas e recuperação da IA, armazenamento indisponível, roupas replicadas, regras e rollback. Não houve execução no motor Roblox ou confirmação visual do gato no mapa publicado.',scripts=specs)
 m.update(latest='V58',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in{'V44','V55','V56','V57','V58'}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>','<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. O 09A_SHOP_UI aparece somente em 4 partes.</div>',html,count=1)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V58.html').write_text(html)
 intro='# Instalação V58 — 26 substituições + 1 NOVO\n\n'+note+'\n\n## Criar primeiro\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
 for s in specs:
  if s['action']=='CRIAR':intro+='| `'+s['name']+'` **(NOVO)** | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
 intro+='\n## Substituir estes 26 scripts\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
 for s in specs:
  if s['action']=='SUBSTITUIR':intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
 (ROOT/'INSTALL_V58.md').write_text(intro+'\n'+(ROOT/'audits/V58/INSTALL_DETAILS.md').read_text())
 result=dict(version='V58',base_commit=BASE,items=27,replace=26,create=1,effective_sources=len(set(effective)|{s['name']for s in specs}),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V57 already installed')
 (ROOT/'audits/V58/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
