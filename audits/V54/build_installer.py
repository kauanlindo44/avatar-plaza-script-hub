"""V54 delta over the verified remote V53, with both rule locations explicit."""
from datetime import datetime,timedelta,timezone
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
BASE_SHA='f99494623aa804cf43bd04712e50e33220a19b26'
CREATIONS=['07UI_SURFACE_EFFECTS','09A4_UTILITY_SKIN','09B7_LAST_AVATAR']
REPLACEMENTS=['07A0_CHESS_RULES','07B0_CHECKERS_RULES','09B5_AVATAR_RUNTIME',
 '07H1_GAME_LOBBY','07H2_GAME_BOARD','07K15_TRUCO_TABLE','07K5_TRUCO_UI',
 '09A1_SHOP_LAYOUT','09A2_PREVIEW_LAYOUT','09C6_AVATAR_PREVIEW','09C4_OUTFIT_LIBRARY',
 '09C7_COMMUNITY_FEED','09C8_COMMUNITY_DETAILS','09C1_SHOP_LOOKS','07H_GAME_UI','09C_SHOP_CLIENT']
DUAL={'07A0_CHESS_RULES','07B0_CHECKERS_RULES'}
def safe(value):
 return json.dumps(value,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
def build():
 p=ROOT/'manifest.json';m=json.loads(p.read_text());previous=[v for v in m['versions']if v['id']!='V54']
 assert previous[-1]['id']=='V53','Requires complete V53.'
 available={s['name']:s for v in previous for s in v['scripts']};base=next(v for v in previous if v['id']=='V44');specs=[]
 for name in CREATIONS+REPLACEMENTS:
  path=ROOT/'scripts/V54'/(name+'.lua');data=path.read_bytes();lines=len(data.decode().splitlines());assert lines<=400,name
  if name in CREATIONS:
   assert name not in available;spec=dict(name=name,type='ModuleScript',location='ServerScriptService'if name=='09B7_LAST_AVATAR'else'ReplicatedStorage',action='CRIAR')
  else:
   spec=available[name].copy();assert data!=(ROOT/spec['path']).read_bytes(),name;spec['action']='SUBSTITUIR'
  spec.update(path=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),lines=lines,parts=2)
  for k in ['hide_full','install_note']:spec.pop(k,None)
  specs.append(spec)
  if name in DUAL:
   assert spec['location']=='ReplicatedStorage';server=spec.copy();server['location']='ServerScriptService';specs.append(server)
 assert {x.stem for x in(ROOT/'scripts/V54').glob('*.lua')}==set(CREATIONS+REPLACEMENTS)
 reports=[json.loads(x.read_text())for x in(ROOT/'audits/V54').glob('*_results.json')if isinstance(json.loads(x.read_text()),list)]
 cases=sum(map(len,reports));assert all(r['result']=='pass'for group in reports for r in group)
 count=len(available)+len(CREATIONS);maxlines=max(s['lines']for s in specs)
 note='Requer a V53 completa já instalada. V54 tem 21 instalações: 18 SUBSTITUIÇÕES + 3 NOVOS (19 fontes diferentes). Pare Play. Crie primeiro 07UI_SURFACE_EFFECTS e 09A4_UTILITY_SKIN como ModuleScript em ReplicatedStorage, e 09B7_LAST_AVATAR como ModuleScript em ServerScriptService. Substitua os demais, sem duplicar instâncias. ATENÇÃO: 07A0_CHESS_RULES e 07B0_CHECKERS_RULES precisam da mesma fonte em DOIS locais: ReplicatedStorage E ServerScriptService. Cada local está listado separadamente. Copiar inteiro ou duas partes no MESMO script. (NOVO)/(SUBSTITUIR) não fazem parte do nome. Consulte INSTALL_V54.md.'
 validation=f'{count} fontes efetivas com sintaxe Lua 5.4 válida; {cases} cenários simulados, incluindo 72 partidas de bots, persistência/falhas de armazenamento, seis tamanhos de tela, regras e ações do controlador. Cópia e hashes do JavaScript real conferidos. Não houve execução no motor Roblox; renderização de malhas, toque e DataStores reais precisam de teste no jogo publicado.'
 version=dict(id='V54',title='JOGOS + LOOKS + COMUNIDADE + CARRINHO — 18 SUBSTITUIÇÕES + 3 NOVOS',date='2026-10-10',
  summary='Interfaces modernas ocupam a área segura como no catálogo; bots com retratos, mesa 2D com feltro e coleta animada, looks com prévia maior, comunidade em duas colunas e carrinho com escolhas claras/recarregar. Última skin aplicada volta ao entrar. Regras de dama/xadrez corrigidas no cliente e servidor. Apenas delta após V53.',
  install_note=note,validation=validation,scripts=specs)
 m.update(latest='V54',updated_at=max(datetime.now(timezone.utc),datetime.fromisoformat(m['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds'));m['versions']=previous+[version]
 p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
 sources={s['path']:(ROOT/s['path']).read_text()for v in[base,version]for s in v['scripts']}
 runtime=(ROOT/'audits/V51/installer_runtime.js').read_text()
 constants='const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST='+safe(dict(m,versions=[base,version]))+';\nconst FALLBACK_SCRIPTS='+safe(sources)+';\n'
 hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
 html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V54 e a instalação V44',html)
 assert '/* COMPACT_INSTALLER */'in html;hp.write_text(html);(ROOT/'AVATAR_PLAZA_V54.html').write_text(html)
 install='# Instalação V54 — 18 substituições + 3 NOVOS\n\n'+note+'\n\n'
 for title,action in [('Criar primeiro — 3 NOVOS','CRIAR'),('Substituir — 18 instâncias existentes','SUBSTITUIR')]:
  install+='## '+title+'\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
  for s in specs:
   if s['action']==action:install+='| `'+s['name']+'` | '+s['type']+' | '+s['location']+' | '+str(s['lines'])+' |\n'
  install+='\n'
 install+='As regras aparecem duas vezes porque existem no cliente e no servidor. Cole o mesmo código em cada instância indicada. Não crie outra instância com nome duplicado dentro da mesma pasta. Os três módulos marcados NOVO são as únicas criações.\n\nApague a fonte antiga uma vez e copie inteiro, ou cole parte 1 e depois parte 2 na mesma instância. O 09A_SHOP_UI e seus quatro trechos não entram nesta substituição. Todas as fontes têm até '+str(maxlines)+' linhas. O HTML esconde o código e mostra nome, tipo, local, última linha e copiar. ONLINE fica verde depois da sincronização. Sem conexão, há o delta V54 e a base histórica V44; instalar V54 continua exigindo V53 completa.\n\n'
 install+='## Interfaces e comportamento\n\n- **Jogos:** cabeçalho com moedas, abas Truco/Dama/Xadrez, quatro ações claras, painéis em azul escuro/jade com acentos, retratos originais de Nico/Lia/Dante, seleção de bot e efeitos de toque. Opções têm um único X; sair de uma sala de espera cancela a fila no servidor. As dificuldades continuam ligadas às IAs reais existentes.\n- **Partidas:** tabuleiros de xadrez/dama grandes e centrados; promoção permite Rainha/Torre/Bispo/Cavalo também contra bots. Mesa 2D de Truco com aro de madeira, feltro, duplas destacadas e cartas públicas animadas até o centro. A vaza completa fica visível antes da coleta. As três cartas próprias permanecem acima dos botões. Chamada de Truco usa os dez segundos já controlados pelo servidor e somente aumentos da variante.\n- **Meus looks e salvar:** prévia principal ampla sobre palco iluminado, cards compactos, seis ações visíveis e itens com X separado da miniatura. Nova tela de salvar mostra a skin e o formulário; R6 fica indisponível para corpos que precisam de R15. Cards que falham mostram apenas uma linha curta; a prévia principal permite tentar novamente.\n- **Comunidade:** exatamente duas skins lado a lado, busca e filtro, fundo iluminado e preços compactos. As linhas se adaptam ao espaço: duas filas visíveis quando há altura suficiente. Usa os dados reais já existentes; recicla 50 slots e mantém até 100 looks no buffer, com Carregar mais e sem inventar usuários. Detalhes mostram prévia 360°, código quando houver, itens e ações.\n- **Carrinho:** Itens escolhidos e Look completo, total estimado, marcação e remoção separadas, botão Recarregar e confirmação de quantidade. Em deitado, há prévia lateral. Abrir, selecionar ou comprar não troca a skin; cotação que falha libera os controles para nova tentativa. Preços finais e compra continuam no prompt oficial.\n- **Área segura:** mesmos cálculos de origem/insets do catálogo; o cabeçalho aproveita a parte livre ao lado dos controles Roblox quando cabe. O restante alcança o limite seguro inferior. X de 48px e ações principais de pelo menos 44px; decoração não intercepta toque.\n\n'
 install+='## Skin ao voltar ao jogo\n\nDepois de Aplicar ser confirmado no personagem pelo servidor, a aparência é guardada no DataStore AvatarPlaza_LastApplied_v1. Ao entrar novamente, o servidor tenta restaurar corpo, acessórios, camadas, proporções e aparência antes do perfil padrão. A interface diferencia skin aplicada, salvamento pendente e falha de armazenamento. Abrir o catálogo sem modificar a skin não salva o perfil por cima de uma restauração que falhou.\n\nMudanças rápidas são agrupadas; gravações normais ficam espaçadas em oito segundos. PlayerRemoving e BindToClose tentam enviar a última alteração pendente. Um token de sessão impede gravação tardia do servidor antigo após a nova sessão assumir. Isso não recupera alterações ainda não gravadas em uma queda abrupta ou troca de servidor antes do flush. Falha de armazenamento mantém o registro anterior e não vira confirmação falsa de salvamento.\n\nTeste em uma experiência publicada com DataStores disponíveis. Em Studio, o teste de persistência depende de Enable Studio Access to API Services. Para roupas 3D, Layered Clothing precisa estar permitido nas configurações de avatar do projeto: scripts não podem alterar a propriedade protegida. Gato abacaxi 72779265740934 continua sendo uma camisa 3D aplicada sobre R15. Malhas/cages específicos precisam de teste visual no Roblox.\n\n'
 install+='## Regras revisadas\n\nDama brasileira de 64 casas: captura obrigatória com maioria, pedras capturam para trás, peças capturadas bloqueiam até o fim da sequência e coroação ocorre apenas no destino final. Contagem ordinária de 20 lances por jogador e finais reduzidos de cinco por jogador; nestes finais, movimento de pedra/captura não reinicia a contagem. Xadrez: mate precede empate automático de 75 lances, promoção reinicia o contador de peão e en passant conta na repetição somente quando pode ser jogado legalmente. Regras idênticas nos dois locais listados.\n\n'
 install+='## Conferir no aparelho\n\n1. Abra Jogos em pé/deitado; escolha os três jogos e os três bots. Crie/saia de uma sala, confirme quatro participantes no Truco e teste chamada/revanche.\n2. Confira mesa, cartas, nomes, tabuleiros, promoção e toque dos botões.\n3. Abra Meus looks/Salvar/Comunidade/Carrinho; veja a skin, gire e remova um item com X. Simule falha de cotação e Recarregar.\n4. Aplique uma skin, aguarde a confirmação de salvamento, saia e entre de novo. Teste também respawn e uma falha de carregamento.\n\nPasses, produtos e preços permanecem os do painel; compras diretas continuam. Sem novas ofertas de caixas. Éter Visual 3716300364 continua desativado. Nenhuma experiência Roblox foi publicada/alterada automaticamente.\n\nRelatório: [audits/V54/README.md](audits/V54/README.md). Fontes: [audits/V54/RESEARCH.md](audits/V54/RESEARCH.md).\n'
 (ROOT/'INSTALL_V54.md').write_text(install)
 result=dict(version='V54',base_commit=BASE_SHA,items=len(specs),replace=18,create=3,unique_delta_sources=19,max_lines=maxlines,effective_sources=count,simulated_cases=cases,html_bytes=hp.stat().st_size,prerequisite='Complete V53 already installed',dual_rule_locations=sorted(DUAL))
 (ROOT/'audits/V54/package_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':build()
