# Instalação V52 — 23 substituições + 5 NOVOS

Requer a V51 completa já instalada. São 28 itens: 23 SUBSTITUIÇÕES e 5 NOVOS. Pare Play. Crie primeiro os cinco NOVOS como ModuleScripts em ReplicatedStorage, na ordem do instalador; depois substitua apenas os 23 existentes, sem duplicar instâncias. Cada item tem 2 partes consecutivas no MESMO script; também há Copiar script inteiro. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V52.md. Para roupas 3D, confira Layered Clothing nas propriedades/Avatar Settings do projeto: LoadCharacterLayeredClothing precisa permitir roupas em camadas; essa propriedade não pode ser alterada por scripts.

## Criar primeiro — 5 NOVOS

| Nome exato no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `07K14_DECK_OPTIONS` | ModuleScript | ReplicatedStorage | 2 |
| `08B3_AVATAR_VERIFY` | ModuleScript | ReplicatedStorage | 2 |
| `07H5_TRUCO_SETUP` | ModuleScript | ReplicatedStorage | 2 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 2 |
| `07K16_ATELIER_UI` | ModuleScript | ReplicatedStorage | 2 |

## Substituir — 23 existentes

| Nome exato no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `08B_AVATAR_DATA` | ModuleScript | ReplicatedStorage | 2 |
| `08B1_BODY_PACKAGES` | ModuleScript | ReplicatedStorage | 2 |
| `08D_SKIN_STATE` | ModuleScript | ReplicatedStorage | 2 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 2 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 2 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 2 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 2 |
| `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 2 |
| `09C1_SHOP_LOOKS` | ModuleScript | ReplicatedStorage | 2 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 2 |
| `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 2 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `07H2_GAME_BOARD` | ModuleScript | ReplicatedStorage | 2 |
| `07K0_TRUCO_RULES` | ModuleScript | ReplicatedStorage | 2 |
| `07K2_TRUCO_MATCH` | ModuleScript | ServerScriptService | 2 |
| `07K_TRUCO_SERVER` | Script | ServerScriptService | 2 |
| `07K6_CARD_CATALOG` | ModuleScript | ReplicatedStorage | 2 |
| `07K7_CARD_STYLES` | ModuleScript | ReplicatedStorage | 2 |
| `07K8_CARD_INVENTORY` | ModuleScript | ServerScriptService | 2 |
| `07K10_CARD_COMMERCE` | ModuleScript | ServerScriptService | 2 |
| `07K9_CARD_INVENTORY_UI` | ModuleScript | ReplicatedStorage | 2 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 2 |
| `07K_TRUCO_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |

Apague a fonte antiga uma vez e cole as duas partes em ordem na mesma instância, ou use Copiar script inteiro. Não crie scripts separados para as partes. Não reinstale versões anteriores por cima destes itens. Esta atualização não substitui 09A_SHOP_UI; suas quatro partes da V51 permanecem instaladas. Todas as fontes desta entrega têm até 357 linhas.

O HTML mostra nome, tipo, local, última linha e copiar, mantendo a fonte oculta. ONLINE fica verde quando a sincronização termina. Sem conexão, contém o delta V52 e a base histórica V44; a V52 ainda exige a V51 completa.

## O que conferir no Roblox

- **Corpos:** habilite roupas em camadas no projeto. Teste gato abacaxi, corpo meme e realista no perfil, prévia, Aplicar e respawn. Uma camisa não deve apagar o restante do outfit. Confira os itens com X embaixo. A verificação física agora rejeita um acessório 3D ausente em vez de confirmar só pelos IDs.
- **Comunidade e looks:** somente pesquisa, filtro e outfits, com 4 colunas em telas largas ou 3 nas menores. Até 5 linhas quando há espaço legível. Meus avatares seleciona um look e abre sua prévia; itens continuam embaixo.
- **Jogos:** três painéis no desktop/deitado, três painéis amplos empilhados no retrato. Moedas no cabeçalho, ações separadas, X acessível. Xadrez/dama usam tabuleiro maior e centrado.
- **Truco:** partida rápida oferece variante e baralho cheio/limpo. Criar permite selecionar valores/naipes e salvar a configuração; mesas personalizadas não dão ranking nem moedas competitivas. Cartas próprias embaixo, públicas no centro e coleta visual para o canto. Cartas dos adversários permanecem privadas.
- **Visuais:** compras diretas, três cartas de amostra, Meus visuais/Salvos/Ateliê. Não há novas compras de caixas. Créditos antigos continuam resgatáveis sem cobrança nova.
- **Ateliê:** use uma imagem/decal permitido no Roblox. Carregar/↻ mostram sucesso ou erro. Teste arrastar, zoom, giro, luz, moldura/faixa, frente/verso, aplicar, guardar e reequipar em Salvos. Até 12 visuais salvos por conta.

Passes e IDs de produtos diretos permanecem os mesmos. Preços vêm da Roblox no cliente; esta atualização não modifica os valores do painel. Não use Éter Visual (3716300364), que continua desativado. Recibos antigos dos três produtos de caixas são processados para não perder compras pendentes.

Os testes são simulados e não comprovam disponibilidade/renderização de assets específicos, desempenho no aparelho ou pagamentos reais. Consulte [audits/V52/README.md](audits/V52/README.md) e [audits/V52/RESEARCH.md](audits/V52/RESEARCH.md).
