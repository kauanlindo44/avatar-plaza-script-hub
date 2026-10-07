"""V52 delta over verified GitHub V51; compact copying UI and history preserved."""
from datetime import datetime,timedelta,timezone
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
CREATIONS=['07K14_DECK_OPTIONS','08B3_AVATAR_VERIFY','07H5_TRUCO_SETUP','07K15_TRUCO_TABLE','07K16_ATELIER_UI']
REPLACEMENTS=['08B_AVATAR_DATA','08B1_BODY_PACKAGES','08D_SKIN_STATE','09B5_AVATAR_RUNTIME','09C6_AVATAR_PREVIEW','09B_SHOP_SERVER','09A1_SHOP_LAYOUT','09A2_PREVIEW_LAYOUT','09C1_SHOP_LOOKS','09C7_COMMUNITY_FEED','07H1_GAME_LOBBY','07H_GAME_UI','07H2_GAME_BOARD','07K0_TRUCO_RULES','07K2_TRUCO_MATCH','07K_TRUCO_SERVER','07K6_CARD_CATALOG','07K7_CARD_STYLES','07K8_CARD_INVENTORY','07K10_CARD_COMMERCE','07K9_CARD_INVENTORY_UI','07K5_TRUCO_UI','07K_TRUCO_CLIENT']
BASE_SHA='24dad1296cabb261eb67bf1aed5a449f6cac3cf9'
def safe(value):
 return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 mpath=ROOT/'manifest.json';m=json.loads(mpath.read_text());previous=[v for v in m['versions']if v['id']!='V52']
 assert previous[-1]['id']=='V51','This patch is based on complete V51.'
 available={s['name']:s for v in previous for s in v['scripts']};base=next(v for v in previous if v['id']=='V44');specs=[]
 for name in CREATIONS+REPLACEMENTS:
  path=ROOT/'scripts/V52'/(name+'.lua');data=path.read_bytes();source=data.decode();lines=len(source.splitlines());assert lines<=400,name
  if name in CREATIONS:
   assert name not in available,name;spec=dict(name=name,type='ModuleScript',location='ReplicatedStorage',action='CRIAR')
  else:
   spec=available[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2);spec.pop('hide_full',None);specs.append(spec)
 assert {p.stem for p in(ROOT/'scripts/V52').glob('*.lua')}==set(CREATIONS+REPLACEMENTS)
 note='Requer a V51 completa já instalada. São 28 itens: 23 SUBSTITUIÇÕES e 5 NOVOS. Pare Play. Crie primeiro os cinco NOVOS como ModuleScripts em ReplicatedStorage, na ordem do instalador; depois substitua apenas os 23 existentes, sem duplicar instâncias. Cada item tem 2 partes consecutivas no MESMO script; também há Copiar script inteiro. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V52.md. Para roupas 3D, confira Layered Clothing nas propriedades/Avatar Settings do projeto: LoadCharacterLayeredClothing precisa permitir roupas em camadas; essa propriedade não pode ser alterada por scripts.'
 version=dict(id='V52',title='COMUNIDADE + JOGOS + TRUCO + ATELIÊ — 23 SUBSTITUIÇÕES + 5 NOVOS',date='2026-10-07',summary='Comunidade com pesquisa/filtro e 3–4 colunas, prévia em Meus avatares, correção de R15 para roupas 3D, novo lobby e mesa 2D. Compra direta de visuais, três cartas de amostra e Ateliê com enquadramentos salvos. Somente o delta após V51.',install_note=note,validation='74 fontes efetivas passam a sintaxe Lua 5.4. 25 cenários de serviços/geometria simulados, incluindo 72 partidas completas de bots. JavaScript real do instalador, hashes e cópia exata. Tamanhos 390×844, 851×392, 667×375, 568×320 e desktop amostrados conforme o cenário. Não houve execução no Roblox real nem compras; corpos específicos e toque físico ainda precisam de teste.',scripts=specs)
 m.update(latest='V52',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version];mpath.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 sources={s['path']:(ROOT/s['path']).read_text()for v in[base,version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 htmlpath=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',htmlpath.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V52 e a instalação V44',html)
 assert '/* COMPACT_INSTALLER */'in html;htmlpath.write_text(html);(ROOT/'AVATAR_PLAZA_V52.html').write_text(html)
 install='# Instalação V52 — 23 substituições + 5 NOVOS\n\n'+note+'\n\n'
 for title,names in[('Criar primeiro — 5 NOVOS',CREATIONS),('Substituir — 23 existentes',REPLACEMENTS)]:
  install+='## '+title+'\n\n| Nome exato no Studio | Tipo | Local | Partes |\n|---|---|---|---:|\n'
  for name in names:
   s=next(s for s in specs if s['name']==name);install+='| `'+name+'` | '+s['type']+' | '+s['location']+' | 2 |\n'
  install+='\n'
 install+='Apague a fonte antiga uma vez e cole as duas partes em ordem na mesma instância, ou use Copiar script inteiro. Não crie scripts separados para as partes. Não reinstale versões anteriores por cima destes itens. Esta atualização não substitui 09A_SHOP_UI; suas quatro partes da V51 permanecem instaladas. Todas as fontes desta entrega têm até '+str(max(s['lines']for s in specs))+' linhas.\n\nO HTML mostra nome, tipo, local, última linha e copiar, mantendo a fonte oculta. ONLINE fica verde quando a sincronização termina. Sem conexão, contém o delta V52 e a base histórica V44; a V52 ainda exige a V51 completa.\n\n'
 install+='## O que conferir no Roblox\n\n- **Corpos:** habilite roupas em camadas no projeto. Teste gato abacaxi, corpo meme e realista no perfil, prévia, Aplicar e respawn. Uma camisa não deve apagar o restante do outfit. Confira os itens com X embaixo. A verificação física agora rejeita um acessório 3D ausente em vez de confirmar só pelos IDs.\n- **Comunidade e looks:** somente pesquisa, filtro e outfits, com 4 colunas em telas largas ou 3 nas menores. Até 5 linhas quando há espaço legível. Meus avatares seleciona um look e abre sua prévia; itens continuam embaixo.\n- **Jogos:** três painéis no desktop/deitado, três painéis amplos empilhados no retrato. Moedas no cabeçalho, ações separadas, X acessível. Xadrez/dama usam tabuleiro maior e centrado.\n- **Truco:** partida rápida oferece variante e baralho cheio/limpo. Criar permite selecionar valores/naipes e salvar a configuração; mesas personalizadas não dão ranking nem moedas competitivas. Cartas próprias embaixo, públicas no centro e coleta visual para o canto. Cartas dos adversários permanecem privadas.\n- **Visuais:** compras diretas, três cartas de amostra, Meus visuais/Salvos/Ateliê. Não há novas compras de caixas. Créditos antigos continuam resgatáveis sem cobrança nova.\n- **Ateliê:** use uma imagem/decal permitido no Roblox. Carregar/↻ mostram sucesso ou erro. Teste arrastar, zoom, giro, luz, moldura/faixa, frente/verso, aplicar, guardar e reequipar em Salvos. Até 12 visuais salvos por conta.\n\n'
 install+='Passes e IDs de produtos diretos permanecem os mesmos. Preços vêm da Roblox no cliente; esta atualização não modifica os valores do painel. Não use Éter Visual (3716300364), que continua desativado. Recibos antigos dos três produtos de caixas são processados para não perder compras pendentes.\n\nOs testes são simulados e não comprovam disponibilidade/renderização de assets específicos, desempenho no aparelho ou pagamentos reais. Consulte [audits/V52/README.md](audits/V52/README.md) e [audits/V52/RESEARCH.md](audits/V52/RESEARCH.md).\n'
 (ROOT/'INSTALL_V52.md').write_text(install)
 result=dict(version='V52',base_commit=BASE_SHA,items=len(specs),replace=len(REPLACEMENTS),create=len(CREATIONS),max_lines=max(s['lines']for s in specs),html_bytes=htmlpath.stat().st_size,prerequisite='Complete V51 already installed')
 (ROOT/'audits/V52/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
