"""V53 delta over audited remote V52; preserve every historical release."""
from datetime import datetime,timedelta,timezone
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
CREATIONS=['08B4_AVATAR_LOAD','09B6_CART_RESOLVER']
REPLACEMENTS=['08B2_BODY_DESCRIPTION','08B3_AVATAR_VERIFY','09B5_AVATAR_RUNTIME','09C6_AVATAR_PREVIEW',
 '07P2_STUDIO_AVATAR','09B_SHOP_SERVER','09A1_SHOP_LAYOUT','09C4_OUTFIT_LIBRARY','09C2_SHOP_CATALOG','09C_SHOP_CLIENT',
 '07H1_GAME_LOBBY','07H_GAME_UI','07K3_TRUCO_DIRECTORY','07K2_TRUCO_MATCH','07K_TRUCO_SERVER',
 '07K7_CARD_STYLES','07K15_TRUCO_TABLE','07K5_TRUCO_UI','07K_TRUCO_CLIENT']
BASE_SHA='b397dfe12ebebed3ca61c91df530dbcbc69ca902'
def safe(value):
 return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 mpath=ROOT/'manifest.json';m=json.loads(mpath.read_text());previous=[v for v in m['versions']if v['id']!='V53']
 assert previous[-1]['id']=='V52','Requires complete V52.'
 available={s['name']:s for v in previous for s in v['scripts']};base=next(v for v in previous if v['id']=='V44');specs=[]
 for name in CREATIONS+REPLACEMENTS:
  path=ROOT/'scripts/V53'/(name+'.lua');data=path.read_bytes();source=data.decode();lines=len(source.splitlines());assert lines<=400,name
  if name in CREATIONS:
   assert name not in available,name;spec=dict(name=name,type='ModuleScript',location='ReplicatedStorage'if name=='08B4_AVATAR_LOAD'else'ServerScriptService',action='CRIAR')
  else:
   spec=available[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2);spec.pop('hide_full',None);specs.append(spec)
 assert {p.stem for p in(ROOT/'scripts/V53').glob('*.lua')}==set(CREATIONS+REPLACEMENTS)
 count=len(available)+len(CREATIONS)
 note='Requer a V52 completa já instalada. São 21 itens: 19 SUBSTITUIÇÕES e 2 NOVOS. Pare Play. Crie 08B4_AVATAR_LOAD como ModuleScript em ReplicatedStorage e 09B6_CART_RESOLVER como ModuleScript em ServerScriptService; depois substitua apenas os 19 existentes, sem duplicar instâncias. Cada item permite Copiar script inteiro ou duas partes consecutivas no MESMO script. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V53.md. Para roupas 3D, confira Layered Clothing nas configurações de avatar do projeto; não é possível habilitar essa propriedade por script.'
 version=dict(id='V53',title='AVATARES + CARRINHO + JOGOS — 19 SUBSTITUIÇÕES + 2 NOVOS',date='2026-10-08',
  summary='Carregamento visual compartilhado em catálogo/looks/Photo Mode, falhas e nova tentativa; carrinho reconhece pacotes e mantém escolhas. Catálogo recicla cards. Jogos com seleção por abas, bots com nome, sala 2v2 com Pronto e reserva de dupla, TRUCO com 10s e revanche. Apenas delta após V52.',
  install_note=note,validation=f'{count} fontes efetivas passam a sintaxe Lua 5.4. 40 cenários de serviços/geometria simulados, incluindo 72 partidas completas de bots. JavaScript real do instalador, hashes e cópia exata. Telas de 320×568 a 1920×1080, incluindo 568×320. Não houve execução no Roblox real, compra ou publicação do place; malhas/cages específicos, deformação, toque físico e viagens precisam de teste real.',scripts=specs)
 m.update(latest='V53',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 mpath.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 sources={s['path']:(ROOT/s['path']).read_text()for v in[base,version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 htmlpath=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',htmlpath.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V53 e a instalação V44',html)
 assert '/* COMPACT_INSTALLER */'in html;htmlpath.write_text(html);(ROOT/'AVATAR_PLAZA_V53.html').write_text(html)
 install='# Instalação V53 — 19 substituições + 2 NOVOS\n\n'+note+'\n\n'
 for title,names in[('Criar primeiro — 2 NOVOS',CREATIONS),('Substituir — 19 existentes',REPLACEMENTS)]:
  install+='## '+title+'\n\n| Nome exato no Studio | Tipo | Local | Partes |\n|---|---|---|---:|\n'
  for name in names:
   s=next(s for s in specs if s['name']==name);install+='| `'+name+'` | '+s['type']+' | '+s['location']+' | 2 |\n'
  install+='\n'
 install+='Apague a fonte antiga uma vez e cole as duas partes em ordem na mesma instância, ou use Copiar script inteiro. Não crie scripts separados para as partes e não cole versões anteriores por cima. A V53 contém somente alterações; não instale a V44 embutida por cima da V52. O 09A_SHOP_UI e seus quatro trechos permanecem os da versão já instalada. Todos os itens desta entrega têm no máximo '+str(max(s['lines']for s in specs))+' linhas.\n\nO HTML mostra nome, tipo, local, última linha e copiar, mantendo a fonte oculta. ONLINE fica verde quando a sincronização termina. Sem conexão, contém o delta V53 e a base histórica V44; a V53 ainda exige a V52 completa.\n\n'
 install+='## O que mudou\n\n- **Avatar e prévias:** catálogo, Meus avatares, comunidade e Photo Mode usam o mesmo carregamento. R15 quando necessário, readback dos IDs/roupas/proporções/cores, corpo completo, acessórios físicos e pré-carregamento das malhas/texturas. Falhas ficam visíveis e as prévias maiores oferecem Tentar novamente; o catálogo tem somente um aviso/botão de falha. A prévia usa fundo neutro claro e câmera 360°. Os itens com X continuam embaixo.\n- **Gato abacaxi:** 72779265740934 é uma camisa 3D (ShirtAccessory), não um pacote de corpo. Ela deve ser colocada sobre um R15 que permita camadas. O caminho de teste preserva as roupas e acessórios existentes. Não existe confirmação de renderização desse asset no Roblox nesta sessão.\n- **Carrinho:** Outfit atual consulta pacotes de corpo/pares de sapatos em vez de cobrar peças duplicadas. Consultas de pacotes são limitadas e o total é uma estimativa. Itens indisponíveis ou já possuídos são excluídos; preço desconhecido aparece como consultar. Comprar fica bloqueado enquanto o outfit é resolvido; escolhas desmarcadas são mantidas. + CARRINHO nos detalhes adiciona o item sem trocar o avatar. Experimentar também o adiciona sem duplicar.\n- **Catálogo:** os cards são reutilizados ao rolar; até 40 instâncias de card, mesmo com mais páginas. Duas linhas visíveis e até cinco itens por linha quando há espaço, miniatura ampla e preço compacto embaixo.\n- **Jogos:** abas Truco/Dama/Xadrez e quatro ações do jogo escolhido. Paleta grafite/verde suave, moedas no cabeçalho, bots Nico/Lia/Dante em perfis verticais; os nomes correspondem aos níveis reais das IAs existentes. Xadrez/dama continuam com tabuleiro grande no centro.\n- **Salas de Truco:** duas duplas, código, roster e Estou pronto. A partida humana começa somente depois da confirmação dos quatro jogadores. O anfitrião pode reservar o assento oposto para um amigo Roblox por dois minutos e compartilhar o código; não é enviada mensagem automática ao amigo. Códigos de outro servidor utilizam a viagem já existente. Reentrar limpa a confirmação antiga.\n- **Mesa:** maior, cartas públicas no centro e três cartas próprias tocáveis; uma única faixa de ações embaixo. TRUCO tem dez segundos para resposta, Aceitar/Correr/aumento legal; o servidor aplica o prazo. Revanche exige todos os votos; não é oferecida nos torneios. As artes ficam mais calmas e distintas, preservando valor e naipe.\n\n'
 install+='## Conferir no Roblox\n\nHabilite roupas em camadas nas propriedades/Avatar Settings do projeto. Teste gato abacaxi, Gumball e corpos realistas no perfil, prévia, Aplicar, Photo Mode e respawn. Confirme notch, controles Roblox, X e arrasto 360° em pé/deitado. Faça uma sala com quatro contas, escolha as duplas, confirme Pronto, teste chamada de 10 segundos, reserva de amigo de outro servidor e revanche.\n\nO carregamento visual usa um prazo para pré-carregamento e uma fila limitada; a criação nativa do Roblox pode demorar além desse prazo. Se falhar, tente novamente. A presença de WrapTarget/WrapLayer, os IDs e o sucesso de downloads não comprovam a deformação/renderização final de todo asset. A leitura de configuração protegida é apenas tentativa; a configuração real deve ser conferida no editor.\n\nPasses, produtos e preços não foram alterados. Compras diretas permanecem, sem novas ofertas de caixas. Não use Éter Visual (3716300364), que continua desativado. Créditos e recibos antigos são preservados.\n\nTestes: [audits/V53/README.md](audits/V53/README.md). Fontes oficiais: [audits/V53/RESEARCH.md](audits/V53/RESEARCH.md).\n'
 (ROOT/'INSTALL_V53.md').write_text(install)
 result=dict(version='V53',base_commit=BASE_SHA,items=len(specs),replace=len(REPLACEMENTS),create=len(CREATIONS),max_lines=max(s['lines']for s in specs),effective_sources=count,html_bytes=htmlpath.stat().st_size,prerequisite='Complete V52 already installed')
 (ROOT/'audits/V53/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()

