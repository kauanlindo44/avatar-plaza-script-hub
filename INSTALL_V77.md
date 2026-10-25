# Instalação V77 — 5 novos + 24 substituições

Base: V76 completa. V77: 5 NOVOS + 24 SUBSTITUIÇÕES. Pare Play. Crie primeiro os cinco ModuleScripts novos em ReplicatedStorage, exatamente com os nomes indicados. Depois substitua as 24 fontes existentes por inteiro, nos tipos/locais indicados. Não acrescente V77 ou contadores aos nomes. Use Copiar script inteiro; partes são alternativa para a mesma instância. Reinicie Play depois dos dois grupos. Guia: INSTALL_V77.md.

## Criar os 5 módulos novos

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/5 | `07G11_REFERENCE_WORLDS` | ModuleScript | ReplicatedStorage | 94 |
| 2/5 | `07H12_SCORE_SHEET` | ModuleScript | ReplicatedStorage | 34 |
| 3/5 | `07UI_REFERENCE_LAYOUT` | ModuleScript | ReplicatedStorage | 69 |
| 4/5 | `09C20_AVATAR_REMOVAL` | ModuleScript | ReplicatedStorage | 95 |
| 5/5 | `09I27_STYLE_CATALOG` | ModuleScript | ReplicatedStorage | 31 |

## Substituir as 24 fontes existentes

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/24 | `07G10_HUD_LAYOUT` | ModuleScript | ReplicatedStorage | 79 |
| 2/24 | `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 117 |
| 3/24 | `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 89 |
| 4/24 | `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 72 |
| 5/24 | `07G9_COMMAND_PANEL` | ModuleScript | ReplicatedStorage | 43 |
| 6/24 | `07H2_GAME_BOARD` | ModuleScript | ReplicatedStorage | 215 |
| 7/24 | `07H7_BOARD_SESSIONS` | ModuleScript | ServerScriptService | 81 |
| 8/24 | `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 175 |
| 9/24 | `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 121 |
| 10/24 | `07P9_STUDIO_CATALOG` | ModuleScript | ReplicatedStorage | 98 |
| 11/24 | `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 205 |
| 12/24 | `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 60 |
| 13/24 | `09C16_CATALOG_HOME` | ModuleScript | ReplicatedStorage | 77 |
| 14/24 | `09C18_AVATAR_SAVE` | ModuleScript | ReplicatedStorage | 97 |
| 15/24 | `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 296 |
| 16/24 | `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 188 |
| 17/24 | `09I13_OUTFIT_SEARCH` | ModuleScript | ServerScriptService | 90 |
| 18/24 | `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 147 |
| 19/24 | `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 142 |
| 20/24 | `BC_HUD` | ModuleScript | ReplicatedStorage | 140 |
| 21/24 | `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 149 |
| 22/24 | `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 258 |
| 23/24 | `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 184 |
| 24/24 | `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 399 |

## Depois de instalar

Reinicie Play somente depois de criar todos os módulos e substituir todas as fontes. Não execute fontes parciais. Os números do instalador são contadores de progresso; não fazem parte dos nomes das instâncias.

Valide no Studio/Studio Lite: abertura da IA, catálogo e compra oficial; salvar/restaurar e desfazer; avatar e captura no modo foto; gestos e recortes no celular; 19 mundos; partida de xadrez e damas entre duas contas; Truco; queda/empurrão/explosão e áudio no Botão do Caos. Este pacote não executa testes de física, FPS, áudio, compras reais ou publicação do place.

Nenhuma chave de IA, serviço externo pago ou novo produto de cobrança foi adicionado. Plus e Pro mantêm os IDs existentes; o servidor conserva a autoridade de recibos.

Use [a conferência do pedido](audits/V77/PROMPT_REVIEW.md) para distinguir implementações, simulações e pendências. Os JPGs são reconstruções das posições da interface, com miniaturas ilustrativas, não capturas do Roblox.
