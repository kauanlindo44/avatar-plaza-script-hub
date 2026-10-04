# Instalação V49 — Studio Lite

Requer V44 completa e a base original já instaladas. Pare Play. A V49 tem 3 scripts NOVOS e 38 substituições cumulativas desde V44, incluindo V45 a V48. Crie primeiro 08B1_BODY_PACKAGES (ModuleScript/ReplicatedStorage), 09B5_AVATAR_RUNTIME (ModuleScript/ServerScriptService) e 09C11_AVATAR_CHARACTER (LocalScript/StarterPlayer > StarterPlayerScripts). Depois substitua as fontes indicadas nas instâncias existentes, sem duplicar nomes. 08B_AVATAR_DATA e 08D_SKIN_STATE substituem seus ModuleScripts originais em ReplicatedStorage. Se já terminou a V48, faça somente os 11 itens da lista de diferenças: 3 criações e 8 substituições. Se ainda está instalando a V44, termine seus 55 itens primeiro. 09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V49 em ordem no MESMO ModuleScript. Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. Nenhum passe ou produto adicional; IDs e preços do Roblox mantidos. Consulte INSTALL_V49.md.

Os avisos **(NOVO)** e **(SUBSTITUIR)** pertencem ao instalador, nunca ao nome da instância. O HTML contém V44 e V49 offline e preserva o histórico online. VERSION V41/V44 internos continuam como contratos de compatibilidade.

## Se já terminou a V48

São **11 itens**: **3 NOVOS + 8 substituições**. Pare Play; crie os três novos nas localizações abaixo antes de substituir as fontes restantes. Não reinstale os outros scripts da V48.

| Nome | Ação | Tipo | Local | Partes |
|---|---|---|---|---:|
| `08B1_BODY_PACKAGES` | **NOVO** | ModuleScript | ReplicatedStorage | 2 |
| `08B_AVATAR_DATA` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 2 |
| `08D_SKIN_STATE` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 2 |
| `09A1_SHOP_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 4 |
| `09B5_AVATAR_RUNTIME` | **NOVO** | ModuleScript | ServerScriptService | 2 |
| `09B_SHOP_SERVER` | SUBSTITUIR | Script | ServerScriptService | 2 |
| `09C11_AVATAR_CHARACTER` | **NOVO** | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 2 |
| `09C4_OUTFIT_LIBRARY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 2 |
| `09C_SHOP_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |

## Pacote cumulativo desde V44

Se está em V44/V45/V46/V47 ou não sabe quais correções instalou, use os **41 itens** desta tabela: **3 NOVOS + 38 substituições**. A base completa V44 ainda é necessária. Para 09A, cole as quatro partes juntas no mesmo ModuleScript. Nos demais, cole ambas as partes na mesma instância.

| Nome | Ação | Tipo | Local | Linhas | Partes |
|---|---|---|---|---:|---:|
| `08B1_BODY_PACKAGES` | **NOVO** | ModuleScript | ReplicatedStorage | 47 | 2 |
| `09B5_AVATAR_RUNTIME` | **NOVO** | ModuleScript | ServerScriptService | 157 | 2 |
| `09C11_AVATAR_CHARACTER` | **NOVO** | LocalScript | StarterPlayer > StarterPlayerScripts | 54 | 2 |
| `07G_HUB_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 105 | 2 |
| `07H1_GAME_LOBBY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 171 | 2 |
| `07H_GAME_UI` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 192 | 2 |
| `07K0_TRUCO_RULES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 164 | 2 |
| `07K12_TOURNAMENT_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 58 | 2 |
| `07K2_TRUCO_MATCH` | SUBSTITUIR | ModuleScript | ServerScriptService | 70 | 2 |
| `07K4_TRUCO_TABLES` | SUBSTITUIR | ModuleScript | ServerScriptService | 47 | 2 |
| `07K5_TRUCO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 145 | 2 |
| `07K6_CARD_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 37 | 2 |
| `07K7_CARD_STYLES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 132 | 2 |
| `07K8_CARD_INVENTORY` | SUBSTITUIR | ModuleScript | ServerScriptService | 146 | 2 |
| `07K9_CARD_INVENTORY_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 318 | 2 |
| `07K_TRUCO_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 83 | 2 |
| `07K_TRUCO_SERVER` | SUBSTITUIR | Script | ServerScriptService | 237 | 2 |
| `07P0_STUDIO_PRESETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 20 | 2 |
| `07P2_STUDIO_AVATAR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 188 | 2 |
| `07P3_POSE_EDITOR` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 69 | 2 |
| `07P4_STUDIO_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 115 | 2 |
| `07P5_POSE_CANVAS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 162 | 2 |
| `07P6_STUDIO_SETS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 135 | 2 |
| `07P_PHOTO_MODE` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 175 | 2 |
| `07UI_DESIGN_SYSTEM` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 154 | 2 |
| `07UI_SCREEN_BOUNDS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 36 | 2 |
| `08B_AVATAR_DATA` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 345 | 2 |
| `08D_SKIN_STATE` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 131 | 2 |
| `09A1_SHOP_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 134 | 2 |
| `09A2_PREVIEW_LAYOUT` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 61 | 2 |
| `09A_SHOP_UI` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 280 | 4 |
| `09B1_AVATAR_DISCOVERY` | SUBSTITUIR | ModuleScript | ServerScriptService | 129 | 2 |
| `09B2_COSPLAY_METADATA` | SUBSTITUIR | ModuleScript | ServerScriptService | 40 | 2 |
| `09B4_CURATED_LOOKS` | SUBSTITUIR | ModuleScript | ServerScriptService | 140 | 2 |
| `09B_SHOP_SERVER` | SUBSTITUIR | Script | ServerScriptService | 203 | 2 |
| `09C2_SHOP_CATALOG` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 248 | 2 |
| `09C4_OUTFIT_LIBRARY` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 167 | 2 |
| `09C5_UGC_STORES` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 71 | 2 |
| `09C7_COMMUNITY_FEED` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 130 | 2 |
| `09C8_COMMUNITY_DETAILS` | SUBSTITUIR | ModuleScript | ReplicatedStorage | 146 | 2 |
| `09C_SHOP_CLIENT` | SUBSTITUIR | LocalScript | StarterPlayer > StarterPlayerScripts | 367 | 2 |

## O que foi corrigido

- Entrada: consulta o HumanoidDescription equipado no perfil Roblox e desliga UseAvatarSettings para a construção desse avatar. Um corpo comprado precisa estar equipado na conta para aparecer automaticamente; possuir o pacote sem equipá-lo não muda o avatar. A correção não faz nenhuma compra.
- Corpo/pacote: usa IDs das seis partes, proporções e animações do outfit nativo. Corpos diferentes continuam usando articulações internas R15. Roupas e acessórios existentes são mantidos ao experimentar um corpo. Pacote incompleto ou indisponível mostra erro em vez de sucesso parcial.
- Aplicar: ao trocar corpo ou rig, cria um personagem nativo completo com o rig escolhido. Mantém posição, vida, velocidade e ferramentas; retoma assento e liga câmera/animações. Confere os IDs, rig, partes e proporções efetivos antes de responder. Se o Roblox não carregar o novo modelo, mantém o anterior.
- Reaparecimento: recupera o último look confirmado durante a mesma sessão. A V49 não salva automaticamente o outfit no perfil Roblox nem entre servidores; use Salvar para guardar seus looks.
- Catálogo: prévia quadrada, duas linhas, cinco colunas em telas largas e quatro quando necessário; miniaturas e Robux legíveis. Aplicar continua em texto verde, com Salvar/Restaurar/Carrinho/Corpo em ícones. Os itens equipados permanecem abaixo com X ao lado da imagem; espaço maior permite mais itens visíveis.

## Teste obrigatório no Roblox

1. Equipe o gato abacaxi na personalização do Roblox. Entre num servidor novo com todos os 11 itens atualizados. Confira o corpo inteiro, não só o R15 padrão, e o catálogo mostrando o mesmo avatar. Não é necessário comprar novamente para este teste.
2. Experimente um corpo realista e um meme/criatura. Confira frente, costas e lados, camisa/calça/acessórios, proporções e Aplicar. Em seguida remova só um item pelo X.
3. Teste R6 → R15, restaurar e reaparecer após morrer. Confirme câmera, andar, correr/pular, emotes, Photo Mode e retorno à sala de jogos.
4. Em celular retrato/paisagem e desktop, confira duas linhas do catálogo, miniaturas dos itens, X, ações e popup de corpo. Uma falha temporária do Roblox deve mostrar aviso e permitir tentar de novo.

**Validação:** 91 casos em Lua 5.4 com serviços simulados + 1 caso do JavaScript real do instalador. Os doubles não carregam meshes reais; não foi possível validar o pacote específico do gato abacaxi no Roblox/Studio Lite daqui. IDs, preços, passes e Developer Products são os mesmos da V48.
