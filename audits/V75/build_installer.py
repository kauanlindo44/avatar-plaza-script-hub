"""Package V75 as a new immutable delta over the published V74 manifest."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE=(HERE/'base_commit.txt').read_text().strip()
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V74'
 old={s['name']:s for v in baseline['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V75').glob('*.lua')):
  raw=p.read_bytes();text=raw.decode();lines=len(text.splitlines());assert lines<=400,(p.name,lines)
  header=re.fullmatch(r'-- (.+) \| (ModuleScript|LocalScript|Script) \| (.+) \| V75 \((CRIAR|SUBSTITUIR)\)',text.splitlines()[0]);assert header,p.name
  name,kind,location,action=header.groups();assert name==p.stem and(name in old)==(action=='SUBSTITUIR')
  if name in old:assert kind==old[name]['type']and location==old[name]['location']and text.splitlines()[1:]!=(ROOT/old[name]['path']).read_text().splitlines()[1:]
  specs.append(dict(name=name,type=kind,location=location,action=action,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(raw).hexdigest(),lines=lines,parts=2))
 specs.sort(key=lambda s:(s['action']!='CRIAR',{'ModuleScript':0,'Script':1,'LocalScript':2}[s['type']],s['name']))
 new=sum(s['action']=='CRIAR'for s in specs);replace=len(specs)-new;assert(new,replace)==(2,35)
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==12 and all(x['exit_code']==0 for x in suite);cases=sum(x['cases']for x in suite)
 note=f'Base: V74 completa. V75: {new} NOVOS + {replace} SUBSTITUIÇÕES. Pare Play. Crie primeiro os {new} ModuleScripts novos em ReplicatedStorage e depois substitua as {replace} fontes existentes por inteiro, nos nomes/tipos/locais indicados. Não acrescente V75 ou os contadores aos nomes. Reinicie Play depois de concluir os dois grupos. Use Copiar script inteiro; as duas partes são uma alternativa para a mesma instância. Guia: INSTALL_V75.md.'
 version=dict(id='V75',base_version='V74',title='HUD COM CENTRO LIVRE · IA ACESSÍVEL · EMOTES 5×4 · JOGOS',date='2026-10-22',summary='HUD compacto nas bordas, IA de looks direta e lista de comandos em janela móvel. Carregar/Vestindo/Restaurar usam cores próprias. Assistente abre sem depender da consulta opcional de planos, reconecta servidor tardio e apresenta looks pequenos, até cinco por coluna; busca respeita cores negativas e palavras completas. Photo Mode mantém o centro da câmera ao abrir painéis; emotes em cinco colunas e até quatro linhas, com compra separada. Vale da aventura inicia por padrão e cenários têm menos peças. Truco apresenta cartas por assento; Xadrez/Damas recebem composição, último lance, material e áudio. Botão do Caos ganha piso verde finito 128×88 sem paredes, queda eliminatória, empurrão validado no servidor, bomba com descida/explosão no chão e um único alvo. Efeitos sonoros da Creator Store, música reduzida durante a partida e limpeza na saída. Regras/relógios/bots e recibos dos jogos anteriores preservados.',install_note=note,validation=f'{cases} cenários simulados em 12 suítes, mais bloqueio real de rede/execução no processo de testes; sete geometrias; fontes efetivas e hashes verificados; JavaScript do instalador testado separadamente. Layouts reconstruídos não são capturas Roblox. PENDENTE de teste nativo multiplayer, corpos, toque, streaming, áudio/permissões e desempenho. Pesquisa audiovisual limitada pelo bloqueio do YouTube; referências e limites em audits/V75/RESEARCH.md.',scripts=specs)
 stamp=max(datetime.now(timezone.utc),datetime.fromisoformat(baseline['updated_at'])+timedelta(seconds=1))
 manifest=dict(baseline);manifest.update(latest='V75',updated_at=stamp.isoformat(timespec='seconds'),versions=baseline['versions']+[version])
 (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in manifest['versions']if v['id']=='V44'or v['id']in {'V'+str(i)for i in range(55,76)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']};runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(manifest,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 meta=f'<div class="meta">V75 · base V74 completa · {new} NOVOS + {replace} SUBSTITUIÇÕES. Contagens separadas, nomes/tipos/locais exatos e botão para copiar a fonte inteira. Confira o guia. Testes nativos no Roblox continuam pendentes.</div>'
 html=re.sub(r'<div class="meta">[\s\S]*?</div>',meta,html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=html.replace(CSS,'');html=update(html);hp.write_text(html);(ROOT/'AVATAR_PLAZA_V75.html').write_text(html)
 guide='# Instalação V75 — 2 novos + 35 substituições\n\n'+note+'\n\n'
 for action,title in [('CRIAR','Criar os 2 scripts novos'),('SUBSTITUIR','Substituir os 35 scripts existentes')]:
  group=[s for s in specs if s['action']==action];guide+='## '+title+'\n\n| Número | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
  for i,s in enumerate(group,1):guide+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  guide+='\n'
 (ROOT/'INSTALL_V75.md').write_text(guide+(HERE/'INSTALL_DETAILS.md').read_text())
 report=dict(version='V75',base_version='V74',base_commit=BASE,items=len(specs),create=new,replace=replace,effective_sources=len(old)+new,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,native_roblox_tests='PENDENTE')
 (HERE/'package_results.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':build()
