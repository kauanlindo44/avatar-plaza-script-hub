# Instalação V45 — Studio Lite

Requer V44 completa, com os 55 scripts e a base original já instalados. Pare Play. SUBSTITUA apenas estes 14 scripts nas instâncias existentes; não crie nomes duplicados. Nenhum script novo, passe ou Developer Product adicional é necessário. Se ainda estiver instalando a V44, termine os 55 itens antes desta atualização. 09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes da V45, em ordem, no MESMO ModuleScript. Os outros scripts têm 2 partes consecutivas. Não misture partes de versões diferentes. Os IDs e preços atuais das compras são mantidos. Consulte INSTALL_V45.md.

Os títulos do HTML exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. Preserve as dependências da [V44](INSTALL_V44.md). O HTML contém V44 e V45 para instalação offline.

| Nome | Ação | Tipo | Local | Linhas | Partes |
|---|---|---|---|---:|---:|
| `07H1_GAME_LOBBY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 112 | 2 |
| `07K5_TRUCO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 97 | 2 |
| `07K7_CARD_STYLES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 73 | 2 |
| `07K9_CARD_INVENTORY_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 251 | 2 |
| `07UI_DESIGN_SYSTEM` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 151 | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 280 | 4 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 245 | 2 |
| `09C7_COMMUNITY_FEED` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 170 | 2 |
| `09C8_COMMUNITY_DETAILS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 123 | 2 |
| `07K8_CARD_INVENTORY` | SUBSTITUIR | ModuleScript | ServerScriptService | 144 | 2 |
| `09B2_COSPLAY_METADATA` | SUBSTITUIR | ModuleScript | ServerScriptService | 40 | 2 |
| `09B4_CURATED_LOOKS` | SUBSTITUIR | ModuleScript | ServerScriptService | 129 | 2 |
| `07K_TRUCO_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 180 | 2 |
| `07K_TRUCO_SERVER` | SUBSTITUIR | Script | ServerScriptService | 218 | 2 |

Ao terminar, inicie Play e confira Output. Para verificar a câmera/mão do Truco, entre em Treino; para o Ateliê, use uma imagem pública aprovada e o passe existente. Faça a conferência final em um place publicado, porque DataStore, compras e serviços do Roblox não são reproduzidos integralmente pelo Play do Studio Lite.
