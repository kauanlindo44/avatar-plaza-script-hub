"""Build the V76 delta without rewriting historical source packages."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
def safe(value):return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 base=json.loads((HERE/'base_manifest.json').read_text());assert base['latest']=='V75'
 old={s['name']:s for v in base['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V76').glob('*.lua')):
  raw=p.read_bytes();text=raw.decode();lines=len(text.splitlines());assert lines<=400,p.name
  match=re.fullmatch(r'-- (.+) \| (ModuleScript|LocalScript|Script) \| (.+) \| V76 \((CRIAR|SUBSTITUIR)\)',text.splitlines()[0]);assert match,p.name
  name,kind,location,action=match.groups();assert name==p.stem and(name in old)==(action=='SUBSTITUIR')
  if name in old:assert kind==old[name]['type']and location==old[name]['location']and text.splitlines()[1:]!=(ROOT/old[name]['path']).read_text().splitlines()[1:]
  specs.append(dict(name=name,type=kind,location=location,action=action,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(raw).hexdigest(),lines=lines,parts=2))
 specs.sort(key=lambda s:(s['action']!='CRIAR',{'ModuleScript':0,'Script':1,'LocalScript':2}[s['type']],s['name']))
 new=sum(s['action']=='CRIAR'for s in specs);changed=len(specs)-new;assert(new,changed)==(2,12)
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==14 and all(r['exit_code']==0 for r in suite);cases=sum(r['cases']for r in suite)
 note=f'Base: V75 completa. V76: {new} NOVOS + {changed} SUBSTITUIÇÕES. Pare Play. Crie primeiro 07G10_HUD_LAYOUT (ModuleScript em ReplicatedStorage) e 09I26_REQUEST_GUARD (ModuleScript em ServerScriptService). Depois substitua as {changed} fontes existentes por inteiro, nos nomes/tipos/locais indicados. Não acrescente V76, números ou contadores aos nomes. Use Copiar script inteiro. As duas partes são alternativa para a mesma instância. Reinicie Play após instalar os dois grupos. Guia: INSTALL_V76.md.'
 version=dict(id='V76',base_version='V75',title='HUD DE REFERÊNCIA · FUNDOS 3×3 · PLANOS E PROTEÇÕES',date='2026-10-23',summary='HUD reorganizado conforme a foto: Catálogo/Patrocinar no alto, Comunidade/Emotes à esquerda, Looks/Carregar à direita e ferramentas nas bordas. Menu + concentra IA e utilidades; toque em telas baixas recolhe atalhos secundários e preserva a área de pulo. Acesso direto ao corpo no editor. Photo Mode tem captura direta e fundos com três colunas e até três cards por coluna; emotes mantêm cinco colunas e até quatro linhas. Câmera mantém margens zero ao abrir painéis. Plus 3717699383 e Pro 3717699454 conferidos no código; compra exige consulta oficial e vínculo do produto à experiência. Guardas nos RPCs da IA e catálogo validam payload, frequência conjunta e concorrência; recibos conferem produto e identidade e continuam idempotentes. Truco separa cartas públicas da mão em telas baixas. Motores, bots, relógios, arena e regras permanecem na base.',install_note=note,validation=f'{cases} cenários simulados em 14 suítes; bloqueios reais de rede/execução no processo Lua; hashes e 175 fontes efetivas compiladas; instalador verificado separadamente. Pesquisa: 30 metadados de vídeos de 2026, 20 referências selecionadas; mídia/legendas inacessíveis, 0 minutos de análise audiovisual integral. Cópia exata de todas as telas do outro jogo NÃO VERIFICADA. Roblox nativo, aparelho físico, FPS, multiplayer e compra real permanecem pendentes.',scripts=specs)
 stamp=max(datetime.now(timezone.utc),datetime.fromisoformat(base['updated_at'])+timedelta(seconds=1))
 manifest=dict(base);manifest.update(latest='V76',updated_at=stamp.isoformat(timespec='seconds'),versions=base['versions']+[version])
 (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in manifest['versions']if v['id']=='V44'or v['id']in {'V'+str(i)for i in range(55,77)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(manifest,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 permanent=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
 html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',permanent.read_text())
 meta=f'<div class="meta">V76 · base V75 completa · {new} NOVOS + {changed} SUBSTITUIÇÕES. Confira os locais dos dois módulos novos. Copie as fontes inteiras e reinicie Play. Testes nativos e revisão audiovisual integral continuam pendentes.</div>'
 html=re.sub(r'<div class="meta">[\s\S]*?</div>',meta,html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=update(html.replace(CSS,'')).rstrip()+'\n';permanent.write_text(html);(ROOT/'AVATAR_PLAZA_V76.html').write_text(html)
 guide='# Instalação V76 — 2 novos + 12 substituições\n\n'+note+'\n\n'
 for action,title in [('CRIAR','Criar os 2 módulos novos'),('SUBSTITUIR','Substituir as 12 fontes existentes')]:
  group=[s for s in specs if s['action']==action];guide+='## '+title+'\n\n| Número | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
  for i,s in enumerate(group,1):guide+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  guide+='\n'
 (ROOT/'INSTALL_V76.md').write_text(guide+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version='V76',base='V75',base_commit=(HERE/'base_commit.txt').read_text().strip(),items=len(specs),create=new,replace=changed,effective_sources=len(old)+new,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=permanent.stat().st_size,native_roblox='PENDENTE',audiovisual_minutes_reviewed=0)
 (HERE/'package_results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
