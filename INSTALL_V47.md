# Instalação V47 — Studio Lite

Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. SUBSTITUA estes 32 scripts nas instâncias existentes, sem duplicar nomes. A V47 inclui V45 e V46; não precisa instalá-las separadamente. Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. Se ainda estiver instalando a V44, termine os 55 itens primeiro. 09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V47, em ordem, no MESMO ModuleScript. Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. Quem já terminou a V46 pode substituir apenas os 18 nomes da lista de diferenças em INSTALL_V47.md. IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V47.md.

Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. **0 scripts NOVOS**. O HTML contém V44 e V47 offline e preserva o histórico online. Preserve as dependências da [V44](INSTALL_V44.md). Os identificadores VERSION V41/V44 internos são contratos de compatibilidade.

## Se já terminou a V46

Substitua somente estes **18 scripts** pela fonte V47. Pare Play antes. Use as mesmas instâncias, tipos e locais da tabela abaixo; apague a fonte antiga uma vez e cole todas as partes do script.

- `07H1_GAME_LOBBY` — **SUBSTITUIR**
- `07K7_CARD_STYLES` — **SUBSTITUIR**
- `07K8_CARD_INVENTORY` — **SUBSTITUIR**
- `07K9_CARD_INVENTORY_UI` — **SUBSTITUIR**
- `07K_TRUCO_SERVER` — **SUBSTITUIR**
- `07P0_STUDIO_PRESETS` — **SUBSTITUIR**
- `07P2_STUDIO_AVATAR` — **SUBSTITUIR**
- `07P4_STUDIO_UI` — **SUBSTITUIR**
- `07P6_STUDIO_SETS` — **SUBSTITUIR**
- `07P_PHOTO_MODE` — **SUBSTITUIR**
- `07UI_DESIGN_SYSTEM` — **SUBSTITUIR**
- `07UI_SCREEN_BOUNDS` — **SUBSTITUIR**
- `09A1_SHOP_LAYOUT` — **SUBSTITUIR**
- `09A_SHOP_UI` — **SUBSTITUIR**
- `09B1_AVATAR_DISCOVERY` — **SUBSTITUIR**
- `09B4_CURATED_LOOKS` — **SUBSTITUIR**
- `09B_SHOP_SERVER` — **SUBSTITUIR**
- `09C7_COMMUNITY_FEED` — **SUBSTITUIR**

## Pacote completo de substituições desde V44

Se está na V44/V45 ou não sabe quais correções já instalou, substitua os **32** nomes desta tabela. A V47 contém as correções anteriores.

| Nome | Ação | Tipo | Local | Linhas | Partes |
|---|---|---|---|---:|---:|
| `07H1_GAME_LOBBY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 131 | 2 |
| `07K0_TRUCO_RULES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 164 | 2 |
| `07K12_TOURNAMENT_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 58 | 2 |
| `07K5_TRUCO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 114 | 2 |
| `07K7_CARD_STYLES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 115 | 2 |
| `07K9_CARD_INVENTORY_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 284 | 2 |
| `07P0_STUDIO_PRESETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 20 | 2 |
| `07P2_STUDIO_AVATAR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 188 | 2 |
| `07P3_POSE_EDITOR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 69 | 2 |
| `07P4_STUDIO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 109 | 2 |
| `07P5_POSE_CANVAS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 162 | 2 |
| `07P6_STUDIO_SETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 119 | 2 |
| `07UI_DESIGN_SYSTEM` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 154 | 2 |
| `07UI_SCREEN_BOUNDS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 36 | 2 |
| `09A1_SHOP_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 130 | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 279 | 4 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 248 | 2 |
| `09C7_COMMUNITY_FEED` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 123 | 2 |
| `09C8_COMMUNITY_DETAILS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 123 | 2 |
| `07K2_TRUCO_MATCH` | SUBSTITUIR | ModuleScript | ServerScriptService | 70 | 2 |
| `07K4_TRUCO_TABLES` | SUBSTITUIR | ModuleScript | ServerScriptService | 47 | 2 |
| `07K8_CARD_INVENTORY` | SUBSTITUIR | ModuleScript | ServerScriptService | 146 | 2 |
| `09B1_AVATAR_DISCOVERY` | SUBSTITUIR | ModuleScript | ServerScriptService | 125 | 2 |
| `09B2_COSPLAY_METADATA` | SUBSTITUIR | ModuleScript | ServerScriptService | 40 | 2 |
| `09B4_CURATED_LOOKS` | SUBSTITUIR | ModuleScript | ServerScriptService | 140 | 2 |
| `07H_GAME_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 192 | 2 |
| `07K_TRUCO_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 217 | 2 |
| `07K_TRUCO_SERVER` | SUBSTITUIR | Script | ServerScriptService | 237 | 2 |
| `07P_PHOTO_MODE` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 173 | 2 |
| `09B_SHOP_SERVER` | SUBSTITUIR | Script | ServerScriptService | 211 | 2 |
| `09C_SHOP_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 366 | 2 |
| `08B_AVATAR_DATA` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 382 | 2 |

## Conferência no jogo

1. Jogos: escolha Xadrez, Damas e Truco no topo; veja Criar / entrar e Contra bots. Confira o código e Cancelar espera em paisagem.
2. Baralhos: Caixa Nox/Reign/Eclipse deve ter embalagem, diferente da carta. Em Ateliê, cole um ID/link de Image ou Decal publicado, pressione Carregar e espere a imagem aparecer. Ajuste recorte, veja frente/verso e pressione Salvar e equipar. Cliente e servidor devem estar ambos na V47. O carregamento de Decal respeita as permissões atuais da Roblox; nenhuma configuração para importar modelos de terceiros é habilitada.
3. Catálogo: confira a faixa inferior, duas linhas legíveis, prévia ampliada, itens removíveis por X e aplicação sem apagar acessórios não editados.
4. Comunidade: confira os quatro filtros visíveis, até três linhas conforme altura e Carregar mais. Os lotes restantes devem ser reaproveitados; erros devem mostrar uma tentativa, sem nomes de scripts. Somente descrições reais e distintas são exibidas.
5. Photo Mode: abra cada ferramenta lateral. Em R15, escolha um emote e veja o avatar no cenário se mover; pare/congele e edite a pose. Teste Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma, rotação, luz, pausar cenário, ocultar UI e sair.

Os 68 testes são simulados, exceto a execução real do JavaScript do instalador. Renderização, toque físico, imagens aprovadas, emotes e compras exigem teste no Roblox/Studio Lite/place publicado. Esta atualização não faz compras nem muda preços do painel.
