# Instalação V54 — 18 substituições + 3 NOVOS

Requer a V53 completa já instalada. V54 tem 21 instalações: 18 SUBSTITUIÇÕES + 3 NOVOS (19 fontes diferentes). Pare Play. Crie primeiro 07UI_SURFACE_EFFECTS e 09A4_UTILITY_SKIN como ModuleScript em ReplicatedStorage, e 09B7_LAST_AVATAR como ModuleScript em ServerScriptService. Substitua os demais, sem duplicar instâncias. ATENÇÃO: 07A0_CHESS_RULES e 07B0_CHECKERS_RULES precisam da mesma fonte em DOIS locais: ReplicatedStorage E ServerScriptService. Cada local está listado separadamente. Copiar inteiro ou duas partes no MESMO script. (NOVO)/(SUBSTITUIR) não fazem parte do nome. Consulte INSTALL_V54.md.

## Criar primeiro — 3 NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07UI_SURFACE_EFFECTS` | ModuleScript | ReplicatedStorage | 65 |
| `09A4_UTILITY_SKIN` | ModuleScript | ReplicatedStorage | 68 |
| `09B7_LAST_AVATAR` | ModuleScript | ServerScriptService | 93 |

## Substituir — 18 instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07A0_CHESS_RULES` | ModuleScript | ReplicatedStorage | 389 |
| `07A0_CHESS_RULES` | ModuleScript | ServerScriptService | 389 |
| `07B0_CHECKERS_RULES` | ModuleScript | ReplicatedStorage | 112 |
| `07B0_CHECKERS_RULES` | ModuleScript | ServerScriptService | 112 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 188 |
| `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 181 |
| `07H2_GAME_BOARD` | ModuleScript | ReplicatedStorage | 155 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 102 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 142 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 173 |
| `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 62 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 114 |
| `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 205 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 142 |
| `09C8_COMMUNITY_DETAILS` | ModuleScript | ReplicatedStorage | 149 |
| `09C1_SHOP_LOOKS` | ModuleScript | ReplicatedStorage | 177 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 220 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 382 |

As regras aparecem duas vezes porque existem no cliente e no servidor. Cole o mesmo código em cada instância indicada. Não crie outra instância com nome duplicado dentro da mesma pasta. Os três módulos marcados NOVO são as únicas criações.

Apague a fonte antiga uma vez e copie inteiro, ou cole parte 1 e depois parte 2 na mesma instância. O 09A_SHOP_UI e seus quatro trechos não entram nesta substituição. Todas as fontes têm até 389 linhas. O HTML esconde o código e mostra nome, tipo, local, última linha e copiar. ONLINE fica verde depois da sincronização. Sem conexão, há o delta V54 e a base histórica V44; instalar V54 continua exigindo V53 completa.

## Interfaces e comportamento

- **Jogos:** cabeçalho com moedas, abas Truco/Dama/Xadrez, quatro ações claras, painéis em azul escuro/jade com acentos, retratos originais de Nico/Lia/Dante, seleção de bot e efeitos de toque. Opções têm um único X; sair de uma sala de espera cancela a fila no servidor. As dificuldades continuam ligadas às IAs reais existentes.
- **Partidas:** tabuleiros de xadrez/dama grandes e centrados; promoção permite Rainha/Torre/Bispo/Cavalo também contra bots. Mesa 2D de Truco com aro de madeira, feltro, duplas destacadas e cartas públicas animadas até o centro. A vaza completa fica visível antes da coleta. As três cartas próprias permanecem acima dos botões. Chamada de Truco usa os dez segundos já controlados pelo servidor e somente aumentos da variante.
- **Meus looks e salvar:** prévia principal ampla sobre palco iluminado, cards compactos, seis ações visíveis e itens com X separado da miniatura. Nova tela de salvar mostra a skin e o formulário; R6 fica indisponível para corpos que precisam de R15. Cards que falham mostram apenas uma linha curta; a prévia principal permite tentar novamente.
- **Comunidade:** exatamente duas skins lado a lado, busca e filtro, fundo iluminado e preços compactos. As linhas se adaptam ao espaço: duas filas visíveis quando há altura suficiente. Usa os dados reais já existentes; recicla 50 slots e mantém até 100 looks no buffer, com Carregar mais e sem inventar usuários. Detalhes mostram prévia 360°, código quando houver, itens e ações.
- **Carrinho:** Itens escolhidos e Look completo, total estimado, marcação e remoção separadas, botão Recarregar e confirmação de quantidade. Em deitado, há prévia lateral. Abrir, selecionar ou comprar não troca a skin; cotação que falha libera os controles para nova tentativa. Preços finais e compra continuam no prompt oficial.
- **Área segura:** mesmos cálculos de origem/insets do catálogo; o cabeçalho aproveita a parte livre ao lado dos controles Roblox quando cabe. O restante alcança o limite seguro inferior. X de 48px e ações principais de pelo menos 44px; decoração não intercepta toque.

## Skin ao voltar ao jogo

Depois de Aplicar ser confirmado no personagem pelo servidor, a aparência é guardada no DataStore AvatarPlaza_LastApplied_v1. Ao entrar novamente, o servidor tenta restaurar corpo, acessórios, camadas, proporções e aparência antes do perfil padrão. A interface diferencia skin aplicada, salvamento pendente e falha de armazenamento. Abrir o catálogo sem modificar a skin não salva o perfil por cima de uma restauração que falhou.

Mudanças rápidas são agrupadas; gravações normais ficam espaçadas em oito segundos. PlayerRemoving e BindToClose tentam enviar a última alteração pendente. Um token de sessão impede gravação tardia do servidor antigo após a nova sessão assumir. Isso não recupera alterações ainda não gravadas em uma queda abrupta ou troca de servidor antes do flush. Falha de armazenamento mantém o registro anterior e não vira confirmação falsa de salvamento.

Teste em uma experiência publicada com DataStores disponíveis. Em Studio, o teste de persistência depende de Enable Studio Access to API Services. Para roupas 3D, Layered Clothing precisa estar permitido nas configurações de avatar do projeto: scripts não podem alterar a propriedade protegida. Gato abacaxi 72779265740934 continua sendo uma camisa 3D aplicada sobre R15. Malhas/cages específicos precisam de teste visual no Roblox.

## Regras revisadas

Dama brasileira de 64 casas: captura obrigatória com maioria, pedras capturam para trás, peças capturadas bloqueiam até o fim da sequência e coroação ocorre apenas no destino final. Contagem ordinária de 20 lances por jogador e finais reduzidos de cinco por jogador; nestes finais, movimento de pedra/captura não reinicia a contagem. Xadrez: mate precede empate automático de 75 lances, promoção reinicia o contador de peão e en passant conta na repetição somente quando pode ser jogado legalmente. Regras idênticas nos dois locais listados.

## Conferir no aparelho

1. Abra Jogos em pé/deitado; escolha os três jogos e os três bots. Crie/saia de uma sala, confirme quatro participantes no Truco e teste chamada/revanche.
2. Confira mesa, cartas, nomes, tabuleiros, promoção e toque dos botões.
3. Abra Meus looks/Salvar/Comunidade/Carrinho; veja a skin, gire e remova um item com X. Simule falha de cotação e Recarregar.
4. Aplique uma skin, aguarde a confirmação de salvamento, saia e entre de novo. Teste também respawn e uma falha de carregamento.

Passes, produtos e preços permanecem os do painel; compras diretas continuam. Sem novas ofertas de caixas. Éter Visual 3716300364 continua desativado. Nenhuma experiência Roblox foi publicada/alterada automaticamente.

Relatório: [audits/V54/README.md](audits/V54/README.md). Fontes: [audits/V54/RESEARCH.md](audits/V54/RESEARCH.md).
