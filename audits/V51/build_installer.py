"""V51 delta from complete V50, preserving the compact installer and history."""
from datetime import datetime,timedelta,timezone
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
REPLACEMENTS=['07UI_SCREEN_BOUNDS','08B_AVATAR_DATA','08B1_BODY_PACKAGES','08D_SKIN_STATE','09A_SHOP_UI','09A1_SHOP_LAYOUT','09B_SHOP_SERVER','09B5_AVATAR_RUNTIME','09C_SHOP_CLIENT','09C2_SHOP_CATALOG','09C6_AVATAR_PREVIEW']
CREATIONS=['08B2_BODY_DESCRIPTION']
def safe(value):
 return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 mpath=ROOT/'manifest.json';m=json.loads(mpath.read_text());previous=[v for v in m['versions']if v['id']!='V51']
 available={s['name']:s for v in previous for s in v['scripts']};base=next(v for v in previous if v['id']=='V44')
 specs=[]
 for name in CREATIONS+REPLACEMENTS:
  path=ROOT/'scripts/V51'/(name+'.lua');data=path.read_bytes();source=data.decode();lines=len(source.splitlines());assert lines<=400,name
  if name in CREATIONS:
   assert name not in available
   spec=dict(name=name,type='ModuleScript',location='ReplicatedStorage',parts=2,action='CRIAR')
  else:
   spec=available[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines)
  spec['parts']=4 if name=='09A_SHOP_UI'else 2
  if name=='09A_SHOP_UI':spec['hide_full']=True
  specs.append(spec)
 assert {p.stem for p in(ROOT/'scripts/V51').glob('*.lua')}==set(CREATIONS+REPLACEMENTS)
 note='Requer a V50 completa (ou os mesmos 11 itens da V49 sobre a V48 completa). São 12 itens: 11 SUBSTITUIÇÕES e 1 NOVO. Pare Play e crie primeiro 08B2_BODY_DESCRIPTION em ReplicatedStorage, como ModuleScript. Depois substitua os 11 existentes, sem duplicar instâncias. Os três NOVOS da V50 são existentes nesta versão. 09A_SHOP_UI continua com 4 partes consecutivas no MESMO ModuleScript; os demais têm 2 partes. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V51.md.'
 version=dict(id='V51',title='CORPOS NATIVOS + TELA DO CELULAR — 11 SUBSTITUIÇÕES + 1 NOVO',date='2026-10-04',summary='Correção da origem da área segura, topo livre ao lado da Roblox, prévia maior e cards com Robux embaixo. Pacotes nativos preservam metadados, expressão e acessórios do corpo; falhas podem ser tentadas novamente. Somente o delta depois da V50 completa.',install_note=note,validation='106 verificações Lua 5.4 com serviços/geometria simulados, incluindo 15 novos casos de corpos e celular. Verificação do JavaScript real do instalador, hashes e cópia em partes. Não houve execução no Roblox real; renderização de corpos específicos e toque físico ainda precisam de teste no aparelho.',scripts=specs)
 m.update(latest='V51',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version];mpath.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 htmlpath=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',htmlpath.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V51 e a instalação V44',html)
 assert '/* COMPACT_INSTALLER */'in html;htmlpath.write_text(html);(ROOT/'AVATAR_PLAZA_V51.html').write_text(html)
 install='# Instalação V51 — 11 substituições + 1 NOVO\n\n'+note+'\n\n'
 for title,names in [('Criar primeiro — 1 NOVO',CREATIONS),('Substituir — 11 existentes',REPLACEMENTS)]:
  install+='## '+title+'\n\n| Nome no Studio | Tipo | Local | Partes |\n|---|---|---|---:|\n'
  for name in names:
   spec=next(s for s in specs if s['name']==name);install+='| `'+name+'` | '+spec['type']+' | '+spec['location']+' | '+str(spec['parts'])+' |\n'
  install+='\n'
 install+='Apague a fonte antiga uma vez e cole as partes em ordem na mesma instância. Não crie quatro scripts para 09A_SHOP_UI. Não reinstale V50/V49 por cima destes itens depois.\n\nO HTML mantém o código oculto e mostra nome, tipo, local, última linha e copiar. ONLINE fica verde quando sincronizado. Sem conexão, o arquivo contém V51 e V44; a V51 depende de uma V50 completa já instalada.\n\nA V51 modifica apenas estes 12 itens. Jogos, passes, produtos, preços e dados salvos continuam compatíveis. As VERSION V41/V44 internas são contratos de compatibilidade.\n\n## Conferir no Roblox\n\nAbra o catálogo com um corpo meme/realista equipado no perfil. Experimente outro corpo e depois uma camisa; o restante do look deve permanecer. Confira as peças na prévia e no personagem, os quatro lados, morte/respawn e os X dos itens. Em caso de erro, use Tentar novamente.\n\nTeste o celular deitado e em pé, incluindo notch/barra de gestos: no deitado, veja 5 cards por linha e 2 linhas nas telas com espaço suficiente, Robux embaixo e prévia maior. Os controles da Roblox devem continuar livres.\n\nOs testes executados são simulados. Não comprovam a disponibilidade de cada asset nem a renderização do Funky Ehh Kid Meme (Gumball) no Roblox real. Detalhes e referências em [audits/V51/README.md](audits/V51/README.md) e [audits/V51/RESEARCH.md](audits/V51/RESEARCH.md).\n'
 (ROOT/'INSTALL_V51.md').write_text(install)
 result=dict(version='V51',items=len(specs),replace=len(REPLACEMENTS),create=len(CREATIONS),max_lines=max(s['lines']for s in specs),html_bytes=htmlpath.stat().st_size,prerequisite='Complete V50 or equivalent V49 patch over complete V48')
 (ROOT/'audits/V51/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
