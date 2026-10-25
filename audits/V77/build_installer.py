"""Build V77 from the published V76 manifest; historical source bytes are immutable."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
VERSION='V77'
def safe(value):return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 base=json.loads((HERE/'base_manifest.json').read_text());assert base['latest']=='V76'
 old={s['name']:s for v in base['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts'/VERSION).glob('*.lua')):
  raw=p.read_bytes();source=raw.decode();lines=len(source.splitlines());assert lines<=400,p.name
  match=re.fullmatch(r'-- (.+) \| (ModuleScript|LocalScript|Script) \| (.+) \| V77 \((CRIAR|SUBSTITUIR)\)',source.splitlines()[0]);assert match,p.name
  name,kind,location,action=match.groups();assert name==p.stem and(name in old)==(action=='SUBSTITUIR')
  if name in old:
   assert kind==old[name]['type']and location==old[name]['location']
   assert source.splitlines()[1:]!=(ROOT/old[name]['path']).read_text().splitlines()[1:],name
  specs.append(dict(name=name,type=kind,location=location,action=action,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(raw).hexdigest(),lines=lines,parts=2))
 specs.sort(key=lambda s:(s['action']!='CRIAR',{'ModuleScript':0,'Script':1,'LocalScript':2}[s['type']],s['name']))
 tested=json.loads((HERE/'tested_sources.json').read_text())
 for spec in specs:assert tested[spec['path']]==spec['sha256'],'Source changed after regression: '+spec['name']
 new=sum(s['action']=='CRIAR'for s in specs);changed=len(specs)-new;assert new==5 and changed==24,(new,changed)
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==17 and all(r['exit_code']==0 for r in suite);cases=sum(r['cases']for r in suite)
 note=f'Base: V76 completa. V77: {new} NOVOS + {changed} SUBSTITUIÇÕES. Pare Play. Crie primeiro os cinco ModuleScripts novos em ReplicatedStorage, exatamente com os nomes indicados. Depois substitua as {changed} fontes existentes por inteiro, nos tipos/locais indicados. Não acrescente V77 ou contadores aos nomes. Use Copiar script inteiro; partes são alternativa para a mesma instância. Reinicie Play depois dos dois grupos. Guia: INSTALL_V77.md.'
 version=dict(id=VERSION,base_version='V76',title='HUD DA REFERÊNCIA · CENÁRIOS SIMPLES · MESAS CLÁSSICAS',date='2026-10-25',summary='HUD com Catálogo/Lojas, roupas nas laterais e utilidades nos cantos; Mais reúne IA/jogos/comandos. Catálogo com mosaico de seis categorias e ações explícitas de experimentar/comprar. Modo foto com cinco ações, grades de três colunas, busca e câmera central fixa. Configurações em seis categorias, comandos agrupados, remoção com prévia e janelas coloridas de avatar menores. Treze cenários simples dos trechos visíveis; Vale da aventura continua inicial. IA lateral com biblioteca editorial local, miniaturas compactas e até cinco looks por coluna. Xadrez/damas com aparência clássica, jogadores/relógios junto ao tabuleiro e histórico de lances aceitos; regras/bots/tempo existentes preservados. Truco e Caos com cores mais discretas. Plus/Pro e recibos oficiais preservados.',install_note=note,validation=f'{cases} cenários simulados em 17 suítes; testes do processo bloqueiam rede/execução. Fontes compiladas e hashes verificados separadamente. Pesquisa pública limitada ao Chess.com: documentação e interface atual inspecionadas; gameplay integral quadro a quadro NÃO CONCLUÍDA. Vídeos do usuário estudados por amostragem, não por inspeção individual de todos os frames. Não certifica cópia pixel a pixel nem ausência de toda vulnerabilidade. Roblox nativo, áudio, física, FPS, compras reais e multiplayer pendentes.',scripts=specs)
 stamp=max(datetime.now(timezone.utc),datetime.fromisoformat(base['updated_at'])+timedelta(seconds=1))
 manifest=dict(base);manifest.update(latest=VERSION,updated_at=stamp.isoformat(timespec='seconds'),versions=base['versions']+[version])
 (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in manifest['versions']if v['id']=='V44'or v['id']in{'V'+str(i)for i in range(55,78)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(manifest,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 permanent=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
 html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',permanent.read_text())
 meta=f'<div class="meta">V77 · base V76 completa · {new} NOVOS + {changed} SUBSTITUIÇÕES. Crie os módulos antes de substituir as fontes. Todos os novos ficam em ReplicatedStorage. Copie as fontes inteiras e reinicie Play. Validação nativa e gameplay integral pendentes.</div>'
 html=re.sub(r'<div class="meta">[\s\S]*?</div>',meta,html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=update(html.replace(CSS,'')).rstrip()+'\n';permanent.write_text(html);(ROOT/'AVATAR_PLAZA_V77.html').write_text(html)
 guide=f'# Instalação V77 — {new} novos + {changed} substituições\n\n'+note+'\n\n'
 for action,title in [('CRIAR',f'Criar os {new} módulos novos'),('SUBSTITUIR',f'Substituir as {changed} fontes existentes')]:
  group=[s for s in specs if s['action']==action];guide+='## '+title+'\n\n| Número | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
  for i,s in enumerate(group,1):guide+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  guide+='\n'
 (ROOT/'INSTALL_V77.md').write_text(guide+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version=VERSION,base='V76',base_commit=(HERE/'base_commit.txt').read_text().strip(),items=len(specs),create=new,replace=changed,effective_sources=len(old)+new,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=permanent.stat().st_size,native_roblox='PENDENTE',complete_chess_gameplay_review='NOT_COMPLETED')
 (HERE/'package_results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
