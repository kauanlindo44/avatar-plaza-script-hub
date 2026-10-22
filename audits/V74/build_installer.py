"""Immutable V74 delta on verified GitHub V73; code/native test boundaries explicit."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='144dcc4d8168536b87d8e046b117a965714c5312'
def safe(value):return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V73'
 effective={s['name']:s for v in baseline['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V74').glob('*.lua')):
  raw=p.read_bytes();text=raw.decode();lines=len(text.splitlines());assert lines<=400,(p.name,lines)
  header=re.fullmatch(r'-- (.+) \| (ModuleScript|LocalScript|Script) \| (.+) \| V74 \((CRIAR|SUBSTITUIR)\)',text.splitlines()[0]);assert header,p.name
  name,kind,location,action=header.groups();assert name==p.stem
  assert (name in effective)==(action=='SUBSTITUIR'),(name,action)
  if name in effective:
   old=effective[name];assert kind==old['type']and location==old['location'];assert raw!=(ROOT/old['path']).read_bytes()
  specs.append(dict(name=name,type=kind,location=location,action=action,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(raw).hexdigest(),lines=lines,parts=2))
 specs.sort(key=lambda s:(s['action']!='CRIAR',{'ModuleScript':0,'Script':1,'LocalScript':2}[s['type']],s['name']))
 creations=sum(s['action']=='CRIAR'for s in specs);replacements=len(specs)-creations;assert(creations,replacements)==(16,12)
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==12 and all(x['exit_code']==0 for x in suite);cases=sum(x['cases']for x in suite)
 note='Base: V73 completa. V74: 16 scripts NOVOS + 12 SUBSTITUIÇÕES. Pare Play; crie os 16 novos com nome/tipo/local exatos; substitua as 12 fontes inteiras em suas instâncias existentes. Não coloque (NOVO), contagem ou V74 no nome das instâncias. Reinicie Play só depois de concluir tudo. Os grupos são numerados separadamente: 1/16 NOVO e 1/12 SUBSTITUIR. Guia: INSTALL_V74.md. Não é necessário criar nenhum produto ou passe para Botão do Caos.'
 version=dict(id='V74',base_version='V73',title='BOTÃO DO CAOS V1 · NOSSOS JOGOS · HUD E PATROCINAR',date='2026-10-22',summary='Biblioteca dos nossos quatro jogos com cards próprios, seleção lateral no computador e navegação separada no celular. HUD com nomes legíveis, grafite suave e atalhos agrupados. Patrocinar conserva seis itens por linha e quatro linhas com cards neutros e preços mais fortes. Botão do Caos V1: arena 96×96 distante da praça, fila FIFO de 2–8, preparação 12 s, contagem 5 s, disputa 150 s, treino individual 90 s, 12 efeitos, combate e sorteio no servidor, espectador, resultados e retorno preservando avatar/ferramentas/configurações. Verificação de obstáculos e recuperação de erro. Plus/Pro identificam falhas de produto/preço/venda e consultam a lista oficial quando necessário; concessão continua somente por recibo. Sem novos produtos pagos, economia ou implementação de Rodovia 061.',install_note=note,validation=f'{cases} cenários simulados em doze suítes Lua; sete geometrias, 21 reconstruções visuais, sintaxe/hashes de 171 fontes e JavaScript real do instalador. Nenhum teste físico ou servidor multiplayer publicado foi executado. Botão do Caos está PENDENTE DE TESTE NATIVO com 2–8 usuários, recortes/toque, ferramentas com corpos personalizados, streaming, áudio e FPS. Regras, bots, relógios e pontuação de Truco/Xadrez/Damas preservados.',scripts=specs)
 prior=datetime.fromisoformat(baseline['updated_at']);stamp=max(datetime.now(timezone.utc),datetime(2026,10,22,tzinfo=timezone.utc),prior+timedelta(seconds=1))
 manifest=dict(baseline);manifest.update(latest='V74',updated_at=stamp.isoformat(timespec='seconds'),versions=baseline['versions']+[version])
 (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in manifest['versions']if v['id']=='V44'or v['id']in {'V'+str(i)for i in range(55,75)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']};runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(manifest,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'<div class="meta">[\s\S]*?</div>','<div class="meta">V74 · base V73 completa · 16 NOVOS + 12 SUBSTITUIÇÕES. Contagens separadas 1/16 e 1/12, nome/tipo/local, última linha e botão de copiar a fonte inteira. Botão do Caos V1 aguarda teste nativo no Roblox. Histórico e atualização pelo GitHub.</div>',html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=html.replace(CSS,'');html=update(html);hp.write_text(html);(ROOT/'AVATAR_PLAZA_V74.html').write_text(html)
 guide='# Instalação V74 — 16 novos + 12 substituições\n\n'+note+'\n\n'
 for action,title in [('CRIAR','Criar os 16 scripts novos'),('SUBSTITUIR','Substituir os 12 scripts existentes')]:
  group=[s for s in specs if s['action']==action];guide+='## '+title+'\n\n| Número do grupo | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
  for i,s in enumerate(group,1):guide+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  guide+='\n'
 (ROOT/'INSTALL_V74.md').write_text(guide+(HERE/'INSTALL_DETAILS.md').read_text())
 report=dict(version='V74',base_version='V73',base_commit=BASE,items=len(specs),create=creations,replace=replacements,effective_sources=len(effective)+creations,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,native_roblox_tests='PENDENTE DE TESTE')
 (HERE/'package_results.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':build()
