# Instalação V44 — Studio Lite

Requer V43 completa e os scripts originais do handoff já instalados. Pare Play. CRIE 22 instâncias e SUBSTITUA 33 nos locais indicados, sem duplicar nomes. 07A_CHESS, 07B_CHECKERS, 07C_POISON_POTATO e 07W_WINS_SERVICE SUBSTITUEM os originais que já existem no jogo, embora apareçam pela primeira vez neste repositório. 07C_POISON_POTATO agora desativa o jogo antigo; não mantenha sua cópia ativa. Mantenha as regras 07A0/07B0 originais no ServerScriptService e as cópias em ReplicatedStorage. 09A_SHOP_UI: apague o código antigo uma vez e cole exatamente as 4 partes, em ordem, no MESMO ModuleScript. Instale os 55 itens antes de Play. Passes usam os IDs informados e o preço atual do Roblox, inclusive 2 Robux durante seu teste. Produtos repetíveis continuam desativados até receber IDs de Developer Product. Caixas oferecem escolha garantida, sem sorteios. Consulte INSTALL_V44.md e audits/V44/README.md.

## Antes de instalar

Faça uma cópia do seu place e pare Play. Esta é uma atualização da V43, não um projeto vazio. A V43 depende da V42 e dos scripts originais do handoff. Preserve `08B_AVATAR_DATA` e `08D_SKIN_STATE` V41, `08L_COMMUNITY`, `07P1_CAPTURE_ENGINE`, `07H2_BOT_CLIENT`, `07H3_CROSS_SERVER_ROOMS`, `07Z_BOARD_VISUALS`, as regras 07A0/07B0 nos dois locais indicados na V37 e a base que cria `PracaKit`.

No instalador, abra V44 e copie cada parte no tipo e local da tabela. Para SUBSTITUIR, use a instância existente e apague sua fonte antiga antes de colar. Para CRIAR, crie uma única instância com o nome exato. Partes consecutivas pertencem à mesma instância.

Os sete módulos mantidos com a mesma fonte da V43 também estão no pacote para facilitar uma instalação coerente. O carrinho e Plus não precisam de passe adicional.

## Os 55 scripts

| Ação | Nome | Tipo | Local | Linhas |
|---|---|---|---|---:|
| SUBSTITUIR | `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 97 |
| SUBSTITUIR | `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 84 |
| CRIAR | `07G3_PERSONAL_TOOLS` | ModuleScript | ReplicatedStorage | 38 |
| SUBSTITUIR | `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 89 |
| SUBSTITUIR | `07H4_BOT_ENGINE` | ModuleScript | ReplicatedStorage | 96 |
| CRIAR | `07K0_TRUCO_RULES` | ModuleScript | ReplicatedStorage | 163 |
| CRIAR | `07K12_TOURNAMENT_UI` | ModuleScript | ReplicatedStorage | 58 |
| CRIAR | `07K1_TRUCO_AI` | ModuleScript | ReplicatedStorage | 45 |
| CRIAR | `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 96 |
| CRIAR | `07K6_CARD_CATALOG` | ModuleScript | ReplicatedStorage | 33 |
| CRIAR | `07K7_CARD_STYLES` | ModuleScript | ReplicatedStorage | 42 |
| CRIAR | `07K9_CARD_INVENTORY_UI` | ModuleScript | ReplicatedStorage | 157 |
| SUBSTITUIR | `07P0_STUDIO_PRESETS` | ModuleScript | ReplicatedStorage | 20 |
| SUBSTITUIR | `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 146 |
| SUBSTITUIR | `07P3_POSE_EDITOR` | ModuleScript | ReplicatedStorage | 51 |
| SUBSTITUIR | `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 88 |
| SUBSTITUIR | `07P5_POSE_CANVAS` | ModuleScript | ReplicatedStorage | 128 |
| SUBSTITUIR | `07P6_STUDIO_SETS` | ModuleScript | ReplicatedStorage | 67 |
| SUBSTITUIR | `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 151 |
| SUBSTITUIR | `07UI_SCREEN_BOUNDS` | ModuleScript | ReplicatedStorage | 31 |
| SUBSTITUIR | `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 127 |
| SUBSTITUIR | `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 61 |
| SUBSTITUIR | `09A_SHOP_UI` | ModuleScript | ReplicatedStorage | 280 |
| CRIAR | `09C10_CONFIRM_ACTION` | ModuleScript | ReplicatedStorage | 18 |
| SUBSTITUIR | `09C1_SHOP_LOOKS` | ModuleScript | ReplicatedStorage | 173 |
| SUBSTITUIR | `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 245 |
| SUBSTITUIR | `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 149 |
| SUBSTITUIR | `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 95 |
| SUBSTITUIR | `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 143 |
| SUBSTITUIR | `09C8_COMMUNITY_DETAILS` | ModuleScript | ReplicatedStorage | 123 |
| CRIAR | `09C9_PLAYER_INSPECT` | ModuleScript | ReplicatedStorage | 21 |
| CRIAR | `07K10_CARD_COMMERCE` | ModuleScript | ServerScriptService | 78 |
| CRIAR | `07K11_GAMES_PROGRESS` | ModuleScript | ServerScriptService | 47 |
| CRIAR | `07K13_TOURNAMENT_SERVICE` | ModuleScript | ServerScriptService | 212 |
| CRIAR | `07K2_TRUCO_MATCH` | ModuleScript | ServerScriptService | 64 |
| CRIAR | `07K3_TRUCO_DIRECTORY` | ModuleScript | ServerScriptService | 94 |
| CRIAR | `07K4_TRUCO_TABLES` | ModuleScript | ServerScriptService | 44 |
| CRIAR | `07K8_CARD_INVENTORY` | ModuleScript | ServerScriptService | 144 |
| SUBSTITUIR | `07W_WINS_SERVICE` | ModuleScript | ServerScriptService | 60 |
| SUBSTITUIR | `09B1_AVATAR_DISCOVERY` | ModuleScript | ServerScriptService | 88 |
| SUBSTITUIR | `09B2_COSPLAY_METADATA` | ModuleScript | ServerScriptService | 31 |
| CRIAR | `09B3_PLAYER_INSPECT` | ModuleScript | ServerScriptService | 42 |
| CRIAR | `09B4_CURATED_LOOKS` | ModuleScript | ServerScriptService | 65 |
| SUBSTITUIR | `01C_HUB_CHALLENGES` | Script | ServerScriptService | 197 |
| SUBSTITUIR | `07A_CHESS` | Script | ServerScriptService | 393 |
| SUBSTITUIR | `07B_CHECKERS` | Script | ServerScriptService | 376 |
| SUBSTITUIR | `07C_POISON_POTATO` | Script | ServerScriptService | 4 |
| SUBSTITUIR | `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 105 |
| CRIAR | `07G_SETTINGS_SERVER` | Script | ServerScriptService | 37 |
| SUBSTITUIR | `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 192 |
| CRIAR | `07K_TRUCO_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 92 |
| CRIAR | `07K_TRUCO_SERVER` | Script | ServerScriptService | 218 |
| SUBSTITUIR | `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 150 |
| SUBSTITUIR | `09B_SHOP_SERVER` | Script | ServerScriptService | 205 |
| SUBSTITUIR | `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 358 |

## Compras e primeiro teste

Os passes 1951234105/1962433436/1966813498 estão associados a Ateliê/Regent/Zenith. O código não muda preços no painel Roblox. Mantenha os 2 Robux durante o teste. Caixas e os outros visuais por Robux precisam de Developer Products: seus IDs ficam em `07K6_CARD_CATALOG.Products`, por enquanto todos zero. Não coloque IDs de Game Pass nesse registro.

Publique em um place de teste e use duas contas para verificar os itens de QA em `audits/V44/README.md`. O proprietário pode já possuir seus passes; a compra real deve ser conferida por uma conta que ainda não tenha o benefício. Não use os testes simulados como prova de compra real.
