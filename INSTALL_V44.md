# Instalação V44 — Studio Lite

Requer V43 completa e os scripts originais do handoff já instalados. Pare Play. CRIE 22 instâncias e SUBSTITUA 33 nos locais indicados, sem duplicar nomes. Os títulos mostram (NOVO) ou (SUBSTITUIR); não inclua essas indicações no nome da instância. 07A_CHESS, 07B_CHECKERS, 07C_POISON_POTATO e 07W_WINS_SERVICE SUBSTITUEM os originais que já existem no jogo, embora apareçam pela primeira vez neste repositório. 07C_POISON_POTATO agora desativa o jogo antigo; não mantenha sua cópia ativa. Mantenha as regras 07A0/07B0 originais no ServerScriptService e as cópias em ReplicatedStorage. 09A_SHOP_UI: apague o código antigo uma vez e cole exatamente as 4 partes, em ordem, no MESMO ModuleScript. Instale os 55 itens antes de Play. Passes usam os IDs informados e o preço atual do Roblox, inclusive 1 Robux durante seu teste. Os dez Developer Products estão configurados; Éter Visual foi excluído. Caixas oferecem escolha garantida, sem sorteios. Consulte INSTALL_V44.md e audits/V44/README.md.

## Antes de instalar

Faça uma cópia do seu place e pare Play. Esta é uma atualização da V43, não um projeto vazio. A V43 depende da V42 e dos scripts originais do handoff. Preserve `08B_AVATAR_DATA` e `08D_SKIN_STATE` V41, `08L_COMMUNITY`, `07P1_CAPTURE_ENGINE`, `07H2_BOT_CLIENT`, `07H3_CROSS_SERVER_ROOMS`, `07Z_BOARD_VISUALS`, as regras 07A0/07B0 nos dois locais indicados na V37 e a base que cria `PracaKit`.

No instalador, abra V44 e copie cada parte no tipo e local da tabela. Para SUBSTITUIR, use a instância existente e apague sua fonte antiga antes de colar. Para CRIAR, crie uma única instância com o nome exato. Partes consecutivas pertencem à mesma instância.

Os sete módulos mantidos com a mesma fonte da V43 também estão no pacote para facilitar uma instalação coerente. O carrinho e Plus não precisam de passe adicional.

## Os 55 scripts

| Ação | Nome | Tipo | Local | Linhas |
|---|---|---|---|---:|
| SUBSTITUIR | `07G1_HUB_SETTINGS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 97 |
| SUBSTITUIR | `07G2_LOCAL_WORLDS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 84 |
| CRIAR | `07G3_PERSONAL_TOOLS` **(NOVO)** | ModuleScript | ReplicatedStorage | 38 |
| SUBSTITUIR | `07H1_GAME_LOBBY` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 89 |
| SUBSTITUIR | `07H4_BOT_ENGINE` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 96 |
| CRIAR | `07K0_TRUCO_RULES` **(NOVO)** | ModuleScript | ReplicatedStorage | 163 |
| CRIAR | `07K12_TOURNAMENT_UI` **(NOVO)** | ModuleScript | ReplicatedStorage | 58 |
| CRIAR | `07K1_TRUCO_AI` **(NOVO)** | ModuleScript | ReplicatedStorage | 45 |
| CRIAR | `07K5_TRUCO_UI` **(NOVO)** | ModuleScript | ReplicatedStorage | 96 |
| CRIAR | `07K6_CARD_CATALOG` **(NOVO)** | ModuleScript | ReplicatedStorage | 37 |
| CRIAR | `07K7_CARD_STYLES` **(NOVO)** | ModuleScript | ReplicatedStorage | 42 |
| CRIAR | `07K9_CARD_INVENTORY_UI` **(NOVO)** | ModuleScript | ReplicatedStorage | 184 |
| SUBSTITUIR | `07P0_STUDIO_PRESETS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 20 |
| SUBSTITUIR | `07P2_STUDIO_AVATAR` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 146 |
| SUBSTITUIR | `07P3_POSE_EDITOR` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 51 |
| SUBSTITUIR | `07P4_STUDIO_UI` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 88 |
| SUBSTITUIR | `07P5_POSE_CANVAS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 128 |
| SUBSTITUIR | `07P6_STUDIO_SETS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 67 |
| SUBSTITUIR | `07UI_DESIGN_SYSTEM` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 151 |
| SUBSTITUIR | `07UI_SCREEN_BOUNDS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 31 |
| SUBSTITUIR | `09A1_SHOP_LAYOUT` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 127 |
| SUBSTITUIR | `09A2_PREVIEW_LAYOUT` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 61 |
| SUBSTITUIR | `09A_SHOP_UI` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 280 |
| CRIAR | `09C10_CONFIRM_ACTION` **(NOVO)** | ModuleScript | ReplicatedStorage | 18 |
| SUBSTITUIR | `09C1_SHOP_LOOKS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 173 |
| SUBSTITUIR | `09C2_SHOP_CATALOG` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 245 |
| SUBSTITUIR | `09C4_OUTFIT_LIBRARY` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 149 |
| SUBSTITUIR | `09C6_AVATAR_PREVIEW` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 95 |
| SUBSTITUIR | `09C7_COMMUNITY_FEED` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 143 |
| SUBSTITUIR | `09C8_COMMUNITY_DETAILS` **(SUBSTITUIR)** | ModuleScript | ReplicatedStorage | 123 |
| CRIAR | `09C9_PLAYER_INSPECT` **(NOVO)** | ModuleScript | ReplicatedStorage | 21 |
| CRIAR | `07K10_CARD_COMMERCE` **(NOVO)** | ModuleScript | ServerScriptService | 76 |
| CRIAR | `07K11_GAMES_PROGRESS` **(NOVO)** | ModuleScript | ServerScriptService | 47 |
| CRIAR | `07K13_TOURNAMENT_SERVICE` **(NOVO)** | ModuleScript | ServerScriptService | 212 |
| CRIAR | `07K2_TRUCO_MATCH` **(NOVO)** | ModuleScript | ServerScriptService | 64 |
| CRIAR | `07K3_TRUCO_DIRECTORY` **(NOVO)** | ModuleScript | ServerScriptService | 94 |
| CRIAR | `07K4_TRUCO_TABLES` **(NOVO)** | ModuleScript | ServerScriptService | 44 |
| CRIAR | `07K8_CARD_INVENTORY` **(NOVO)** | ModuleScript | ServerScriptService | 144 |
| SUBSTITUIR | `07W_WINS_SERVICE` **(SUBSTITUIR)** | ModuleScript | ServerScriptService | 60 |
| SUBSTITUIR | `09B1_AVATAR_DISCOVERY` **(SUBSTITUIR)** | ModuleScript | ServerScriptService | 88 |
| SUBSTITUIR | `09B2_COSPLAY_METADATA` **(SUBSTITUIR)** | ModuleScript | ServerScriptService | 31 |
| CRIAR | `09B3_PLAYER_INSPECT` **(NOVO)** | ModuleScript | ServerScriptService | 42 |
| CRIAR | `09B4_CURATED_LOOKS` **(NOVO)** | ModuleScript | ServerScriptService | 65 |
| SUBSTITUIR | `01C_HUB_CHALLENGES` **(SUBSTITUIR)** | Script | ServerScriptService | 197 |
| SUBSTITUIR | `07A_CHESS` **(SUBSTITUIR)** | Script | ServerScriptService | 393 |
| SUBSTITUIR | `07B_CHECKERS` **(SUBSTITUIR)** | Script | ServerScriptService | 376 |
| SUBSTITUIR | `07C_POISON_POTATO` **(SUBSTITUIR)** | Script | ServerScriptService | 4 |
| SUBSTITUIR | `07G_HUB_UI` **(SUBSTITUIR)** | LocalScript | StarterPlayer > StarterPlayerScripts | 105 |
| CRIAR | `07G_SETTINGS_SERVER` **(NOVO)** | Script | ServerScriptService | 37 |
| SUBSTITUIR | `07H_GAME_UI` **(SUBSTITUIR)** | LocalScript | StarterPlayer > StarterPlayerScripts | 192 |
| CRIAR | `07K_TRUCO_CLIENT` **(NOVO)** | LocalScript | StarterPlayer > StarterPlayerScripts | 92 |
| CRIAR | `07K_TRUCO_SERVER` **(NOVO)** | Script | ServerScriptService | 218 |
| SUBSTITUIR | `07P_PHOTO_MODE` **(SUBSTITUIR)** | LocalScript | StarterPlayer > StarterPlayerScripts | 150 |
| SUBSTITUIR | `09B_SHOP_SERVER` **(SUBSTITUIR)** | Script | ServerScriptService | 205 |
| SUBSTITUIR | `09C_SHOP_CLIENT` **(SUBSTITUIR)** | LocalScript | StarterPlayer > StarterPlayerScripts | 358 |

## Compras e primeiro teste

Os passes 1951234105/1962433436/1966813498 estão associados a Ateliê/Regent/Zenith. O código não muda preços no painel Roblox. O criador configurou passes e produtos por 1 Robux durante o teste. A interface consulta o preço atual no cliente e desativa a compra se a Roblox não confirmar preço/disponibilidade.

Os dez IDs abaixo estão em `07K6_CARD_CATALOG.Products`. As chaves Vesper/Hex/Aether permanecem internas para preservar dados salvos; os nomes exibidos são Veyra/Nyxar/Vaelis. Éter Visual (3716300364) está desativado e não é usado.

| Developer Product | ID | Preço de teste informado |
|---|---:|---:|
| Caixa Nox | 3716296910 | 1 Robux |
| Caixa Reign | 3716298871 | 1 Robux |
| Caixa Eclipse | 3716298939 | 1 Robux |
| Visual Onyx | 3716298994 | 1 Robux |
| Visual Veyra | 3716299051 | 1 Robux |
| Visual Nyxar | 3716299236 | 1 Robux |
| Visual Aurum | 3716300186 | 1 Robux |
| Visual Valor | 3716300285 | 1 Robux |
| Visual Vaelis | 3716300668 | 1 Robux |
| Visual Nova | 3716300484 | 1 Robux |

Publique em um place de teste e use duas contas para verificar os itens de QA em `audits/V44/README.md`. O proprietário pode já possuir seus passes; a compra real deve ser conferida por uma conta que ainda não tenha o benefício. Não use os testes simulados como prova de compra real.
