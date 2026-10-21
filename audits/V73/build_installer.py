"""V73 immutable correction delta on the verified published V72."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
BASE='85194b93107388bdf7bd4334f066424839fe6b06'
def safe(o):return json.dumps(o,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 baseline=json.loads((HERE/'base_manifest.json').read_text());assert baseline['latest']=='V72';effective={s['name']:s for v in baseline['versions']for s in v['scripts']};specs=[]
 for p in sorted((ROOT/'scripts/V73').glob('*.lua')):
  name=p.stem;data=p.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  assert data.decode().splitlines()[0]==f"-- {name} | {spec['type']} | {spec['location']} | V73 (SUBSTITUIR)"
  spec.update(path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for k in ['hide_full','install_note']:spec.pop(k,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['type']!='ModuleScript',s['name']));assert len(specs)==8
 suite=json.loads((HERE/'suite_results.json').read_text());assert len(suite)==10 and all(x['exit_code']==0 for x in suite);cases=sum(s['cases']for s in suite)
 note='Base: V72 completa. V73: 8 SUBSTITUIÇÕES e NENHUM script novo. Pare Play e substitua as oito fontes inteiras nas instâncias existentes. Atenção: 09I_ASSISTANT_CLIENT e 09I_ACTIVITIES_CLIENT são scripts diferentes; não cole a mesma fonte nos dois. Reinicie Play depois de concluir tudo. Guia: INSTALL_V73.md.'
 v=dict(id='V73',base_version='V72',title='CORREÇÕES DO CATÁLOGO E ASSISTENTE · PATROCINAR 6 × 4',date='2026-10-21',summary='Patrocinar com seis itens por linha e quatro linhas visíveis, cards menores em cores suaves e miniaturas originais sem gradiente/tinta escura. Prévia lateral mais estreita no celular deitado/computador e painel de avatar opcional no celular em pé. Catálogo informa módulo ausente/duplicado, fonte incorreta ou erro de inicialização com diagnóstico no Output. Assistente ignora callbacks da tela destruída e impede cliente duplicado/fonte instalada com nome errado. Fonte própria das atividades incluída para restauração. Áudio com fallback espaçado e limitado; permissões nativas permanecem respeitadas. Backend de patrocínios, planos, compras e jogos preservados.',install_note=note,validation=f'{cases} cenários simulados em dez suítes Lua, sete geometrias com 24 cards completos, reprodução da falha Parent locked da V72, instalação completa/incompleta e clientes duplicados. Sintaxe, hashes e JavaScript do instalador conferidos. Sem execução nativa no Roblox: conferir toque/recortes, áudio, permissões e a instalação efetiva no jogo publicado.',scripts=specs)
 prior=datetime.fromisoformat(baseline['updated_at']);now=max(datetime.now(timezone.utc),datetime(2026,10,21,tzinfo=timezone.utc),prior+timedelta(seconds=1))
 m=dict(baseline);m.update(latest='V73',updated_at=now.isoformat(timespec='seconds'),versions=baseline['versions']+[v]);(ROOT/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']=='V44'or v['id']in {'V'+str(i)for i in range(55,74)}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']};runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'<div class="meta">[\s\S]*?</div>','<div class="meta">V73: base V72 completa. 8 SUBSTITUIÇÕES · nenhum script NOVO. Contagem 1/8 a 8/8, nome/tipo/local e botão para copiar a fonte inteira. Histórico e atualização pelo GitHub.</div>',html,count=1)
 sys.path.insert(0,str(HERE.parent/'installer_counters'));from update_installer import update,CSS
 html=html.replace(CSS,'');html=update(html);hp.write_text(html);(ROOT/'AVATAR_PLAZA_V73.html').write_text(html)
 intro='# Instalação V73 — 8 substituições, nenhum script novo\n\n'+note+'\n\n| Etapa | Nome exato | Tipo | Local | Linhas |\n|---:|---|---|---|---:|\n'
 for i,s in enumerate(specs,1):intro+=f"| {i}/8 | `{s['name']}` | {s['type']} | {s['location']} | {s['lines']} |\n"
 (ROOT/'INSTALL_V73.md').write_text(intro+'\n'+(HERE/'INSTALL_DETAILS.md').read_text())
 result=dict(version='V73',base_version='V72',base_commit=BASE,items=8,create=0,replace=8,effective_sources=len(effective),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size)
 (HERE/'package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
