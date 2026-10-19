# Instalação V71 — 1 novo + 31 substituições

Base: V69 completa, por pedido do responsável. A V70 NÃO é necessária. V71: 1 ModuleScript NOVO + 31 SUBSTITUIÇÕES. Pare Play, crie primeiro o módulo novo, substitua as fontes completas e reinicie após terminar. NOVO/SUBSTITUIR não fazem parte do nome. Nenhum produto, passe, chave ou upload novo. Guia: INSTALL_V71.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `09I20_ASSISTANT_APPEARANCE` | ModuleScript | ReplicatedStorage | 40 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 69 |
| `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 201 |
| `07H2_GAME_BOARD` | ModuleScript | ReplicatedStorage | 177 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 113 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 173 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 69 |
| `07M2_AUDIO_LIBRARY` | ModuleScript | ServerScriptService | 62 |
| `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 166 |
| `07UI_HALLOWEEN_THEME` | ModuleScript | ReplicatedStorage | 120 |
| `07UI_SURFACE_EFFECTS` | ModuleScript | ReplicatedStorage | 65 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 193 |
| `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 64 |
| `09A4_UTILITY_SKIN` | ModuleScript | ReplicatedStorage | 70 |
| `09B10_SPONSORED_DESTINATIONS` | ModuleScript | ServerScriptService | 155 |
| `09C12_DESTINATION_BROWSER` | ModuleScript | ReplicatedStorage | 163 |
| `09C16_CATALOG_HOME` | ModuleScript | ReplicatedStorage | 72 |
| `09C1_SHOP_LOOKS` | ModuleScript | ReplicatedStorage | 214 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 280 |
| `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 183 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 133 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 153 |
| `09C8_COMMUNITY_DETAILS` | ModuleScript | ReplicatedStorage | 149 |
| `09C9_PLAYER_INSPECT` | ModuleScript | ReplicatedStorage | 70 |
| `09I10_CHAT_NAV` | ModuleScript | ReplicatedStorage | 84 |
| `09I13_OUTFIT_SEARCH` | ModuleScript | ServerScriptService | 66 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 118 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 134 |
| `09I5_ASSISTANT_QUESTIONNAIRE` | ModuleScript | ReplicatedStorage | 108 |
| `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 132 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 98 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 169 |

## Instalar diretamente sobre a V69

1. Pare Play. A **V69 precisa estar completa**. A V70 não é necessária.
2. Crie **um ModuleScript** chamado `09I20_ASSISTANT_APPEARANCE` em **ReplicatedStorage** e copie sua fonte inteira.
3. Substitua as **31 fontes existentes** da tabela, nos tipos e locais indicados. Não crie cópias duplicadas e não acrescente NOVO/SUBSTITUIR ao nome.
4. Reinicie somente após terminar o conjunto.

A publicação se chama V71 porque a V70 já existia no GitHub; **o ponto de partida desta atualização é a V69**, como você pediu. A V70 foi mantida no histórico. O delta cobre também as instâncias que ela alterava, para o resultado ser consistente se alguém chegou a instalá-la. Não é necessário instalá-la primeiro.

`09A_SHOP_UI` permanece nas quatro partes anteriores. O instalador mostra nome, tipo, local, última linha e **Copiar script inteiro**, com duas partes opcionais. Nenhum passe, produto, chave externa, envio de imagem ou serviço pago novo.

## Referências aplicadas

Foram abertas as **18 imagens enviadas**. O mapeamento foi feito pelo conteúdo, pois a numeração escrita no pedido não coincide com a ordem de todos os anexos:

- As nove primeiras imagens mostram o jogo atual.
- As seis capturas seguintes mostram HUD, categorias, loja, emotes, looks e configurações do Catalog Avatar Creator.
- `images.png`: tabuleiro de xadrez verde e creme.
- `images(20261019-174911).jpg`: damas tradicionais, com peças vermelhas e escuras.
- `image(20261019-175102).png`: conversa clara, menu estreito à esquerda e compositor central, usada como referência para o assistente.

As interfaces foram escritas neste projeto. Não foram extraídos scripts, logos, mapas ou modelos de outros jogos. Imagens de avatar/produto usam thumbnails nativos do Roblox; categorias também têm ilustrações em formas nativas como fallback. Não há promessa de cópia pixel a pixel entre resoluções diferentes.

## O que mudou

**HUD e catálogo:** painéis grafite, botões de entrada mais contidos e categorias em um mosaico: destaque alto, cabelos e roupas no meio, Halloween e rostos à direita e acessórios na base. Corpos, emotes e favoritos continuam acessíveis. No celular pequeno o mosaico se reorganiza em uma grade legível. A prévia à esquerda tem cenário grafite fixo, luz frontal clara e blocos discretos; arrastar gira somente o avatar. Os itens equipados com X continuam abaixo da prévia. A praça clássica tem piso neutro quadriculado; os outros mundos da V69 permanecem.

**Xadrez e damas:** apresentação tradicional com borda, sombra e peças em formas nativas com relevo. Xadrez em verde/creme e damas com casas bege/azul acinzentado, peças vermelhas e escuras. Tabuleiro central, alvos e relógios preservados. Nenhuma alteração em regras, bots, turnos, pontuação ou tempos. Truco e demais painéis recebem ajustes de contraste para combinar com o catálogo, sem mudança de lógica.

**Assistente:** área clara independente do catálogo, trilho de ícones estreito no computador, histórico recolhível, duas entradas superiores para Conversa/Looks, mensagens com mais espaço e campo central ao iniciar uma conversa. Depois da primeira mensagem, o campo fica embaixo. O + abre criação, ? abre ajuda e a seta envia. Histórico, compartilhar, conta, salvos e criar com amigos continuam sendo funções reais. A identidade e as funções são do jogo; não se adicionaram botões de voz ou modelos externos sem implementação.

**Pedido em três etapas:** Estilo, Orçamento e Peças. É possível voltar ou escolher uma etapa, conferir o resumo e só então enviar. O orçamento continua por look, a quantidade respeita o plano e as exclusões permanecem explícitas. Um novo pedido começa com seus próprios campos, sem herdar silenciosamente o estilo anterior. O montador agora prioriza sinais de coleção/tema compartilhados entre as peças escolhidas, preservando cor, orçamento, roupas completas e validação nativa. Esse critério compara os nomes e metadados dos produtos; não é reconhecimento visual infalível nem uma IA geral do ChatGPT.

**Patrocinar:** acabamento grafite, cards maiores em jogos/comunidades, favoritos e navegação nos dois eixos mantidos. A cada **900 segundos**, enquanto a vitrine está aberta, o cliente solicita a renovação de imagens/metadados; ao reabrir, a listagem consulta o cache válido do servidor. Busca, favoritos e posição de rolagem são preservados. As publicações continuam por **24 horas**.

As leituras de mídia usam cache compartilhado e até quatro consultas nativas simultâneas, sem regravar os destaques em DataStore. Na renovação de thumbnail de jogo, alternam-se cinco tamanhos oficialmente aceitos de `GameThumbnail`, evitando parâmetros inventados na URL. O emblema da comunidade é consultado novamente em `GroupService`. Se uma consulta falha, a imagem anterior fica e há nova tentativa com intervalo. A propagação final de uma imagem recém-enviada continua dependendo do processamento/cache do Roblox; o relógio de 15 minutos não pode forçar a CDN a publicar uma imagem ainda indisponível.

**Música:** o player normal tem no máximo **420 × 254**, respeitando a área segura. Biblioteca, ID/link e modo mínimo são escolhas separadas. O modo mínimo mantém um botão de ouvir/pausar real. A biblioteca começa com sugestões conhecidas enquanto a busca nativa atualiza. A trilha inicial é bossa/lounge, seguida de alternativas de jazz; o volume pessoal de 40%, salvos e fallback continuam. Preferências pessoais são preservadas; o antigo áudio padrão foi substituído pelo novo padrão quando ainda estava selecionado como padrão.

Sugestões iniciais consultadas na Creator Store:

- [Fall in Love — 1837379560](https://create.roblox.com/store/asset/1837379560/Fall-in-Love), APMOfficial, coleção de bossa/lounge.
- [Sunday Jazz (B) — 1840917953](https://create.roblox.com/store/asset/1840917953).
- [Mellow — 1845756152](https://create.roblox.com/store/asset/1845756152/Mellow).

A permissão real de reprodução é conferida pelo carregamento do Roblox. Uma faixa negada não é apresentada como tocando; o fallback tenta outra. Não há cobrança nova para esses scripts.

## Preservado

Quatro atividades da V69, consentimento e créditos do remix, canais oficiais isolados por partida, dados e códigos existentes, catálogo/carrinho, regras dos jogos, avatares, produtos, planos e recibos. A atualização não modifica os reparos físicos da V69 nem promete resolver malhas/cages defeituosos apenas com design.

O princípio **BUSCAR O EQUILÍBRIO ENTRE EXCESSO E FALTA** e as suas definições de “legal” e “lindo” permanecem em [DIRETRIZES_VISUAIS.md](DIRETRIZES_VISUAIS.md).

## Verificação

**134 cenários simulados**: os 126 anteriores, com expectativas visuais ajustadas ao novo pedido, mais oito cenários da V71. Foram verificados o formulário de três etapas, reset de conversa, combinação entre roupas, renovação nativa das mídias, agendamento de 900 segundos, preservação de filtros/rolagem, música compacta e peças clássicas. As regras e fontes de servidor das partidas permanecem idênticas à V69.

**147 fontes efetivas compiladas**, hashes e dependências conferidos, históricos preservados, proprietário único de recibos e JavaScript real de cópia/offline do instalador. Layouts extraídos do código conferidos em computador, celular em pé/deitado e sete geometrias nos testes, incluindo teclado. As imagens de auditoria são reconstruções com assets ilustrativos, não screenshots nativos do Roblox.

**Ainda precisa de teste no Roblox publicado:** renderização real, tamanhos de fonte, toque/teclado, qualidade dos thumbnails e propagação após trocar ícone/emblema, áudio e permissão dos assets, física/FPS, duas contas conversando em mesas separadas e fluxo das atividades. Não há Roblox Studio/Player neste ambiente.

## Documentação primária consultada

- [Roblox: esquemas de assets e tamanhos de rbxthumb](https://create.roblox.com/docs/projects/assets)
- [MarketplaceService: metadados nativos](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [GroupService: comunidades e emblemas](https://create.roblox.com/docs/reference/engine/classes/GroupService)
- [Áudio e permissões](https://create.roblox.com/docs/audio/assets)
- [Thumbnails e processamento de imagens](https://create.roblox.com/docs/production/publishing/thumbnails)
