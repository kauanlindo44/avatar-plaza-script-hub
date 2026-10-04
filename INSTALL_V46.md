# Instalação V46 — Studio Lite

Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. SUBSTITUA estes 30 scripts nas instâncias existentes, sem duplicar nomes. A V46 inclui as correções da V45; não precisa instalar a V45 separadamente. Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. Se ainda estiver instalando a V44, termine os 55 itens primeiro. 09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V46, em ordem, no MESMO ModuleScript. Os demais têm 2 partes consecutivas. Não misture versões. IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V46.md.

Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. A V46 atualiza a V44 ou a V45 instalada. O HTML contém V44 e V46 offline. Preserve as dependências da [V44](INSTALL_V44.md), substituindo também o `08B_AVATAR_DATA` original pela V46. Os identificadores VERSION V41/V44 internos são contratos de compatibilidade, não sinais de código antigo.

| Nome | Ação | Tipo | Local | Linhas | Partes |
|---|---|---|---|---:|---:|
| `07H1_GAME_LOBBY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 117 | 2 |
| `07K0_TRUCO_RULES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 164 | 2 |
| `07K12_TOURNAMENT_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 58 | 2 |
| `07K5_TRUCO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 114 | 2 |
| `07K7_CARD_STYLES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 95 | 2 |
| `07K9_CARD_INVENTORY_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 271 | 2 |
| `07P0_STUDIO_PRESETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 20 | 2 |
| `07P2_STUDIO_AVATAR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 175 | 2 |
| `07P3_POSE_EDITOR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 69 | 2 |
| `07P4_STUDIO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 90 | 2 |
| `07P5_POSE_CANVAS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 162 | 2 |
| `07P6_STUDIO_SETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 71 | 2 |
| `07UI_DESIGN_SYSTEM` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 151 | 2 |
| `09A1_SHOP_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 129 | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 280 | 4 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 248 | 2 |
| `09C7_COMMUNITY_FEED` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 116 | 2 |
| `09C8_COMMUNITY_DETAILS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 123 | 2 |
| `07K2_TRUCO_MATCH` | SUBSTITUIR | ModuleScript | ServerScriptService | 70 | 2 |
| `07K4_TRUCO_TABLES` | SUBSTITUIR | ModuleScript | ServerScriptService | 47 | 2 |
| `07K8_CARD_INVENTORY` | SUBSTITUIR | ModuleScript | ServerScriptService | 144 | 2 |
| `09B1_AVATAR_DISCOVERY` | SUBSTITUIR | ModuleScript | ServerScriptService | 101 | 2 |
| `09B2_COSPLAY_METADATA` | SUBSTITUIR | ModuleScript | ServerScriptService | 40 | 2 |
| `09B4_CURATED_LOOKS` | SUBSTITUIR | ModuleScript | ServerScriptService | 140 | 2 |
| `07H_GAME_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 192 | 2 |
| `07K_TRUCO_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 217 | 2 |
| `07K_TRUCO_SERVER` | SUBSTITUIR | Script | ServerScriptService | 216 | 2 |
| `07P_PHOTO_MODE` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 173 | 2 |
| `09C_SHOP_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 366 | 2 |
| `08B_AVATAR_DATA` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 382 | 2 |

Após instalar, inicie Play e confira Output. Teste Contra bots no Truco em paisagem: mesa visível, três cartas acima dos botões, câmera por arraste, centralizar, qualquer carta e pausas entre bots. No Ateliê, cole ID/link de imagem pública aprovada, pressione Carregar/Recarregar, ajuste e Salvar e equipar. No catálogo, experimentar, remover item e proporções aplicam no personagem; Restaurar pede confirmação. Em Corpo, verifique os pacotes reais. No Photo Mode, abra Animações em R15, congele e ajuste tocando uma parte ou pelo manequim. Na comunidade, teste Carregar mais, erro/retry, gratuito/pago, X e quatro ângulos. Faça a conferência em place publicado: serviços, compras e renderização nativos não foram executados nesta auditoria.
