# Instalação V65 — 2 novos + 18 substituições

Requer V64 completa. V65: 2 módulos NOVOS em ReplicatedStorage + 18 SUBSTITUIÇÕES. Pare Play, crie primeiro 07UI_PAN_GRID e 08B6_AVATAR_MOVEMENT como ModuleScript em ReplicatedStorage, substitua as fontes completas e reinicie. Não use NOVO/SUBSTITUIR no nome. Nenhum passe/produto novo. Guia: INSTALL_V65.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07UI_PAN_GRID` | ModuleScript | ReplicatedStorage | 41 |
| `08B6_AVATAR_MOVEMENT` | ModuleScript | ReplicatedStorage | 71 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 111 |
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 65 |
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 67 |
| `07G6_WORLD_DETAILS` | ModuleScript | ReplicatedStorage | 37 |
| `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 201 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 64 |
| `07M2_AUDIO_LIBRARY` | ModuleScript | ServerScriptService | 62 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 244 |
| `07P3_POSE_EDITOR` | ModuleScript | ReplicatedStorage | 70 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 216 |
| `09C12_DESTINATION_BROWSER` | ModuleScript | ReplicatedStorage | 149 |
| `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 183 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 153 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 123 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 98 |
| `07G_SETTINGS_SERVER` | Script | ServerScriptService | 54 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 157 |
| `09C11_AVATAR_CHARACTER` | LocalScript | StarterPlayer > StarterPlayerScripts | 58 |

## Instalar

1. Pare Play. Crie **07UI_PAN_GRID** e **08B6_AVATAR_MOVEMENT** como **ModuleScript em ReplicatedStorage**. NOVO é apenas uma indicação no instalador: não acrescente isso ao nome da instância.
2. Substitua a fonte inteira das 18 instâncias existentes listadas acima. Não deixe duplicatas. O `09A_SHOP_UI` continua nas mesmas quatro partes e não entra nesta atualização.
3. Reinicie Play. Esta versão pressupõe a V64 completa; não remova scripts anteriores que não aparecem na lista. Os mesmos DataStores, looks, códigos, permissões e recibos permanecem em uso. Nenhum passe, produto ou textura externa nova precisa ser criado.

## Conferir no Roblox publicado

- **Corpos:** entre com o avatar habitual e experimente corpos de alturas diferentes, roupas em camadas e o fato de gato de abacaxi. O novo avatar usa a altura de apoio do Humanoid gerado pelo Roblox, fica ereto e não herda velocidade/inclinação do anterior. Um acessório grande não é usado como medida da perna. Há duas verificações após a criação; não existe teleporte a cada frame. A câmera continua respeitando o estúdio e os jogos. Diagnóstico: atributo `ACP_MovementStage` no personagem e `[Avatar V65] ... | MOVEMENT | 08B6_AVATAR_MOVEMENT` quando um apoio precisa de correção. Falhas de estrutura/aparência continuam com as etapas/trace da versão anterior e preservam o último corpo confirmado. Sem o ID do corpo fotografado não é possível confirmar aquela combinação específica aqui.
- **Photo Mode:** abra antes e depois do catálogo. Teste um emote da loja, velocidade, loop, parar, repetir o mesmo emote e editar a pose. As AnimationConstraints da cópia permanecem cinemáticas durante o Animator; o editor deixa de sobrescrever a transformação enquanto a animação toca. Repetir um emote já registrado reutiliza o modelo. A confirmação exige uma AnimationTrack com duração carregada; recusa, duração zero e timeout preservam a cópia anterior. Diagnóstico: `[Photo V65] EMOTE_PLAY`. Fundos continuam sendo itens da loja Roblox para testar/comprar; a foto usa o mecanismo de captura da V64.
- **Música:** a primeira faixa sugerida que não carrega é pulada automaticamente; há no máximo oito tentativas iniciais. Selecionar um ID manualmente mantém a escolha da pessoa. O player só informa sucesso depois de terminar o preload e confirmar carregamento/duração. Se falhar, use Recarregar ou outra faixa. Sem ID, Recarregar pede nova consulta da biblioteca. Volume pessoal inicial de 40%, fila e salvos preservados. Logs: `[Music V65] METADATA` ou `CONTENT_LOAD` com ID/estado nativo. Encontrar metadados de áudio não concede permissão para reproduzi-lo.
- **Patrocinar:** jogos e comunidades têm canvas realmente maior nos dois eixos, duas linhas quando há espaço e registros suficientes, rolagem nativa no celular, arraste com mouse e setas. Soltar um arraste não abre um card sem querer. O cabeçalho aproveita a mesma faixa das categorias em paisagem. Inicialmente aparece somente seu jogo **83720142132483** e sua comunidade **546113316**, cada qual na sua seção; não há preenchimento fictício para jogos/grupos. Itens preservam exemplos temporários e substituição de um exemplo por cada publicação real. Compra/favoritos/publicação continuam com validação no servidor.
- **IA:** para um look completo, camisa e calça são priorizadas no orçamento; cabelo e acessórios vêm depois. Uma combinação sem parte de cima ou de baixo não é apresentada como completa. Com Manter avatar, peças já vestidas podem completar a combinação; o preço exibido continua sendo o das peças novas. Preços e aparência são reconferidos. O assistente continua sendo um planejador específico do catálogo, sem chave OpenAI, sem prometer reconhecer qualquer personagem ou conversar como um modelo geral.
- **Interfaces:** teste celular em pé/deitado. O salão possui mesas ilustradas, ações separadas e o perfil escolhido em destaque; regras, dificuldades reais, salas, duplas, moedas e revanche continuam as anteriores. Configurações fica menor e mantém toque de pelo menos 44px. O círculo de restaurar saiu do HUD; **Restaurar permanece dentro do editor com confirmação**. A comunidade mantém Todos/Grátis, códigos e janela de 100 registros/50 slots; o cabeçalho em paisagem libera mais altura para as skins.
- **Mapas:** os seis temas são composições próprias para montar looks e socializar. O centro é plano e desimpedido; árvores, flores e detalhes ficam nas bordas. Foram retirados morros, montanhas, pontes, pavilhões, arcos e construções. Materiais nativos, luz/céu e cores variam por tema. Até 520 partes de cenário, 25 de chão visual reutilizadas e no máximo oito luzes; a área física e o reaparecimento continuam sob controle do servidor. A composição original não representa garantia jurídica contra qualquer reclamação.

## Sobre as fotos

As 11 fotos foram lidas. As dez fotos do console mostram **0 erros e 5 avisos**, incluindo `FoundationProvider not found` em `CorePackages/UIBlox` do Roblox. Essa pilha não demonstra uma linha de erro dos scripts do projeto. A última foto mostra um avatar em posição anormal; ela motivou a verificação de apoio, inclinação, movimento e animação. Não se modifica código interno do Roblox nem se promete remover os avisos do UIBlox. O crescimento de memória entre fotos, isoladamente, não comprova um vazamento neste projeto.

## Documentação consultada

- [AnimationConstraint: juntas cinemáticas e animação](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint)
- [Constraints de animação](https://create.roblox.com/docs/physics/constraints/animation)
- [Humanoid e HipHeight](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
- [Animator](https://create.roblox.com/docs/reference/engine/classes/Animator)
- [Áudio: uso e permissões](https://create.roblox.com/docs/audio/assets)
- [Referência geral: Catalog Avatar Creator](https://www.roblox.com/games/7041939546/Catalog-Avatar-Creator)

## Validação e limites

**48 cenários simulados** em Lua 5.4, seis geometrias de tela, seis paisagens e **122 fontes efetivas** verificadas. Incluem controladores reais da IA, música e Photo Mode sob doubles, rollback de avatar, navegação/gestos, persistência/cache, regras/sessão e o JavaScript real do instalador. Isso não executa o motor Roblox. Renderização, FPS, colisões físicas reais, deformação de malhas/cages, áudio/emotes privados e sensação dos jogos precisam ser confirmados no aplicativo publicado. Os novos materiais são nativos e não dependem de subir imagens para funcionar.
