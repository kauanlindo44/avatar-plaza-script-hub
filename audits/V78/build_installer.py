"""Build V78 from the published V77 manifest; historical source bytes are immutable."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
VERSION='V78'
def safe(value):return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 base=json.loads((HERE/'base_manifest.json').read_text());assert base['latest']=='V77'
 old={s['name']:s for v in base['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts'/VERSION).glob('*.lua')):
  raw=p.read_bytes();source=raw.decode();lines=len(source.splitlines());assert lines<=400,p.name
  match=re.fullmatch(r'-- (.+) \| (ModuleScript|LocalScript|Script) \| (.+) \| V78 \((CRIAR|SUBSTITUIR)\)',source.splitlines()[0]);assert match,p.name
  name,kind,location,action=match.groups();assert name==p.stem and(name in old)==(action=='SUBSTITUIR')
  if name in old:
   assert kind==old[name]['type']and location==old[name]['location']
   assert source.splitlines()[1:]!=(ROOT/old[name]['path']).read_text().splitlines()[1:],name
  specs.append(dict(name=name,type=kind,location=location,action=action,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(raw).hexdigest(),lines=lines,parts=2))
 specs.sort(key=lambda s:(s['action']!='CRIAR',{'ModuleScript':0,'Script':1,'LocalScript':2}[s['type']],s['name']))
 tested=json.loads((HERE/'tested_sources.json').read_text())
 for spec in specs:assert tested[spec['path']]==spec['sha256'],'Source changed after regression: '+spec['name']
 new=sum(s['action']=='CRIAR'for s in specs);changed=len(specs)-new;assert new==3 and changed==26,(new,changed)
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==18 and all(r['exit_code']==0 for r in suite);cases=sum(r['cases']for r in suite)
 note=f'Base: V77 completa. V78: {new} NOVOS + {changed} SUBSTITUIÇÕES. Pare Play. Crie primeiro os três ModuleScripts novos em ReplicatedStorage, exatamente com os nomes indicados. Depois substitua as {changed} fontes existentes por inteiro, nos tipos/locais indicados. Não acrescente V78 ou contadores aos nomes. Use Copiar script inteiro; partes são alternativa para a mesma instância. Reinicie Play depois dos dois grupos. Guia: INSTALL_V78.md.'
 version=dict(id=VERSION,base_version='V77',title='CORREÇÕES FUNCIONAIS · PC/CELULAR · CÂMERA LIVRE',date='2026-10-26',summary='Corrige a rejeição do módulo atual de carrinho/corpo e protege a inicialização de catálogo/IA contra exportações incompatíveis. Prévia local recuperável e fila limitada com redescoberta do servidor. HUD com botões maiores, entrada direta para IA/jogos e reflow PC/celular; catálogo com cards proporcionais, 2–8 colunas e categorias/filtros acessíveis. Menu da IA e histórico sem sobreposição. Câmera livre com WASD, arrasto e joystick próprio, sem mover o personagem; controles/câmera restaurados na saída. Cenários fixos com materiais nativos, arquitetura detalhada e continuação das trilhas; trocar tema não teleporta. Vale da aventura inicial, modo foto de três colunas e regras/bots/recibos preservados.',install_note=note,validation=f'{cases} cenários simulados em 18 suítes; fonte real dos módulos/LocalScripts e serviços nativos simulados. Processo restringe rede/execução, payloads e repetição verificados. Não certifica funcionamento 100% no motor ou aparelho real. Revisão dos cinco prints e nova amostragem visual do vídeo de mapas; continuação inferida, sem recuperar texturas originais por ID. Roblox nativo, áudio, captura, FPS, compras reais e multiplayer pendentes.',scripts=specs)
 stamp=max(datetime.now(timezone.utc),datetime.fromisoformat(base['updated_at'])+timedelta(seconds=1))
 manifest=dict(base);manifest.update(latest=VERSION,updated_at=stamp.isoformat(timespec='seconds'),versions=base['versions']+[version])
 (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in manifest['versions']if v['id']=='V44'or v['id']in{'V'+str(i)for i in range(55,79)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(manifest,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 permanent=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
 html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',permanent.read_text())
 meta=f'<div class="meta">V78 · base V77 completa · {new} NOVOS + {changed} SUBSTITUIÇÕES. Crie os módulos antes de substituir as fontes. Todos os novos ficam em ReplicatedStorage. Copie as fontes inteiras e reinicie Play. Validação no motor Roblox e no aparelho ainda pendente.</div>'
 html=re.sub(r'<div class="meta">[\s\S]*?</div>',meta,html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=update(html.replace(CSS,'')).rstrip()+'\n';permanent.write_text(html);(ROOT/'AVATAR_PLAZA_V78.html').write_text(html)
 guide=f'# Instalação V78 — {new} novos + {changed} substituições\n\n'+note+'\n\n'
 for action,title in [('CRIAR',f'Criar os {new} módulos novos'),('SUBSTITUIR',f'Substituir as {changed} fontes existentes')]:
  group=[s for s in specs if s['action']==action];guide+='## '+title+'\n\n| Número | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
  for i,s in enumerate(group,1):guide+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  guide+='\n'
 (ROOT/'INSTALL_V78.md').write_text(guide+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version=VERSION,base='V77',base_commit=(HERE/'base_commit.txt').read_text().strip(),items=len(specs),create=new,replace=changed,effective_sources=len(old)+new,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=permanent.stat().st_size,native_roblox='PENDENTE',complete_chess_gameplay_review='NOT_COMPLETED')
 (HERE/'package_results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
