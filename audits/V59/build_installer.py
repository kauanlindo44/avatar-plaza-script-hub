"""Focused V59 patch on published V58; historical versions remain immutable."""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
BASE='eee3fb7a7114b8cdb6828436c78556817938ecf5'
def safe(obj):return json.dumps(obj,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V59'];assert previous[-1]['id']=='V58'
 effective={s['name']:s for v in previous for s in v['scripts']};specs=[]
 for path in sorted((ROOT/'scripts/V59').glob('*.lua')):
  name=path.stem;data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,(name,lines)
  spec=effective[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name
  spec.update(action='SUBSTITUIR',path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for key in ['hide_full','install_note']:spec.pop(key,None)
  specs.append(spec)
 specs.sort(key=lambda s:(s['type']!='ModuleScript',s['name']))
 assert len(specs)==4 and all(s['action']=='SUBSTITUIR'for s in specs)
 reports=[json.loads((ROOT/'audits/V59'/p).read_text())for p in ['native_results.json','interface_results.json']]
 cases=sum(map(len,reports));assert cases==14 and all(x['result']=='pass'for r in reports for x in r)
 note='Requer V58 completa. V59: somente 4 SUBSTITUIÇÕES da IA; nenhum script novo. Pare Play, substitua as fontes completas nos locais indicados e reinicie Play. Recarregar IA compara o assistente com o exemplo oficial. Respostas em inglês neste teste de compatibilidade. Guia: INSTALL_V59.md.'
 version=dict(id='V59',title='IA: HTTP 400 + DIAGNÓSTICO INDEPENDENTE — 4 SUBSTITUIÇÕES',date='2026-10-11',
  summary='Remove a instrução contraditória de português/JSON, usa texto simples em inglês e verifica a instrução real. Recarregar compara o exemplo oficial separadamente. Corrige sobreposição do X e alinhamento das mensagens; preserva limites, reembolso e verificação de planos.',install_note=note,
  validation='14 cenários simulados; 98 fontes efetivas com sintaxe válida; seis resoluções, quatro abas e dois estados de conexão; JavaScript real do instalador. TextGenerator nativo ainda precisa de teste no Roblox; HTTP 400 não foi confirmado como resolvido no serviço.',scripts=specs)
 m.update(latest='V59',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 embedded=[v for v in m['versions']if v['id']in{'V44','V55','V56','V57','V58','V59'}]
 sources={s['path']:(ROOT/s['path']).read_text()for v in embedded for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=embedded))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>','<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V59 tem apenas 4 substituições da IA. O 09A_SHOP_UI aparece somente em 4 partes.</div>',html,count=1)
 hp.write_text(html);(ROOT/'AVATAR_PLAZA_V59.html').write_text(html)
 intro='# Instalação V59 — somente 4 substituições\n\n'+note+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
 for s in specs:intro+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
 (ROOT/'INSTALL_V59.md').write_text(intro+'\n'+(ROOT/'audits/V59/INSTALL_DETAILS.md').read_text())
 result=dict(version='V59',base_commit=BASE,items=4,replace=4,create=0,effective_sources=len(effective),max_lines=max(s['lines']for s in specs),simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V58 already installed')
 (ROOT/'audits/V59/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
