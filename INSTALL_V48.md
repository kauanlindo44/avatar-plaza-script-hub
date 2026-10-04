# Instalação V48 — Studio Lite

Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. SUBSTITUA estes 36 scripts nas instâncias existentes, sem duplicar nomes. A V48 inclui V45, V46 e V47; não precisa instalá-las separadamente. Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. Se ainda estiver instalando a V44, termine os 55 itens primeiro. 09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V48, em ordem, no MESMO ModuleScript. Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. Quem já terminou a V47 pode substituir apenas os 19 nomes da lista de diferenças em INSTALL_V48.md. IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V48.md.

Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. **0 scripts NOVOS**. O HTML contém V44 e V48 offline e preserva o histórico online. Preserve as dependências da [V44](INSTALL_V44.md). Os identificadores VERSION V41/V44 internos são contratos de compatibilidade.

## Se já terminou a V47

Substitua somente estes **19 scripts** pela fonte V48. Pare Play antes. Use as mesmas instâncias, tipos e locais da tabela abaixo; apague a fonte antiga uma vez e cole todas as partes do script.

- `07G_HUB_UI` — **SUBSTITUIR**
- `07H1_GAME_LOBBY` — **SUBSTITUIR**
- `07K5_TRUCO_UI` — **SUBSTITUIR**
- `07K6_CARD_CATALOG` — **SUBSTITUIR**
- `07K7_CARD_STYLES` — **SUBSTITUIR**
- `07K9_CARD_INVENTORY_UI` — **SUBSTITUIR**
- `07K_TRUCO_CLIENT` — **SUBSTITUIR**
- `07P4_STUDIO_UI` — **SUBSTITUIR**
- `07P6_STUDIO_SETS` — **SUBSTITUIR**
- `07P_PHOTO_MODE` — **SUBSTITUIR**
- `08B_AVATAR_DATA` — **SUBSTITUIR**
- `09A1_SHOP_LAYOUT` — **SUBSTITUIR**
- `09A2_PREVIEW_LAYOUT` — **SUBSTITUIR**
- `09B1_AVATAR_DISCOVERY` — **SUBSTITUIR**
- `09C2_SHOP_CATALOG` — **SUBSTITUIR**
- `09C5_UGC_STORES` — **SUBSTITUIR**
- `09C7_COMMUNITY_FEED` — **SUBSTITUIR**
- `09C8_COMMUNITY_DETAILS` — **SUBSTITUIR**
- `09C_SHOP_CLIENT` — **SUBSTITUIR**

## Pacote completo de substituições desde V44

Se está na V44/V45 ou não sabe quais correções já instalou, substitua os **36** nomes desta tabela. A V48 contém as correções anteriores.

| Nome | Ação | Tipo | Local | Linhas | Partes |
|---|---|---|---|---:|---:|
| `07H1_GAME_LOBBY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 171 | 2 |
| `07K0_TRUCO_RULES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 164 | 2 |
| `07K12_TOURNAMENT_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 58 | 2 |
| `07K5_TRUCO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 145 | 2 |
| `07K6_CARD_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 37 | 2 |
| `07K7_CARD_STYLES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 132 | 2 |
| `07K9_CARD_INVENTORY_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 318 | 2 |
| `07P0_STUDIO_PRESETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 20 | 2 |
| `07P2_STUDIO_AVATAR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 188 | 2 |
| `07P3_POSE_EDITOR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 69 | 2 |
| `07P4_STUDIO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 115 | 2 |
| `07P5_POSE_CANVAS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 162 | 2 |
| `07P6_STUDIO_SETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 135 | 2 |
| `07UI_DESIGN_SYSTEM` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 154 | 2 |
| `07UI_SCREEN_BOUNDS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 36 | 2 |
| `09A1_SHOP_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 130 | 2 |
| `09A2_PREVIEW_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 61 | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 279 | 4 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 248 | 2 |
| `09C7_COMMUNITY_FEED` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 130 | 2 |
| `09C8_COMMUNITY_DETAILS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 146 | 2 |
| `07K2_TRUCO_MATCH` | SUBSTITUIR | ModuleScript | ServerScriptService | 70 | 2 |
| `07K4_TRUCO_TABLES` | SUBSTITUIR | ModuleScript | ServerScriptService | 47 | 2 |
| `07K8_CARD_INVENTORY` | SUBSTITUIR | ModuleScript | ServerScriptService | 146 | 2 |
| `09B1_AVATAR_DISCOVERY` | SUBSTITUIR | ModuleScript | ServerScriptService | 129 | 2 |
| `09B2_COSPLAY_METADATA` | SUBSTITUIR | ModuleScript | ServerScriptService | 40 | 2 |
| `09B4_CURATED_LOOKS` | SUBSTITUIR | ModuleScript | ServerScriptService | 140 | 2 |
| `07G_HUB_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 105 | 2 |
| `07H_GAME_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 192 | 2 |
| `07K_TRUCO_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 83 | 2 |
| `07K_TRUCO_SERVER` | SUBSTITUIR | Script | ServerScriptService | 237 | 2 |
| `07P_PHOTO_MODE` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 175 | 2 |
| `09B_SHOP_SERVER` | SUBSTITUIR | Script | ServerScriptService | 211 | 2 |
| `09C_SHOP_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 366 | 2 |
| `08B_AVATAR_DATA` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 370 | 2 |
| `09C5_UGC_STORES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 71 | 2 |

## Conferência no jogo

1. Jogos: escolha Xadrez, Damas e Truco no topo. Confira Partida rápida, Criar / entrar, Contra bots, três dificuldades, código e Cancelar espera em retrato/paisagem. O painel preto/verde deve ocupar a altura disponível sem sobrepor controles nativos.
2. Truco 2D: veja as quatro posições públicas da mesa, suas três cartas, placar e ações inferiores. Jogue qualquer carta própria na sua vez; teste Truco, Correr, carta coberta, variantes e gritos. Nenhuma carta privada adversária pode aparecer. Não deve existir câmera dentro do rosto ou mão 3D na tela.
3. Baralhos: caixas Nox/Reign/Eclipse têm embalagem própria. Antes de pagar, veja os três visuais e escolha um; cada opção mostra 100% ao escolher, sem sorteio. Após a confirmação efetiva do servidor, o visual escolhido deve aparecer recebido; cancelar a compra não entrega nada. Veja todas as frentes/versos e Meus visuais. Uma caixa já existente pode ser aberta pelo inventário.
4. Ateliê: cole um ID/link de Image ou Decal publicado, pressione Carregar e confira sucesso verde ou falha vermelha. Uma falha genérica pode ser permissão, moderação ou conexão; o aviso não deve afirmar uma causa que o Roblox não informou. Teste Recarregar, zoom, arraste, frente/verso e Salvar e equipar. Cliente e servidor devem estar ambos atualizados. Carregamento de Decal respeita permissões nativas e não habilita importação de modelos de terceiros.
5. Catálogo: confira SUBCATEGORIA destacado, corpos pagos primeiro, CORPOS GRÁTIS e MEMES / CRIATURAS. Teste um corpo de proporções incomuns na prévia 360 graus e no personagem do jogo. Roupa aplicada não deve apagar acessórios não editados. Confira também as duas linhas, faixa inferior, carrinho e X de remoção.
6. Limiteds: o botão antigo de Lojas UGC agora abre Limiteds, com aparência dourada e cards horizontais. Busca, Popular / Menor preço e Carregar mais só devem mostrar itens comprovadamente Limited/Collectible. Uma consulta sem resultados pode ficar vazia, sem inserir itens comuns.
7. Comunidade: confira Todos, Robux, Grátis e Publicados, até três colunas e duas linhas maiores e Carregar mais. Após falha temporária, deve haver nova tentativa sem apagar looks já carregados. Ao abrir um look, veja itens com imagem e nome; toque no item para preço, descrição, Experimentar e Carrinho. Teste X de fechar/remover e rotação da prévia.
8. Photo Mode: abra cada ferramenta lateral. Em R15, escolha um emote e veja o avatar no cenário se mover; pare/congele e edite a pose. Teste Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma, rotação, luz, pausar cenário, ocultar UI e sair. Ao fechar ferramentas, não deve permanecer um bloco inferior com o nome do fundo. Estes cinco cenários são originais; a pesquisa pública não encontrou cinco fotos verificáveis de cada fundo do CAC.

Os 77 testes são simulados, exceto a execução real do JavaScript do instalador. Renderização, toque físico, imagens aprovadas, emotes e compras exigem teste no Roblox/Studio Lite/place publicado. Esta atualização não faz compras nem muda preços do painel.
