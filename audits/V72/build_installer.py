"""Immutable V72 delta on the verified published V71. Does not modify historical Lua sources."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='798f63e5327c831cca02e664a00f75f852e25633'
NEW={
 '09B13_PURCHASE_HISTORY':('ModuleScript','ServerScriptService'),
 '09B14_AVATAR_BASES':('ModuleScript','ServerScriptService'),
 '09I24_LOOK_BATCHES':('ModuleScript','ServerScriptService'),
 '09C18_AVATAR_SAVE':('ModuleScript','ReplicatedStorage'),
 '09C19_EDITOR_UTILITIES':('ModuleScript','ReplicatedStorage'),
 '09I21_LOOK_CONTRACT':('ModuleScript','ReplicatedStorage'),
 '09I22_BODY_CHOOSER':('ModuleScript','ReplicatedStorage'),
 '09I23_REQUEST_PROGRESS':('ModuleScript','ReplicatedStorage'),
}
def safe(o):return json.dumps(o,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V71';effective={s['name']:s for v in baseline['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V72').glob('*.lua')):
  name=p.stem;data=p.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  if name in NEW:
   assert name not in effective;kind,location=NEW[name];spec=dict(name=name,type=kind,location=location,action='CRIAR')
  else:
   spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  label='NOVO'if spec['action']=='CRIAR'else'SUBSTITUIR';assert data.decode().splitlines()[0]==f"-- {name} | {spec['type']} | {spec['location']} | V72 ({label})"
  spec.update(path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for k in ['hide_full','install_note']:spec.pop(k,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['action']!='CRIAR',s['type']!='ModuleScript',s['name']))
 new=sum(s['action']=='CRIAR'for s in specs);replace=len(specs)-new
 assert len(specs)==45 and new==8 and replace==37
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==9 and all(x['exit_code']==0 for x in suite);cases=sum(s['cases']for s in suite)
 note=f'Base: V71 completa. V72: {new} ModuleScripts NOVOS + {replace} SUBSTITUIÇÕES. Pare Play. Crie primeiro os oito módulos novos nos locais indicados e substitua as fontes completas. Não duplique instâncias nem coloque NOVO/SUBSTITUIR no nome. Reinicie depois de concluir tudo. Nenhum passe/produto/chave/upload novo; Plus e Pro reutilizam os produtos existentes. 09A_SHOP_UI permanece nas quatro partes anteriores. Guia: INSTALL_V72.md.'
 v=dict(id='V72',base_version='V71',title='PEDIDO EXATO, PLANOS, EDITOR E PRATELEIRAS — BASE V71',date='2026-10-20',summary='Pedido visual em quatro etapas com corpo obrigatório, tipos/IDs/pesquisa por peça, esforços e progresso real. Gratuito/Plus/Pro com produtos e recibos existentes; Pro processa a quantidade escolhida em lotes de cinco, com cancelamento e proteção contra repetição. Assistente em branco suave, histórico e planos no rodapé. Prévia sem trilho lateral, itens equipados preservados, criação do zero com corpo/cor/cabelo/tamanho, salvar no jogo/nova roupa/conta Roblox e restauração confirmada. Patrocinar com prévia à esquerda e prateleiras adaptativas, busca, favoritos e rolagem XY; mídia 15 minutos e publicações 24 h mantidas. Photo Mode com grade de emotes/fundos/pacotes, iluminação direcional, clones e efeitos locais. Música mais compacta, HUD e jogos refinados. Chats, atividades, mapas, regras, turnos, bots, relógios e autoridade de compras preservados.',install_note=note,validation=f'{cases} cenários simulados em Lua 5.4, sintaxe/dependências/hashes, sete geometrias de tela e controles com área de toque; JavaScript real do instalador. Imagens de revisão são reconstruções, não capturas nativas. Sem motor Roblox: confirmar áudio, imagens/animações, filtros/permissões, compras reais, física e aparelhos no jogo publicado.',scripts=specs)
 prior=datetime.fromisoformat(baseline['updated_at']);now=max(datetime.now(timezone.utc),datetime(2026,10,20,tzinfo=timezone.utc),prior+timedelta(seconds=1))
 m=dict(baseline);m.update(latest='V72',updated_at=now.isoformat(timespec='seconds'),versions=baseline['versions']+[v]);(ROOT/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in {'V44','V55','V56','V57','V58','V59','V60','V61','V62','V63','V64','V65','V66','V67','V68','V69','V70','V71','V72'}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'<div class="meta">[\s\S]*?</div>',f'<div class="meta">V72: base V71 completa. {new} NOVOS + {replace} SUBSTITUIÇÕES. Contadores separados por tipo de ação. Copiar fonte inteira, nome/tipo/local e última linha; histórico e atualização pelo GitHub.</div>',html,count=1)
 # Apply the counter transformation to the fresh runtime; CSS may already exist in the shell.
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=html.replace(CSS,'');html=update(html);hp.write_text(html);(ROOT/'AVATAR_PLAZA_V72.html').write_text(html)
 intro=f'# Instalação V72 — {new} novos + {replace} substituições\n\n'+note+'\n\n'
 for action,heading in [('CRIAR','Criar primeiro — NOVOS'),('SUBSTITUIR','Substituir nas instâncias existentes')]:
  intro+='## '+heading+'\n\n| Etapa | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n';group=[s for s in specs if s['action']==action]
  for i,s in enumerate(group,1):intro+=f"| {i}/{len(group)} | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
  intro+='\n'
 (ROOT/'INSTALL_V72.md').write_text(intro+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version='V72',base_version='V71',base_commit=BASE,items=len(specs),create=new,replace=replace,effective_sources=len(effective)+new,max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size)
 (HERE/'package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
