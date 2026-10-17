# Instalação V67 — 4 novos + 32 substituições

Requer V66 completa. V67: 4 módulos NOVOS + 32 SUBSTITUIÇÕES. Pare Play. Crie 07G7_ADVENTURE_WORLD e 09I10_CHAT_NAV como ModuleScript em ReplicatedStorage; 08B7_AVATAR_ANIMATIONS e 09I11_CONVERSATIONS como ModuleScript em ServerScriptService. Depois substitua as 32 fontes completas e reinicie. Não acrescente NOVO/SUBSTITUIR aos nomes. Nenhum passe, produto ou chave externa novo. Guia: INSTALL_V67.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G7_ADVENTURE_WORLD` | ModuleScript | ReplicatedStorage | 40 |
| `08B7_AVATAR_ANIMATIONS` | ModuleScript | ServerScriptService | 36 |
| `09I10_CHAT_NAV` | ModuleScript | ReplicatedStorage | 84 |
| `09I11_CONVERSATIONS` | ModuleScript | ServerScriptService | 66 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 112 |
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 68 |
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 68 |
| `07G6_WORLD_DETAILS` | ModuleScript | ReplicatedStorage | 37 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 106 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 167 |
| `07M2_AUDIO_LIBRARY` | ModuleScript | ServerScriptService | 62 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 230 |
| `07P7_ROBLOX_BACKGROUNDS` | ModuleScript | ReplicatedStorage | 41 |
| `07P8_BACKGROUND_RESOLVER` | ModuleScript | ServerScriptService | 61 |
| `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 165 |
| `07UI_HALLOWEEN_THEME` | ModuleScript | ReplicatedStorage | 137 |
| `08B6_AVATAR_MOVEMENT` | ModuleScript | ReplicatedStorage | 94 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 217 |
| `09B8_FREE_HIGHLIGHTS` | ModuleScript | ServerScriptService | 168 |
| `09C12_DESTINATION_BROWSER` | ModuleScript | ReplicatedStorage | 149 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 262 |
| `09C9_PLAYER_INSPECT` | ModuleScript | ReplicatedStorage | 70 |
| `09I1_ASSISTANT_ACCOUNTS` | ModuleScript | ServerScriptService | 121 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 42 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 137 |
| `09I7_ASSISTANT_PROFILE` | ModuleScript | ReplicatedStorage | 55 |
| `09I9_GAME_GUIDE` | ModuleScript | ReplicatedStorage | 68 |
| `01A_HUB_CORE_ENV` | Script | ServerScriptService | 101 |
| `01B_HUB_WORLD` | Script | ServerScriptService | 145 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 98 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 168 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 253 |
| `09C11_AVATAR_CHARACTER` | LocalScript | StarterPlayer > StarterPlayerScripts | 66 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 384 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 106 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 131 |

## Instalar

1. Pare Play e confirme que a **V66 completa** está instalada. Se você parou na V65, instale primeiro a V66 pelo mesmo HTML.
2. Crie os **quatro ModuleScripts NOVOS** da tabela, respeitando ReplicatedStorage ou ServerScriptService. NOVO é apenas a indicação do instalador; não faz parte do nome.
3. Substitua a fonte completa dos **32 scripts existentes**. Não deixe versões duplicadas. Depois de terminar tudo, reinicie Play.

O `09A_SHOP_UI` continua nas quatro partes anteriores e não entra neste pacote. Nenhum passe, produto, chave OpenAI ou textura para enviar ao Roblox precisa ser criado. Looks, códigos, recibos e produtos anteriores continuam preservados. O instalador mantém código recolhido, nome/tipo/local, última linha e botão de copiar a fonte inteira.

## Mudanças e conferência no jogo publicado

- **Fundos:** a V66 criava a prova fora da tela e 100% transparente. Isso podia manter `ImageLabel.IsLoaded` falso mesmo para uma imagem válida; a mensagem atribuía a falha à disponibilidade. A V67 mantém uma prova de 32×32 dentro da tela, com 99% de transparência, durante a confirmação e a remove ao terminar. Usa as referências internas recebidas do servidor, aceita texturas nativas e tenta até quatro referências com prazo total limitado. Permissão negada, cancelamento e timeout mantêm o fundo anterior. Logs: `[Photo V67] BACKGROUND_RENDER`, `BACKGROUND_INSERT` ou `BACKGROUND_REFERENCE`.
- **Apoio dos avatares:** o módulo compara o apoio nativo com os pés/pernas do rig, inclusive classificação nativa de peças, sem incluir roupas, cabelo, ferramentas ou acessórios. Corrige HipHeight baixo, mantém a correção após recálculo inicial e faz verificações limitadas durante cinco segundos; não teleporta a cada frame. Recriações mantêm o personagem ereto, descartam impulso antigo e atribuem a simulação ao jogador quando permitido. É uma correção do posicionamento do rig; não altera a malha/cage criada pelo autor do item.
- **Caminhada:** resolve as animações da aparência realmente equipada. Quando a descrição já traz um asset Animation, usa esse clip; quando traz um item de animação, extrai o clip do recipiente sem executar scripts. Atualiza os filhos de Animate e usa esses clips no fallback. A consulta tenta novamente quando a aplicação da aparência ainda está ocupada; o cache distingue personagens/épocas. O fallback continua cedendo a animações nativas em execução. Rig e qualidade da animação original ainda dependem do asset do Roblox.
- **Emotes no catálogo:** toque num item de Emotes e depois em Testar emote. A prévia atual usa o clip confirmado e Animator; não chama mais PlayEmoteAsync na cópia nem recria o avatar para cada teste. Parar interrompe a animação. R6 oferece a mudança para R15. Cards têm fundo mais escuro e indicação de Emote, com contraste separado do preço.
- **IA:** barra lateral com Nova conversa, pesquisa de conversas, histórico e arquivo. O menu … permite renomear, arquivar/desarquivar e excluir com confirmação. Configurações abre um painel próprio, com Geral, Aparência e Compartilhar. No celular, a barra lateral abre pelo menu e permite rolagem quando necessário. A conversa usa mais área, campo de mensagem separado dos modos e controles acessíveis. Saudações, perguntas e continuação de ajuda são distinguidas dos pedidos de roupa; refinamentos de cor/cabelo preservam o estilo do pedido anterior. Continuam disponíveis os 90 estilos e a criação guiada por orçamento.
- **Histórico privado:** até 20 conversas por jogador, com as últimas 16 mensagens de cada uma. Escritas são agrupadas, sem UpdateAsync por mensagem. O DataStore precisa responder; uma falha é informada e não é tratada como salvamento confirmado. O histórico é vinculado ao UserId da pessoa, independentemente de plano compartilhado. Reabrir o texto não restaura automaticamente os modelos 3D de uma geração antiga.
- **Compartilhar conversa:** o botão no topo abre a confirmação. Criar código público gera uma cópia textual das últimas oito mensagens, filtrada pelo Roblox, válida por sete dias. Selecione/copie o código CH- e envie por sua escolha. Abrir um código lê essa cópia, sem acesso à conta Roblox ou aos outros chats. Se o filtro falhar, não publica. O código não envia mensagens automaticamente para amigos. A conversa compartilhada pode ser continuada como uma cópia privada; o plano antigo compartilhado permanece uma opção separada para quem já o possuía.
- **Truco, baseado na foto 4:** mesa oval verde com borda escura, quatro avatares circulares nas bordas, nomes e indicação de dupla/rivais. Três cartas privadas em leque dentro da composição, cartas públicas menores e identificadas, placar compacto e controles inferiores reduzidos. Em telas largas, Chat e Sair da mesa ficam nas extremidades. Chat tenta abrir o chat nativo e orienta usar o ícone Roblox se a função não estiver disponível. As regras, variantes, turnos, duplas, resposta de dez segundos e compra de visuais continuam as anteriores.
- **HUD e painel de jogador:** botões principais menores, texto mais contido e painel de outro jogador limitado a 430×244, dentro da área segura. A prévia e as quatro ações continuam disponíveis; não foi reduzido o alvo básico de toque dos botões.
- **Mundos:** os seis temas da praça usam materiais lisos, iluminação mais simples e menos realismo. O sétimo, **Vale da aventura**, é uma composição própria com variedade de árvores, lago, caminhos e morros nas bordas, até 620 partes e centro livre. Os outros mantêm orçamento de 300 partes; o chão visual é reutilizado. São temas locais e cenográficos: o relevo decorativo não transforma a área física compartilhada em um percurso de obstáculos.
- **Spawn:** ponto de nascimento visível, com o emblema clássico do Roblox e superfície física. O reaparecimento explícito e a recuperação de quem cai abaixo da praça continuam ativos.
- **Música inicial:** para quem não tem uma última faixa salva, tenta **Pastel Afternoon Piano**, ID **119682972981199**, encontrado na Creator Store. Volume pessoal inicial de 40%; você pode trocar, salvar ou silenciar. Biblioteca inicial procura piano calmo. Encontrar a faixa na loja não garante reprodução na experiência: metadados/conteúdo são verificados e a falha tenta outra música. Uma última escolha salva é preservada.
- **Patrocínio de jogos/comunidades:** cada publicação de usuário continua durando **86.400 segundos, ou 24 horas**, sem renovar ao visualizar. O jogo e a comunidade iniciais da praça mantêm a condição permanente anterior. Na vitrine de itens, uma atualização repetida dentro de 0,8 segundo reutiliza a resposta; publicação/retirada invalida esse cache, evitando o aviso fotografado sem atrasar uma mudança real.
- **Halloween:** acentos mais visíveis, com limite de três camadas decorativas por interface e proteção das cartas/prévias. Configurações → Aparência → Tema oferece **Automático**, **Neutro** e **Halloween ligado**. No automático, termina em **01/11/2026 às 00h de Brasília**, imediatamente após 31/10. É a duração escolhida para este jogo; não uma data universal obrigatória para eventos de outros jogos. A opção manual permite desligar antes ou manter depois.

## O que foi identificado nas fotos

A foto 1 mostra o avatar afundado. As fotos 2–3 mostram 0 erros na contagem, etapas de aplicação/validação, um registro GROUND_REPAIRED e o aviso de atualização rápida do HighlightFeed. As linhas de etapas não demonstram erro de cópia do usuário. A V67 trata o apoio e a atualização repetida; não interpreta todo registro como uma falha. As fotos 4 e 5 orientaram a mudança do truco. A nova composição usa código e elementos próprios; não foi extraída a arte da imagem de referência.

## Fontes consultadas

- [Preload e imagens invisíveis: relato de desenvolvedores e acompanhamento atual](https://devforum.roblox.com/t/contentprovider-doesnt-preload-imagelabels/4039525)
- [Manter imagens carregadas/renderizadas](https://devforum.roblox.com/t/preloading-images-and-keeping-them-loaded/2998098)
- [ImageLabel e IsLoaded](https://create.roblox.com/docs/reference/engine/classes/ImageLabel)
- [ContentProvider e limitações de preload](https://create.roblox.com/docs/reference/engine/classes/ContentProvider)
- [AvatarBackground: leitura no servidor](https://devforum.roblox.com/t/how-to-get-the-image-id-of-an-avatar-background-in-a-local-script/4756010)
- [Humanoid, HipHeight e escalonamento](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
- [Explicação de escalonamento e comprimentos de pernas em Rthro](https://devforum.roblox.com/t/rthro-packages-make-the-position-of-humanoidrootpart-inconsistent-with-avatar-scale-settings-disabled/207610)
- [Animações de personagens e configuração de Animate](https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/play-character-animations)
- [Animação adaptativa e rigs personalizados](https://create.roblox.com/docs/characters/adaptive-animation)
- [ChatGPT desktop: organização dos chats](https://learn.chatgpt.com/docs/projects)
- [ChatGPT desktop: configurações](https://learn.chatgpt.com/docs/app/settings)
- [Floresta estilizada: variação de árvores e composição](https://devforum.roblox.com/t/1-hour-low-poly-forest-showcase/741399)
- [Referências de composição de floresta](https://devforum.roblox.com/t/new-showcase-game/592542)
- [Textura do spawn e referência nativa](https://devforum.roblox.com/t/is-there-a-list-of-roblox-built-in-assets-where-are-some-rbxasset-assets-actually-stored/4309920)
- [Faixa selecionada na Creator Store](https://create.roblox.com/store/asset/119682972981199)
- [Halloween em 31/10/2026](https://www.timeanddate.com/holidays/us/halloween)

## Validação e limites

**84 cenários simulados em Lua 5.4**, **131 fontes efetivas** compiladas, hashes/dependências e JavaScript real do instalador. Incluem a reprodução da falha do probe da V66, cálculo dos pés, tipos de animação/retentativa, histórico/privacidade/filtro/agrupamento de gravações, tema/data e composição do truco em seis geometrias de tela.

Não há Roblox Studio/Player nativo neste ambiente. Os testes não confirmam renderização, FPS, física, deformação de roupas, disponibilidade dos serviços nem a permissão de cada asset real. Não foi feito um teste publicado da combinação fotografada. Não se promete conversar com a capacidade geral do ChatGPT: a IA continua sendo um planejador do catálogo e um guia contextual do jogo, sem chave externa, com interface inspirada na navegação desktop.
