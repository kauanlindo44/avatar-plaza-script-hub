# Instalação V63 — 5 novos + 20 substituições

Requer V62 completa. V63: 5 scripts NOVOS + 20 SUBSTITUIÇÕES. Pare Play, crie primeiro os cinco módulos novos nos locais indicados, substitua as 20 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V63.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G6_WORLD_DETAILS` | ModuleScript | ReplicatedStorage | 39 |
| `07H8_PLAY_SESSION` | ModuleScript | ReplicatedStorage | 51 |
| `09B10_SPONSORED_DESTINATIONS` | ModuleScript | ServerScriptService | 129 |
| `09C11_SPONSOR_FEED` | ModuleScript | ReplicatedStorage | 13 |
| `09C12_DESTINATION_BROWSER` | ModuleScript | ReplicatedStorage | 139 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 65 |
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 132 |
| `07H6_GAME_MOMENTS` | ModuleScript | ReplicatedStorage | 35 |
| `07K4_TRUCO_TABLES` | ModuleScript | ServerScriptService | 19 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 152 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 64 |
| `07P7_ROBLOX_BACKGROUNDS` | ModuleScript | ReplicatedStorage | 34 |
| `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 165 |
| `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 182 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 105 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 129 |
| `01B_HUB_WORLD` | Script | ServerScriptService | 144 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 99 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 248 |
| `07K_TRUCO_SERVER` | Script | ServerScriptService | 277 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 141 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 171 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 260 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 86 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 111 |

## O que mudou

IA e música receberam layouts novos, com hierarquia clara, controles nomeados e área segura para celular. A IA mostra o fluxo estilo → orçamento → prévia, resultados na conversa, progresso, menu, salvos e recuperação de conexão. Música abre um player flutuante com biblioteca, fila e salvos; os controles de carregar ID/link, reprodução, volume e guardar ficam juntos. A biblioteca continua usando consulta nativa assíncrona/cache, e o volume inicial continua em 40%.

Patrocinar agora separa **Itens, IA, Jogos e Comunidades**. A vitrine de itens permite rolagem horizontal e vertical, além de setas para os lados. Um item publicado ocupa um card temporário; dois ocupam dois. Os demais exemplos pagos permanecem. Categoria e pesquisa continuam disponíveis; no celular deitado o menu de categorias abre pelo botão Itens. O coração diminuiu visualmente e conserva uma área de toque de 44 px.

Jogos começa apenas com `83720142132483`, e Comunidades apenas com `546113316`. Eles são os destaques permanentes da praça, sem exemplos de outros jogos/comunidades. Outros jogadores podem publicar por 24 horas, de graça, um por pessoa em cada categoria. IDs e metadados são conferidos no Roblox; a publicação rejeita uma camisa usada como ID de jogo, por exemplo. Pesquisa, favoritos, curtidas, prévia e entrada são independentes da vitrine de roupas. Curtidas e favoritos são desta vitrine e não alteram as contagens do site Roblox.

A entrada em uma comunidade usa o modal nativo `GroupService:PromptJoinAsync`. Entrar em outro jogo usa teleporte do Roblox, depois de uma confirmação na interface, porque a experiência externa não roda dentro da nossa. O botão Eventos consulta os eventos oficiais **da experiência atual**, conforme o serviço nativo permite. Descrição/aviso público disponível é mostrado; não inventamos eventos ou avisos de comunidades externas. As páginas públicas dos dois IDs não abriram na pesquisa, por isso nome, imagem e descrição são consultados pelos serviços nativos durante a execução.

Os seis mundos são ao ar livre: campo das flores, bosque das cerejeiras, floresta lunar, costa dourada, bosque das lanternas e jardim celeste. O distrito de cidade foi substituído; uma preferência antiga `NEON` abre Floresta lunar. Há materiais nativos de madeira, pedra, areia, vegetação e mármore, pavilhão aberto, ponte, lagos, cascata, coqueiros, dunas, abóboras, arcos, trilhas e detalhes de vegetação. Atmosfera, luz, estrelas, nuvens e cores mudam por tema. Apenas o cenário selecionado fica ativo: limite de 720 partes, construção em lotes, até 12 luzes locais e movimento limitado da água. O chão visual reutiliza 25 partes e o chão físico acompanha os jogadores. O cenário continua sendo visual/local, como combinado.

O reaparecimento usa `SpawnCentral` explicitamente, espera o HumanoidRootPart e calcula uma altura segura considerando HipHeight. Trocar mundo pede o retorno ao centro pelo servidor. Queda abaixo do chão também retorna ao ponto seguro. Personagens recriados para aplicar uma aparência conservam a posição válida no mapa; os scripts de aparência e salvamento anteriores permanecem.

Truco usa salas virtuais, com a mesa da interface em 2D, sem construir assentos ou mover o personagem. Xadrez, dama e Truco acrescentam pequenas metas da sessão baseadas em jogadas reais, captura/vaza e conclusão. O resumo guarda as estatísticas da partida e mantém a revanche/placar de sessão. Essas metas são visuais: não alteram regras, ranking ou ganhos. A intenção é dar continuidade e pequenos momentos de conquista; diversão e aparência precisam ser avaliadas jogando.

HUD recebeu uma engrenagem reconhecível e ícone de avatar enquadrado para o estúdio. A faixa de itens abaixo da prévia do catálogo, os X de remover peças, corpos/camadas e os dados anteriores continuam nos módulos existentes.

## Os erros das fotos

| Erro observado | Causa encontrada | Correção da V63 |
|---|---|---|
| `09I3_OUTFIT_BUILDER:19: attempt to modify a readonly table` | Nosso construtor acrescentava valores diretamente a `CatalogSearchParams.AssetTypes`, cuja tabela retornada é protegida. | Monta uma lista local e atribui o filtro completo uma vez. O teste usa uma tabela que rejeita a mutação, e conclui um pedido de IA com itens/preços verificados. |
| `WaitForChild("ChallengeDistrict")` em `07K_TRUCO_SERVER` | A V62 removeu o distrito físico, mas o servidor do Truco ainda esperava esse objeto. Era uma dependência que ficou nos nossos scripts. | Servidor inicia um conjunto de salas virtuais diretamente no mundo, com `07K4_TRUCO_TABLES` atualizado. |
| Photo Mode pede para substituir módulos já colocados | A interface interrompia o teste por um rótulo exato de versão, antes de consultar imagem e tipo do item. | Usa a capacidade real dos módulos e valida a resposta/imagem do Roblox; rótulo antigo/atrasado não bloqueia uma resposta compatível. |
| Personagem nasce/volta embaixo | Spawn não estava vinculado explicitamente ao jogador; salas antigas do Truco também moviam personagens para fora do campo. | RespawnLocation, espera do personagem, altura segura, proteção contra queda e Truco sem assentos físicos. |

Esses erros identificados são dos scripts; as fotos não são evidência de que você copiou errado. Ao instalar, use as fontes completas e reinicie Play para o Roblox executar os módulos novos.

A IA é um assistente de looks com planejamento por estilos e busca no catálogo, sem chave OpenAI e sem TextGenerator. Ela verifica tipo, orçamento, preço atual e carregamento do avatar antes de entregar. Ajuda geral continua limitada às funções do jogo. Os planos/recibos antigos, produtos e o único ProcessReceipt continuam nos scripts anteriores; **não crie novos passes ou produtos** para a V63.

## Conferir no Roblox

1. Pare Play. Crie primeiro os cinco módulos NOVOS nos locais da tabela. Substitua as vinte instâncias existentes, mantendo exatamente o nome/tipo/local. Remova somente uma eventual cópia duplicada dessas mesmas instâncias, caso você a tenha criado; não apague outros módulos. Reinicie Play.
2. Em IA, peça `Quero um look emo preto`, escolha o orçamento e confirme. Confira a resposta, prévia e itens. Output deve mostrar `[IA V63] servidor=V63 motor=V62 protocolo=2`; motor V62 com protocolo 2 é compatível e esperado, pois o planejador não precisou mudar. O construtor agora é V63. Se o catálogo falhar, o pedido deve dar erro e devolver o limite, sem aplicar nada.
3. Abra fundos do Photo Mode. Teste um fundo da loja e um emote na cópia. Um rótulo de versão não deve mais pedir substituição. Permissão/moderação/imagem continuam sendo decisões do Roblox; se a imagem isolada não carregar, pode aparecer a prévia oficial da loja, identificada como tal.
4. Abra Patrocinar. Publique um item pago em uma conta e outro em uma segunda conta: cada um substitui um exemplo, mantendo os demais. Teste categoria, nome/ID, rolagem nos dois sentidos e favorito.
5. Em Jogos/Comunidades confira os seus IDs. Teste conferir um link, publicar, pesquisar, favoritar, curtir na vitrine e o modal de comunidade. Teleporte para outra experiência precisa de teste no jogo publicado; disponibilidade, elegibilidade e permissões são controladas pelo Roblox. A API de eventos mostra eventos cadastrados da experiência atual; caso não haja nenhum, a interface informa isso.
6. Entre em cada mundo, ande além da região inicial, volte, troque novamente, morra e reapareça. Confira memória/FPS no seu celular, posição segura e conservação da aparência aplicada. Teste também o gato de abacaxi no catálogo, no mapa, depois da morte e ao retornar ao jogo.
7. Teste música em pé/deitado: biblioteca antes do ID, fila, salvar, carregar/recarregar, anterior/próxima, volume, mudo e minimizar. Áudio sem permissão deve exibir falha, sem ficar carregando indefinidamente.
8. Com duas pessoas, teste xadrez/damas; confira peças após jogadas. Em Truco teste sala/duplas/partida e revanche, sem teleporte físico. Metas e resumo devem acompanhar jogadas reais e não substituir os controles normais.

O projeto continua com classificação/availability 16+ configurada no Creator Dashboard, fora destes scripts. Fontes legadas `07P1_CAPTURE_ENGINE` e `08L_COMMUNITY`, já presentes no projeto, continuam necessárias.

## Validação e fontes

32 cenários passaram em Lua 5.4 com doubles, incluindo os controladores de IA/música/jogos, listas readonly, substituição exata de exemplos, publicação/paginação/favoritos, resposta de IA, reaparecimento e geometria em seis tamanhos. A auditoria também verifica sintaxe/dependências/hashes e o JavaScript real do instalador. Esses testes não executam o motor Roblox, seus serviços reais ou sua renderização; não representam garantia de FPS ou de preferência visual.

Consultas a fontes primárias Roblox:

- [CatalogSearchParams e tabelas somente leitura](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams)
- [GroupService: dados e PromptJoinAsync](https://create.roblox.com/docs/reference/engine/classes/GroupService)
- [SocialService: eventos da experiência atual](https://create.roblox.com/docs/reference/engine/classes/SocialService)
- [Player.RespawnLocation](https://create.roblox.com/docs/reference/engine/classes/Player)
- [GameThumbnail por PlaceId e tamanhos suportados](https://create.roblox.com/docs/projects/assets)
- [MarketplaceService.GetProductInfoAsync](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [Catalog Avatar Creator oficial](https://www.roblox.com/games/7041939546/Catalog-Avatar-Creator): experimentar, guardar e descobrir looks. As mudanças conectam criação, salvos, prévia e descoberta da nossa vitrine, sem prometer o volume de outfits do outro jogo.
